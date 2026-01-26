# Сборка iOS без подписи кода

Проект настроен для сборки без подписи кода через xcconfig файлы.

## Как это работает

Настройки отключения подписи находятся в файлах:
- `ios/Flutter/Release.xcconfig` 
- `ios/Flutter/Debug.xcconfig`

Эти файлы Flutter не перезаписывает при обновлении проекта, в отличие от `project.pbxproj`.

## Команда для сборки

```bash
flutter build ios --release --no-codesign
```

## Если сборка все еще не работает

Проблема может быть в том, что Xcode требует Development Team даже с `--no-codesign` для сборки на физическое устройство.

### Решение 1: Сборка для симулятора (рекомендуется)

```bash
flutter build ios --simulator --release
```

Это не требует подписи кода и работает всегда.

### Решение 2: Использовать xcodebuild напрямую

Если нужно собрать для устройства без подписи:

```bash
cd ios
xcodebuild -workspace Runner.xcworkspace \
  -scheme Runner \
  -configuration Release \
  -sdk iphoneos \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  DEVELOPMENT_TEAM="" \
  build
```

### Решение 3: Открыть в Xcode и убрать Development Team вручную

1. Откройте проект: `open ios/Runner.xcworkspace`
2. Выберите Runner target
3. В Signing & Capabilities уберите галочку "Automatically manage signing"
4. Оставьте Development Team пустым

## Примечания

- Приложение собранное без подписи не может быть установлено на устройство
- Для установки на устройство потребуется подписать приложение вручную через Xcode
- Сборка для симулятора не требует подписи и работает всегда
