#!/bin/bash

# Скрипт проверки корректности конфигурации Dev Container
# Использование: bash .devcontainer/validate.sh

set -e

echo "🔍 Проверка конфигурации Dev Container для Dream Team SaaS"
echo "=" * 60

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Функции для вывода
success() { echo -e "${GREEN}✅ $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; }
warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
info() { echo -e "${BLUE}ℹ️  $1${NC}"; }

# Счетчики
ERRORS=0
WARNINGS=0

# 1. Проверка существования файлов
echo -e "\n${BLUE}1. Проверка существования файлов${NC}"
echo "-----------------------------------"

check_file() {
    if [ -f "$1" ]; then
        success "Файл $1 существует"
    else
        error "Файл $1 не найден"
        ((ERRORS++))
    fi
}

check_file ".devcontainer/devcontainer.json"
check_file ".devcontainer/Dockerfile"
check_file "docker-compose.dev.yml"
check_file "Gemfile"
check_file "bin/setup"

# 2. Проверка синтаксиса JSON
echo -e "\n${BLUE}2. Проверка синтаксиса devcontainer.json${NC}"
echo "-------------------------------------------"

if command -v python3 &> /dev/null; then
    python3 -c "
import json
import re
import sys

try:
    with open('.devcontainer/devcontainer.json', 'r') as f:
        content = f.read()
    
    # Удаляем комментарии для проверки JSON
    content_no_comments = re.sub(r'//.*$', '', content, flags=re.MULTILINE)
    content_no_comments = re.sub(r'/\*.*?\*/', '', content_no_comments, flags=re.DOTALL)
    
    parsed = json.loads(content_no_comments)
    print('✅ JSON синтаксис корректен')
    
    # Проверяем обязательные поля
    required_fields = ['name', 'build', 'workspaceFolder']
    for field in required_fields:
        if field in parsed:
            print(f'✅ Поле \"{field}\" присутствует')
        else:
            print(f'❌ Отсутствует обязательное поле \"{field}\"')
            sys.exit(1)
            
except json.JSONDecodeError as e:
    print(f'❌ JSON ошибка: {e.msg} на строке {e.lineno}')
    sys.exit(1)
except Exception as e:
    print(f'❌ Ошибка: {e}')
    sys.exit(1)
" || ((ERRORS++))
else
    warning "Python3 не найден, пропускаем проверку JSON"
    ((WARNINGS++))
fi

# 3. Проверка Dockerfile
echo -e "\n${BLUE}3. Проверка Dockerfile${NC}"
echo "------------------------"

if [ -f ".devcontainer/Dockerfile" ]; then
    # Проверяем базовый образ
    if grep -q "FROM ruby:" ".devcontainer/Dockerfile"; then
        success "Базовый образ Ruby найден"
    else
        error "Базовый образ Ruby не найден"
        ((ERRORS++))
    fi
    
    # Проверяем пользователя vscode
    if grep -q "vscode" ".devcontainer/Dockerfile"; then
        success "Пользователь vscode настроен"
    else
        warning "Пользователь vscode не найден"
        ((WARNINGS++))
    fi
    
    # Проверяем рабочую директорию
    if grep -q "WORKDIR /workspace" ".devcontainer/Dockerfile"; then
        success "Рабочая директория настроена"
    else
        warning "Рабочая директория не настроена"
        ((WARNINGS++))
    fi
else
    error "Dockerfile не найден"
    ((ERRORS++))
fi

# 4. Проверка Docker Compose
echo -e "\n${BLUE}4. Проверка docker-compose.dev.yml${NC}"
echo "------------------------------------"

if [ -f "docker-compose.dev.yml" ]; then
    # Проверяем сервис базы данных
    if grep -q "db:" "docker-compose.dev.yml"; then
        success "Сервис базы данных найден"
    else
        error "Сервис базы данных не найден"
        ((ERRORS++))
    fi
    
    # Проверяем PostgreSQL
    if grep -q "postgres:" "docker-compose.dev.yml"; then
        success "PostgreSQL образ найден"
    else
        error "PostgreSQL образ не найден"
        ((ERRORS++))
    fi
    
    # Проверяем volumes
    if grep -q "volumes:" "docker-compose.dev.yml"; then
        success "Volumes настроены"
    else
        warning "Volumes не настроены"
        ((WARNINGS++))
    fi
else
    error "docker-compose.dev.yml не найден"
    ((ERRORS++))
fi

# 5. Проверка зависимостей Ruby
echo -e "\n${BLUE}5. Проверка Ruby зависимостей${NC}"
echo "-------------------------------"

if [ -f "Gemfile" ]; then
    # Проверяем Rails
    if grep -q "rails" "Gemfile"; then
        success "Rails найден в Gemfile"
    else
        error "Rails не найден в Gemfile"
        ((ERRORS++))
    fi
    
    # Проверяем PostgreSQL gem
    if grep -q "pg" "Gemfile"; then
        success "PostgreSQL gem найден"
    else
        error "PostgreSQL gem не найден"
        ((ERRORS++))
    fi
    
    # Проверяем Tailwind CSS
    if grep -q "tailwindcss-rails" "Gemfile"; then
        success "Tailwind CSS Rails найден"
    else
        warning "Tailwind CSS Rails не найден"
        ((WARNINGS++))
    fi
else
    error "Gemfile не найден"
    ((ERRORS++))
fi

# 6. Проверка скрипта настройки
echo -e "\n${BLUE}6. Проверка bin/setup${NC}"
echo "----------------------"

if [ -f "bin/setup" ]; then
    if [ -x "bin/setup" ]; then
        success "bin/setup исполняемый"
    else
        warning "bin/setup не исполняемый (chmod +x bin/setup)"
        ((WARNINGS++))
    fi
    
    # Проверяем содержимое
    if grep -q "bundle install" "bin/setup"; then
        success "Установка гемов настроена"
    else
        warning "Установка гемов не найдена в bin/setup"
        ((WARNINGS++))
    fi
else
    error "bin/setup не найден"
    ((ERRORS++))
fi

# 7. Проверка переменных окружения
echo -e "\n${BLUE}7. Проверка переменных окружения${NC}"
echo "-----------------------------------"

if [ -f ".env.template" ]; then
    success ".env.template найден"
    
    # Проверяем основные переменные
    if grep -q "DATABASE_URL" ".env.template"; then
        success "DATABASE_URL в шаблоне"
    else
        warning "DATABASE_URL не найден в .env.template"
        ((WARNINGS++))
    fi
else
    warning ".env.template не найден"
    ((WARNINGS++))
fi

if [ -f ".env.local" ]; then
    info ".env.local существует (не забудьте добавить в .gitignore)"
else
    info ".env.local не найден (будет создан при первом запуске)"
fi

# 8. Проверка .gitignore
echo -e "\n${BLUE}8. Проверка .gitignore${NC}"
echo "----------------------"

if [ -f ".gitignore" ]; then
    if grep -q ".env.local" ".gitignore"; then
        success ".env.local в .gitignore"
    else
        warning ".env.local не в .gitignore (добавьте для безопасности)"
        ((WARNINGS++))
    fi
    
    if grep -q "node_modules" ".gitignore"; then
        success "node_modules в .gitignore"
    else
        warning "node_modules не в .gitignore"
        ((WARNINGS++))
    fi
else
    warning ".gitignore не найден"
    ((WARNINGS++))
fi

# Итоговый отчет
echo -e "\n${BLUE}📊 Итоговый отчет${NC}"
echo "=================="

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    success "Конфигурация Dev Container полностью корректна! 🎉"
elif [ $ERRORS -eq 0 ]; then
    warning "Конфигурация корректна с $WARNINGS предупреждениями"
    echo -e "\n${YELLOW}💡 Рекомендации:${NC}"
    echo "- Исправьте предупреждения для лучшего опыта разработки"
else
    error "Найдено $ERRORS ошибок и $WARNINGS предупреждений"
    echo -e "\n${RED}🚨 Необходимо исправить ошибки перед использованием Dev Container${NC}"
    exit 1
fi

echo -e "\n${GREEN}🚀 Готово! Теперь можно запускать Dev Container${NC}"
echo "Команды для запуска:"
echo "1. Откройте VS Code: code ."
echo "2. Ctrl+Shift+P -> 'Dev Containers: Reopen in Container'"
echo "3. Дождитесь сборки и запуска bin/setup"
