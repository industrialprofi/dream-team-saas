# Используем официальный Ruby образ на базе Ubuntu
FROM ruby:3.3.8-slim

# Устанавливаем переменные окружения
ENV DEBIAN_FRONTEND=noninteractive
ENV RAILS_ENV=development
ENV BUNDLE_PATH=/usr/local/bundle
ENV PATH=$BUNDLE_PATH/bin:$PATH

# Обновляем систему и устанавливаем необходимые пакеты
RUN apt-get update -qq && apt-get install -yq --no-install-recommends \
    # Основные системные пакеты
    build-essential \
    curl \
    git \
    gnupg2 \
    # PostgreSQL клиент и библиотеки для разработки
    postgresql-client \
    libpq-dev \
    # Библиотеки для компиляции гемов
    libssl-dev \
    libreadline-dev \
    zlib1g-dev \
    libyaml-dev \
    libxml2-dev \
    libxslt-dev \
    # Инструменты для отладки и разработки
    vim \
    less \
    # Очистка кэша apt
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Устанавливаем Node.js 20 LTS через NodeSource
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

# Устанавливаем Yarn
RUN npm install -g yarn@1.22.22

# Создаем пользователя vscode для работы с VS Code Dev Containers
RUN groupadd --gid 1000 vscode \
    && useradd --uid 1000 --gid vscode --shell /bin/bash --create-home vscode \
    && mkdir -p /home/vscode/.vscode-server /home/vscode/.vscode-server-insiders \
    && chown -R vscode:vscode /home/vscode

# Устанавливаем рабочую директорию
WORKDIR /workspace

# Копируем и устанавливаем зависимости Ruby
COPY Gemfile Gemfile.lock ./
RUN bundle config --global frozen 1 \
    && bundle install --jobs 4 --retry 3

# Устанавливаем права доступа для пользователя vscode
RUN chown -R vscode:vscode /workspace /usr/local/bundle

# Переключаемся на пользователя vscode
USER vscode

# Экспонируем порт для Rails сервера
EXPOSE 3000

# Команда по умолчанию
CMD ["bash"]
