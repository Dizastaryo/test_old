#!/bin/bash

# Скрипт для отключения подписи кода в Xcode проекте
# Запускается после pod install

PROJECT_FILE="Runner.xcodeproj/project.pbxproj"

if [ ! -f "$PROJECT_FILE" ]; then
    echo "Error: $PROJECT_FILE not found"
    exit 1
fi

echo "Fixing code signing settings in $PROJECT_FILE..."

# Заменяем CODE_SIGN_IDENTITY на пустую строку в общих настройках
sed -i '' 's/"CODE_SIGN_IDENTITY\[sdk=iphoneos\*\]" = "iPhone Developer";/"CODE_SIGN_IDENTITY[sdk=iphoneos*]" = "";/g' "$PROJECT_FILE"

# Добавляем настройки отключения подписи в секции buildSettings для Runner target
# (если их еще нет)

echo "Code signing settings updated."
