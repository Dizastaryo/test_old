#!/bin/bash
# Скрипт для исправления настроек кодовой подписи после обновления Flutter

PROJECT_FILE="Runner.xcodeproj/project.pbxproj"

# Функция для замены настроек в секции Release
fix_release_config() {
    # Используем sed для замены настроек в Release конфигурации
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' 's/CODE_SIGN_STYLE = Automatic;/CODE_SIGN_STYLE = Manual;/g' "$PROJECT_FILE"
        sed -i '' 's/"CODE_SIGN_IDENTITY\[sdk=iphoneos\*\]" = "iPhone Developer";/"CODE_SIGN_IDENTITY[sdk=iphoneos*]" = "";/g' "$PROJECT_FILE"
    else
        # Linux
        sed -i 's/CODE_SIGN_STYLE = Automatic;/CODE_SIGN_STYLE = Manual;/g' "$PROJECT_FILE"
        sed -i 's/"CODE_SIGN_IDENTITY\[sdk=iphoneos\*\]" = "iPhone Developer";/"CODE_SIGN_IDENTITY[sdk=iphoneos*]" = "";/g' "$PROJECT_FILE"
    fi
    
    # Добавляем настройки если их нет
    if ! grep -q "CODE_SIGN_IDENTITY = \"\";" "$PROJECT_FILE" || ! grep -q "DEVELOPMENT_TEAM = \"\";" "$PROJECT_FILE"; then
        # Это более сложная замена, нужно найти правильную секцию Release
        echo "Настройки кодовой подписи будут применены через xcconfig файлы"
    fi
}

# Запускаем исправление
cd "$(dirname "$0")"
fix_release_config
echo "Настройки кодовой подписи обновлены"
