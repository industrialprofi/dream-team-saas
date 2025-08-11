# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "🌱 Seeding database..."

# Создание тестовых пользователей
puts "Creating users..."

admin_user = User.find_or_create_by!(email: "admin@dreamteam.com") do |user|
  user.name = "Admin User"
  user.password = "password123"
  user.password_confirmation = "password123"
end

demo_user = User.find_or_create_by!(email: "demo@dreamteam.com") do |user|
  user.name = "Demo User"
  user.password = "password123"
  user.password_confirmation = "password123"
end

test_user = User.find_or_create_by!(email: "test@dreamteam.com") do |user|
  user.name = "Test User"
  user.password = "password123"
  user.password_confirmation = "password123"
end

# OAuth пользователь (имитация Google OAuth)
oauth_user = User.find_or_create_by!(email: "oauth@gmail.com") do |user|
  user.name = "OAuth User"
  user.provider = "google_oauth2"
  user.uid = "123456789"
  user.password = Devise.friendly_token[0, 20]
end

puts "✅ Created #{User.count} users"

# Создание тестовых документов
puts "Creating documents..."

# Документы для admin_user
admin_docs = [
  {
    title: "Бизнес-план SaaS платформы",
    content: "Это подробный бизнес-план для нашей SaaS платформы Dream Team. Включает анализ рынка, конкурентов, финансовые прогнозы и стратегию развития.",
    status: :completed
  },
  {
    title: "Техническая документация API",
    content: "Документация REST API для интеграции с внешними системами. Описание эндпоинтов, форматов данных и примеров использования.",
    status: :completed
  },
  {
    title: "Маркетинговая стратегия",
    content: "Стратегия продвижения продукта на рынке. Целевая аудитория, каналы привлечения, бюджет и KPI.",
    status: :processing
  }
]

admin_docs.each do |doc_attrs|
  Document.find_or_create_by!(
    title: doc_attrs[:title],
    user: admin_user
  ) do |doc|
    doc.content = doc_attrs[:content]
    doc.status = doc_attrs[:status]
  end
end

# Документы для demo_user
demo_docs = [
  {
    title: "Презентация для инвесторов",
    content: "Питч-дек для привлечения инвестиций. Проблема, решение, рынок, команда, финансы.",
    status: :completed
  },
  {
    title: "Руководство пользователя",
    content: "Подробное руководство по использованию платформы для новых пользователей.",
    status: :draft
  },
  {
    title: "Отчет по продажам Q1",
    content: "",
    status: :draft
  }
]

demo_docs.each do |doc_attrs|
  Document.find_or_create_by!(
    title: doc_attrs[:title],
    user: demo_user
  ) do |doc|
    doc.content = doc_attrs[:content]
    doc.status = doc_attrs[:status]
  end
end

# Документы для test_user
test_docs = [
  {
    title: "Тестовый документ 1",
    content: "Это тестовый документ для проверки функционала системы.",
    status: :completed
  },
  {
    title: "Черновик статьи",
    content: "Начало статьи о современных технологиях разработки SaaS приложений.",
    status: :draft
  }
]

test_docs.each do |doc_attrs|
  Document.find_or_create_by!(
    title: doc_attrs[:title],
    user: test_user
  ) do |doc|
    doc.content = doc_attrs[:content]
    doc.status = doc_attrs[:status]
  end
end

# Документ для OAuth пользователя
Document.find_or_create_by!(
  title: "Заметки из Google Docs",
  user: oauth_user
) do |doc|
  doc.content = "Заметки, синхронизированные из Google Docs через OAuth интеграцию."
  doc.status = :completed
end

puts "✅ Created #{Document.count} documents"

# Создание логов запросов
puts "Creating request logs..."

# Логи для завершенных документов
Document.completed.each do |document|
  # Создаем несколько логов для каждого документа
  [
    {
      prompt: "Улучши структуру этого документа",
      response: "Я проанализировал документ и предлагаю следующие улучшения структуры...",
      tokens_used: 150
    },
    {
      prompt: "Добавь заключение к документу",
      response: "Вот предлагаемое заключение для вашего документа...",
      tokens_used: 200
    },
    {
      prompt: "Проверь грамматику и стиль",
      response: "Я проверил текст и нашел несколько моментов для улучшения...",
      tokens_used: 120
    }
  ].each do |log_attrs|
    RequestLog.find_or_create_by!(
      user: document.user,
      document: document,
      prompt: log_attrs[:prompt]
    ) do |log|
      log.response = log_attrs[:response]
      log.tokens_used = log_attrs[:tokens_used]
    end
  end
end

puts "✅ Created #{RequestLog.count} request logs"

# Итоговая статистика
puts "\n📊 Seeding completed!"
puts "Users: #{User.count}"
puts "Documents: #{Document.count}"
puts "  - Draft: #{Document.draft.count}"
puts "  - Processing: #{Document.processing.count}"
puts "  - Completed: #{Document.completed.count}"
puts "Request Logs: #{RequestLog.count}"
puts "\n🔑 Test accounts:"
puts "  admin@dreamteam.com / password123"
puts "  demo@dreamteam.com / password123"
puts "  test@dreamteam.com / password123"
puts "  oauth@gmail.com (OAuth user)"
