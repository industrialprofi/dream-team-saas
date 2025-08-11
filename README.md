# Dream Team SaaS - AI Essay Generator

Минимальный MVP веб-приложения для генерации эссе с помощью ИИ, созданный на Rails 8 с использованием современного стека технологий.

## Технологии

- **Backend**: Ruby 3.3.8, Rails 8.0.2
- **Frontend**: Hotwire (Turbo + Stimulus), Tailwind CSS v4, Flowbite UI
- **Database**: PostgreSQL 16.9
- **Background Jobs**: GoodJob
- **Authentication**: Devise + Google OAuth2
- **Testing**: RSpec, FactoryBot, Faker
- **Deployment**: Kamal 2
- **Development**: Dev Container, Docker Compose

## Функциональность

- ✅ Регистрация и аутентификация пользователей (email/password + Google OAuth)
- ✅ CRUD операции с документами
- ✅ AI генерация текста через OpenAI API (с мок-режимом для разработки)
- ✅ Автосохранение документов в реальном времени
- ✅ Фоновая обработка задач генерации текста
- ✅ Логирование запросов к AI с подсчётом токенов
- ✅ Responsive UI с Tailwind CSS и Flowbite компонентами
- ✅ Мониторинг очередей задач через GoodJob Web UI

## Запуск в Dev Container

### Предварительные требования
- VS Code с расширением Dev Containers
- Docker и Docker Compose

### Запуск
1. Клонируйте репозиторий
2. Откройте проект в VS Code
3. Нажмите F1 и выберите: `Dev Containers: Rebuild and Reopen in Container`
4. Дождитесь сборки контейнера (первый запуск может занять несколько минут)
5. В терминале контейнера выполните:
   ```bash
   bin/setup
   ```
6. Запустите приложение:
   ```bash
   bin/dev
   ```

### Доступ к сервисам
- **Приложение**: http://localhost:3000
- **GoodJob Web UI**: http://localhost:3000/admin/good_job
- **PostgreSQL**: localhost:5433 (из хост-системы)

## Переменные окружения

Создайте файл `.env.development.local` с необходимыми переменными:

```bash
# OpenAI API (опционально, без него работает мок-режим)
OPENAI_API_KEY=your_openai_api_key

# Google OAuth (опционально)
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret

# GoodJob Dashboard (для production)
GOOD_JOB_DASHBOARD_USER=admin
GOOD_JOB_DASHBOARD_PASSWORD=secure_password
```

## Тестирование

Запуск всех тестов:
```bash
bundle exec rspec
```

Запуск конкретной группы тестов:
```bash
# Тесты моделей
bundle exec rspec spec/models/

# Тесты контроллеров
bundle exec rspec spec/controllers/

# Тесты сервисов
bundle exec rspec spec/services/

# Тесты фоновых задач
bundle exec rspec spec/jobs/
```

## Архитектура

### Модели
- **User**: Пользователи с поддержкой Devise и OAuth
- **Document**: Документы с статусами (draft, processing, completed)
- **RequestLog**: Логи запросов к AI с подсчётом токенов и стоимости

### Сервисы
- **Llm::Client**: Клиент для работы с OpenAI API (с мок-режимом)

### Фоновые задачи
- **GenerateTextJob**: Асинхронная генерация текста через AI

### Frontend
- Hotwire для SPA-подобного опыта без сложного JS
- Stimulus контроллеры для интерактивности (автосохранение)
- Turbo Streams для обновлений в реальном времени
- Tailwind CSS + Flowbite для современного UI

## Деплой с Kamal 2

### Подготовка
1. Установите Kamal 2:
   ```bash
   gem install kamal
   ```

2. Настройте `config/deploy.yml`:
   ```yaml
   service: dream-team-saas
   image: your-registry/dream-team-saas
   
   servers:
     web:
       hosts:
         - your-server-ip
       options:
         add-host: host.docker.internal:host-gateway
     worker:
       hosts:
         - your-server-ip
       cmd: bundle exec good_job start
   
   registry:
     server: your-registry.com
     username: your-username
     password:
       - REGISTRY_PASSWORD
   
   env:
     clear:
       RAILS_ENV: production
       RAILS_MASTER_KEY: your-master-key
     secret:
       - OPENAI_API_KEY
       - GOOGLE_CLIENT_ID
       - GOOGLE_CLIENT_SECRET
       - GOOD_JOB_DASHBOARD_USER
       - GOOD_JOB_DASHBOARD_PASSWORD
   
   accessories:
     db:
       image: postgres:16
       host: your-server-ip
       env:
         POSTGRES_DB: dream_team_saas_production
         POSTGRES_USER: dream_team_saas
         POSTGRES_PASSWORD:
           - DB_PASSWORD
       directories:
         - data:/var/lib/postgresql/data
   ```

3. Настройте секреты:
   ```bash
   kamal env push
   ```

### Деплой
```bash
# Первый деплой
kamal setup

# Последующие деплои
kamal deploy

# Перезапуск worker'ов после изменений в задачах
kamal app exec --roles=worker 'bundle exec good_job restart'
```

### Мониторинг
```bash
# Логи приложения
kamal app logs

# Логи worker'ов
kamal app logs --roles=worker

# Статус сервисов
kamal app details
```

## Разработка

### Добавление новых фич
1. Создайте миграцию при необходимости
2. Добавьте/обновите модели с валидациями
3. Создайте/обновите контроллеры
4. Добавьте views с Hotwire интеграцией
5. Напишите тесты для всех компонентов
6. Обновите документацию

### Стиль кода
- Следуйте Ruby Style Guide
- Используйте RuboCop для проверки стиля
- Пишите тесты для всех новых функций
- Комментарии и интерфейс только на русском языке
- Код и переменные на английском

### Полезные команды
```bash
# Консоль Rails
bin/rails console

# Генерация миграций
bin/rails generate migration AddFieldToModel field:type

# Запуск миграций
bin/rails db:migrate

# Сброс БД (только для разработки)
bin/rails db:reset

# Проверка стиля кода
bundle exec rubocop

# Автоисправление стиля
bundle exec rubocop -a
```

## Лицензия

MIT License
