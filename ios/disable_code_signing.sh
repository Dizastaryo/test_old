#!/bin/bash
# Скрипт для отключения подписи кода перед сборкой
# Используется в CI/CD

set -e

echo "Disabling code signing for build..."

# Устанавливаем переменные окружения для xcodebuild
export CODE_SIGN_IDENTITY=""
export CODE_SIGNING_REQUIRED="NO"
export CODE_SIGNING_ALLOWED="NO"
export DEVELOPMENT_TEAM=""
export PROVISIONING_PROFILE_SPECIFIER=""

# Также обновляем xcconfig файлы на всякий случай
if [ -f "Flutter/Release.xcconfig" ]; then
    # Убеждаемся, что настройки есть
    if ! grep -q "CODE_SIGN_IDENTITY=" Flutter/Release.xcconfig; then
        echo "CODE_SIGN_IDENTITY=" >> Flutter/Release.xcconfig
        echo "CODE_SIGNING_REQUIRED=NO" >> Flutter/Release.xcconfig
        echo "CODE_SIGNING_ALLOWED=NO" >> Flutter/Release.xcconfig
        echo "DEVELOPMENT_TEAM=" >> Flutter/Release.xcconfig
    fi
fi

echo "Code signing disabled."
