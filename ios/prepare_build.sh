#!/bin/bash

# Скрипт для подготовки проекта к сборке без подписи
# Запускайте перед flutter build ios --release --no-codesign

set -e

PROJECT_FILE="ios/Runner.xcodeproj/project.pbxproj"

if [ ! -f "$PROJECT_FILE" ]; then
    echo "Error: $PROJECT_FILE not found"
    exit 1
fi

echo "Preparing project for build without code signing..."

# Убеждаемся, что настройки подписи отключены
# Это делается через sed для macOS (используйте sed без '' для Linux)

# Для macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
    # Обновляем общие настройки проекта
    sed -i '' 's/"CODE_SIGN_IDENTITY\[sdk=iphoneos\*\]" = "iPhone Developer";/"CODE_SIGN_IDENTITY[sdk=iphoneos*]" = "";/g' "$PROJECT_FILE"
    
    # Добавляем DEVELOPMENT_TEAM = "" если его нет
    if ! grep -q 'DEVELOPMENT_TEAM = "";' "$PROJECT_FILE"; then
        # Добавляем после CODE_SIGN_IDENTITY в общих настройках
        sed -i '' '/CODE_SIGN_IDENTITY\[sdk=iphoneos\*\]/a\
				DEVELOPMENT_TEAM = "";
' "$PROJECT_FILE"
    fi
else
    # Для Linux
    sed -i 's/"CODE_SIGN_IDENTITY\[sdk=iphoneos\*\]" = "iPhone Developer";/"CODE_SIGN_IDENTITY[sdk=iphoneos*]" = "";/g' "$PROJECT_FILE"
fi

echo "Project prepared for build without code signing."
