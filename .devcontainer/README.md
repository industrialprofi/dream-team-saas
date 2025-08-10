# Dev Container для Dream Team SaaS

Этот Dev Container настроен для разработки Rails 8 приложения с использованием современного стека технологий.

## Включенные технологии

### Основной стек
- **Ruby 3.3.8** - актуальная стабильная версия
- **Rails 8.0.2** - последняя версия с новыми фичами (Solid Queue, Solid Cache, Solid Cable)
- **PostgreSQL 16** - современная база данных
- **Node.js 20 LTS** - для фронтенд инструментов
- **Yarn 1.22+** - менеджер пакетов

### Фронтенд
- **Hotwire** (Turbo + Stimulus) - для SPA-like интерфейса
- **Tailwind CSS Rails** - встроенная интеграция с Rails
- **Propshaft** - современный asset pipeline

### Инструменты разработки
- **RuboCop Rails Omakase** - линтер и форматтер
- **Brakeman** - анализ безопасности
- **Capybara + Selenium** - системное тестирование

## Быстрый старт

1. Откройте проект в VS Code
2. Нажмите `Ctrl+Shift+P` и выберите "Dev Containers: Reopen in Container"
3. Дождитесь сборки контейнера и выполнения `bin/setup`
4. Приложение автоматически запустится на порту 3000

## Доступные порты

- **3000** - Rails сервер
- **5432** - PostgreSQL база данных

## Полезные команды

```bash
# Запуск Rails сервера
bin/dev

# Запуск консоли Rails
bin/rails console

# Запуск тестов
bin/rails test

# Проверка стиля кода
bundle exec rubocop

# Анализ безопасности
bundle exec brakeman

# Сброс базы данных
bin/rails db:reset
```

## Расширения VS Code

Автоматически устанавливаются:
- **Ruby** - подсветка синтаксиса и отладка
- **Solargraph** - автодополнение и навигация
- **RuboCop** - линтинг и форматирование
- **GitLens** - расширенная работа с Git
- **Tailwind CSS IntelliSense** - автодополнение классов
- **PostgreSQL** - работа с базой данных

## Структура файлов

```
.devcontainer/
├── Dockerfile              # Образ контейнера
├── devcontainer.json       # Конфигурация VS Code
└── README.md              # Эта документация

docker-compose.dev.yml      # PostgreSQL
bin/setup                   # Скрипт инициализации
```

## Troubleshooting

### База данных не подключается
```bash
# Проверьте статус PostgreSQL
docker-compose -f docker-compose.dev.yml ps

# Перезапустите базу данных
docker-compose -f docker-compose.dev.yml restart db
```

### Проблемы с гемами
```bash
# Переустановите зависимости
bundle install --redownload

# Очистите кэш Bundler
bundle clean --force
```

### Проблемы с Tailwind CSS
```bash
# Пересоберите CSS
bin/rails tailwindcss:build

# Запустите в watch режиме
bin/rails tailwindcss:watch
```
