# frozen_string_literal: true

Devise.setup do |config|
  # Секретный ключ для генерации токенов
  config.secret_key = Rails.application.credentials.secret_key_base

  # Настройки почты
  config.mailer_sender = 'noreply@dreamteam-saas.com'

  # ORM конфигурация
  require 'devise/orm/active_record'

  # Ключи аутентификации
  config.case_insensitive_keys = [:email]
  config.strip_whitespace_keys = [:email]

  # Настройки сессии
  config.skip_session_storage = [:http_auth]

  # Настройки паролей
  config.stretches = Rails.env.test? ? 1 : 12
  config.password_length = 6..128
  config.email_regexp = /\A[^@\s]+@[^@\s]+\z/

  # Настройки для восстановления пароля
  config.reset_password_within = 6.hours

  # Настройки для запоминания пользователя
  config.expire_all_remember_me_on_sign_out = true

  # Настройки для подтверждения email
  config.reconfirmable = true

  # Настройки навигации
  config.sign_out_via = :delete

  # Настройки для Hotwire/Turbo
  config.responder.error_status = :unprocessable_entity
  config.responder.redirect_status = :see_other

  # OmniAuth настройки для Google
  config.omniauth :google_oauth2, ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET'], {
    scope: 'userinfo.email,userinfo.profile',
    prompt: 'select_account',
    image_aspect_ratio: 'square',
    image_size: 50
  }
end
