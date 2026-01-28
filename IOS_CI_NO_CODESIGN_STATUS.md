# iOS CI сборка `.ipa` без подписи (GitHub Actions + `--no-codesign`) — текущая ситуация

## Цель
Получить **настоящий** `.ipa` файл на CI **без Apple Developer аккаунта / Team ID / сертификатов**, используя:

- GitHub Actions (`macos-latest`)
- `flutter build ios --release --no-codesign`
- упаковку `Runner.app` в `Payload/` → `zip` → `.ipa`

Ожидаемый результат:

- ✅ `app.ipa` создаётся
- ❌ не подписан
- ❌ не ставится на iPhone напрямую
- ✅ пригоден как артефакт (можно подписать позже)

---

## Наблюдаемые ошибки и что они означают

### 1) Ошибка симулятора: `Release mode is not supported for simulators`
Возникает если запускать сборку **для симулятора** с `--release`.

Решение: для симулятора использовать `--debug` или убрать `--release`.

> Важно: `.ipa` для симулятора — это отдельная история. Для “настоящего IPA” нужен `iphoneos` (устройство), не `iphonesimulator`.

---

### 2) Ошибка установки Flutter в CI
Лог:

> Unable to determine Flutter version for channel: stable version: stable architecture: arm64

Причина: в `subosito/flutter-action` нельзя задавать `flutter-version: stable`.

Решение: оставить только:

- `with: channel: stable`

---

### 3) CocoaPods: `Flutter (from 'Flutter') required a higher minimum deployment target`
Лог:

> CocoaPods could not find compatible versions for pod "Flutter"... they required a higher minimum deployment target

Причина: в `ios/Podfile` была занижена минимальная версия iOS.

Решение:

- `platform :ios, '13.0'`
- + форс `IPHONEOS_DEPLOYMENT_TARGET = 13.0` в `post_install` для Pods

---

### 4) Главная проблема: Flutter всё ещё требует Development Team даже с `--no-codesign`
Лог:

> Building a deployable iOS app requires a selected Development Team...

Ключевая причина:

- `--no-codesign` отключает подпись при сборке,
- **но** в Xcode-проекте `Runner` подпись всё равно включена (`CODE_SIGN_STYLE = Automatic`, `CODE_SIGN_IDENTITY = iPhone Developer`),
- наш `Podfile post_install` отключал подпись **только для Pods**, а не для таргета `Runner`.

---

## Что уже сделано в репозитории

### 1) Workflow
Файл: `.github/workflows/dart.yml`

- Ставит Flutter через `subosito/flutter-action@v2` (`channel: stable`)
- Делает `flutter pub get`
- Делает `pod install`
- Пытается собрать: `flutter build ios --release --no-codesign`
- Упаковывает `build/ios/iphoneos/Runner.app` → `Payload/` → `app.ipa`
- Загружает `app.ipa` как artifact

### 2) `ios/Podfile`
Файл создан вручную, т.к. Podfile отсутствовал.

Добавлено:

- `platform :ios, '13.0'`
- в `post_install`: 
  - `IPHONEOS_DEPLOYMENT_TARGET = '13.0'`
  - `CODE_SIGNING_REQUIRED = NO`
  - `CODE_SIGNING_ALLOWED = NO`
  - `CODE_SIGN_IDENTITY = ""`
  - `DEVELOPMENT_TEAM = ""`

### 3) ВАЖНОЕ исправление: отключение подписи прямо в `Runner.xcodeproj`
Файл: `ios/Runner.xcodeproj/project.pbxproj`

Добавлены/изменены настройки кодовой подписи **для Runner** (Debug/Release/Profile) и для project-level конфигов:

- `CODE_SIGNING_ALLOWED = NO;`
- `CODE_SIGNING_REQUIRED = NO;`
- `CODE_SIGN_STYLE = Manual;`
- `"CODE_SIGN_IDENTITY[sdk=iphoneos*]" = "";`
- `DEVELOPMENT_TEAM = "";`
- `PROVISIONING_PROFILE_SPECIFIER = "";`

Это критично: именно отсутствие этих настроек чаще всего приводит к тому, что Flutter/Xcode продолжает требовать Team ID даже при `--no-codesign`.

---

## Что проверить в следующем прогоне CI

1) Убедиться, что шаг `pod install` выполняется (и генерируются `ios/Pods`, `ios/Podfile.lock`)
2) На шаге `flutter build ios --release --no-codesign` ожидаем:
   - предупреждение про отсутствие подписи — это нормально
   - **не** должно быть сообщения про “requires a selected Development Team”
3) Должен появиться `build/ios/iphoneos/Runner.app`
4) Должен появиться `app.ipa` как artifact

---

## Если ошибка “Development Team required” останется
Тогда есть 2 вероятных причины:

1) Flutter tool делает дополнительную проверку и падает до того, как Xcode успевает применить настройки.
2) В проекте есть ещё один конфиг/таргет (например, RunnerTests), который ломает сборку.

План диагностики:

- добавить в CI шаги печати важных build settings:
  - `xcodebuild -showBuildSettings -workspace ios/Runner.xcworkspace -scheme Runner | grep -E 'CODE_SIGN|DEVELOPMENT_TEAM|PROVISION'`
- при необходимости — отключить подпись также для RunnerTests (если начнёт мешать)

---

## Краткий итог
На данный момент устранены:

- ошибка release+simulator
- ошибка установки Flutter версии
- ошибка deployment target для CocoaPods
- добавлены настройки отключения подписи **не только для Pods, но и для Runner**

Следующий прогон CI должен либо:

- ✅ собрать `Runner.app` и упаковать `app.ipa`,
или
- снова упасть с тем же сообщением — тогда включаем диагностику `xcodebuild -showBuildSettings`.

