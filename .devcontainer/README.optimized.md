# 🚀 Dev Container для Dream Team SaaS - Профессиональная конфигурация

Оптимизированный Dev Container для Rails 8 приложения с акцентом на производительность, безопасность и удобство команды разработчиков.

## 📋 Профессиональные рекомендации по улучшению

### 1. 🚀 **Производительность и скорость разработки**

**✅ Реализованные улучшения:**
- **Многоэтапная сборка Docker** - оптимизация кэширования слоев
- **Именованные volumes** - лучшая производительность на всех ОС
- **Volume consistency** - `cached` для macOS, оптимальная синхронизация
- **Кэширование зависимостей** - отдельные volumes для bundle, node_modules, yarn
- **Исключение временных файлов** - tmp, log, .git не синхронизируются

**📁 Файлы:**
- `.devcontainer/Dockerfile.optimized` - многоэтапная сборка
- `docker-compose.dev.optimized.yml` - оптимизированные volumes

### 2. 🔒 **Безопасность**

**✅ Реализованные улучшения:**
- **Шаблон переменных окружения** - `.env.template` без секретов
- **Локальные переменные** - `.env.local` в .gitignore
- **Правильные права доступа** - пользователь vscode (UID 1000)
- **Исключение секретов** - расширенный .gitignore

**📁 Файлы:**
- `.env.template` - шаблон без секретов
- `.gitignore.devcontainer` - исключения для Dev Container

### 3. 🖥️ **Кроссплатформенная совместимость**

**✅ Реализованные улучшения:**
- **Volume consistency** - оптимизация для Windows/macOS/Linux
- **Правильные mounts** - Git config, SSH keys, bash history
- **Системные требования** - минимум 4GB RAM, 32GB storage
- **Обновленные расширения VS Code** - совместимые ID

**📁 Файлы:**
- `.devcontainer/devcontainer.optimized.json` - кроссплатформенные настройки

### 4. ⚡ **Автоматизация и удобство**

**✅ Реализованные улучшения:**
- **Улучшенный bin/setup** - проверки, логирование, обработка ошибок
- **Жизненный цикл контейнера** - postCreate, postStart, postAttach команды
- **Отдельный worker** - для фоновых задач Solid Queue
- **Healthchecks** - проверка готовности сервисов

**📁 Файлы:**
- `bin/setup.optimized` - профессиональный скрипт настройки

## 🛠️ Технологический стек

### Основные технологии
- **Ruby 3.3.8** - актуальная стабильная версия
- **Rails 8.0.2** - с Solid Queue/Cache/Cable
- **PostgreSQL 16** - современная база данных
- **Node.js 20 LTS** - для фронтенд инструментов
- **Yarn 1.22+** - менеджер пакетов

### Фронтенд
- **Hotwire** (Turbo + Stimulus) - SPA-like интерфейс
- **Tailwind CSS Rails** - встроенная интеграция
- **Propshaft** - современный asset pipeline

### Инструменты разработки
- **Ruby LSP** - современный language server
- **Solargraph** - резервный LSP
- **RuboCop Rails Omakase** - линтер
- **Brakeman** - анализ безопасности

## 🚀 Быстрый старт

### Первоначальная настройка

1. **Клонируйте репозиторий:**
   ```bash
   git clone <repository-url>
   cd dream-team-saas
   ```

2. **Настройте переменные окружения:**
   ```bash
   cp .env.template .env.local
   # Отредактируйте .env.local под ваши нужды
   ```

3. **Откройте в VS Code:**
   ```bash
   code .
   ```

4. **Запустите Dev Container:**
   - `Ctrl+Shift+P` → "Dev Containers: Reopen in Container"
   - Или используйте оптимизированную версию: переименуйте `devcontainer.optimized.json` в `devcontainer.json`

### Использование оптимизированной конфигурации

```bash
# Переключение на оптимизированные файлы
mv .devcontainer/devcontainer.json .devcontainer/devcontainer.original.json
mv .devcontainer/devcontainer.optimized.json .devcontainer/devcontainer.json

mv .devcontainer/Dockerfile .devcontainer/Dockerfile.original
mv .devcontainer/Dockerfile.optimized .devcontainer/Dockerfile

mv docker-compose.dev.yml docker-compose.dev.original.yml
mv docker-compose.dev.optimized.yml docker-compose.dev.yml

mv bin/setup bin/setup.original
mv bin/setup.optimized bin/setup
chmod +x bin/setup
```

## 📊 Доступные сервисы

### Основные порты
- **3000** - Rails сервер
- **5432** - PostgreSQL база данных

### Дополнительные сервисы
- **Worker** - Solid Queue фоновые задачи (профиль `worker`)

## 🔧 Полезные команды

### Разработка
```bash
# Запуск сервера разработки
bin/dev

# Запуск с воркером фоновых задач
docker-compose --profile worker up

# Rails консоль
bin/rails console

# Запуск тестов
bin/rails test
```

### Управление зависимостями
```bash
# Обновление гемов
bundle update

# Установка новых гемов
bundle add gem_name

# Проверка безопасности
bundle audit
```

### База данных
```bash
# Сброс базы данных
bin/rails db:reset

# Создание миграции
bin/rails generate migration MigrationName

# Откат миграции
bin/rails db:rollback
```

### Качество кода
```bash
# Проверка стиля кода
bundle exec rubocop

# Автоисправление
bundle exec rubocop -A

# Анализ безопасности
bundle exec brakeman
```

## 🎯 Расширения VS Code

### Автоматически устанавливаемые:

**Ruby и Rails:**
- **Shopify Ruby LSP** - современный language server
- **Solargraph** - автодополнение и навигация
- **RuboCop** - линтинг и форматирование
- **Rails DB Schema** - навигация по схеме БД

**Фронтенд:**
- **Tailwind CSS IntelliSense** - автодополнение классов
- **Auto Rename Tag** - синхронное переименование тегов

**Инструменты:**
- **GitLens** - расширенная работа с Git
- **GitHub Pull Requests** - работа с PR
- **PostgreSQL** - работа с базой данных
- **Docker** - управление контейнерами

## 🏗️ Архитектура проекта

### Структура Dev Container
```
.devcontainer/
├── Dockerfile.optimized         # Многоэтапная сборка
├── devcontainer.optimized.json  # Оптимизированная конфигурация VS Code
└── README.optimized.md          # Эта документация

docker-compose.dev.optimized.yml # PostgreSQL + Worker
.env.template                    # Шаблон переменных окружения
.gitignore.devcontainer         # Исключения для Dev Container
bin/setup.optimized             # Профессиональный скрипт настройки
```

## 🔄 Фоновые задачи (Solid Queue)

### Запуск воркера отдельно
```bash
# Запуск основного приложения + воркера
docker-compose --profile worker up

# Только воркер
docker-compose run --rm worker
```

### Мониторинг задач
```bash
# Rails консоль
bin/rails console

# Проверка очереди
SolidQueue::Job.count
SolidQueue::Job.pending.count
```

## 🗄️ База данных PostgreSQL

### Оптимизации для разработки
- **Именованные volumes** - данные сохраняются между перезапусками
- **Healthchecks** - автоматическая проверка готовности
- **Ограничения ресурсов** - стабильная работа
- **Инициализация** - автоматические скрипты в `tmp/db_init/`

### Подключение к БД
```bash
# Через psql в контейнере
docker-compose exec db psql -U postgres -d dream_team_saas_development

# Через VS Code расширение PostgreSQL
# Host: localhost, Port: 5432, User: postgres, Password: postgres
```

## 🚨 Troubleshooting

### База данных не подключается
```bash
# Проверка статуса
docker-compose ps

# Логи PostgreSQL
docker-compose logs db

# Перезапуск БД
docker-compose restart db
```

### Проблемы с правами доступа
```bash
# Исправление прав (в контейнере)
sudo chown -R vscode:vscode /workspace

# Очистка volumes
docker-compose down -v
docker-compose up
```

### Медленная синхронизация файлов
```bash
# Для macOS - используйте :cached
# Для Windows - включите WSL 2
# Проверьте настройки Docker Desktop
```

### Проблемы с гемами
```bash
# Переустановка bundle
bundle clean --force
bundle install

# Очистка кэша
rm -rf vendor/bundle
bundle install
```

## 👥 Работа в команде

### Для новых разработчиков

1. **Установите Docker Desktop** и VS Code
2. **Клонируйте репозиторий** и откройте в VS Code
3. **Скопируйте .env.template в .env.local** и настройте
4. **Откройте в Dev Container** - всё настроится автоматически
5. **Запустите bin/dev** - приложение готово!

### Синхронизация настроек команды
- Общие настройки VS Code в `devcontainer.json`
- Переменные окружения в `.env.template`
- Зависимости в `Gemfile` и `package.json`
- Настройки линтеров в `.rubocop.yml`

## 📚 Дополнительные ресурсы

- [VS Code Dev Containers](https://code.visualstudio.com/docs/remote/containers)
- [Docker Compose](https://docs.docker.com/compose/)
- [Rails 8 Guides](https://guides.rubyonrails.org/)
- [Solid Queue](https://github.com/rails/solid_queue)
- [Tailwind CSS](https://tailwindcss.com/)

---

**💡 Совет:** Регулярно обновляйте образы Docker и зависимости для получения последних исправлений безопасности и улучшений производительности.
про