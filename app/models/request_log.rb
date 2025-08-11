class RequestLog < ApplicationRecord
  # Ассоциации
  belongs_to :user
  belongs_to :document

  # Валидации
  validates :prompt, presence: true, length: { minimum: 1, maximum: 5_000 }
  validates :response, length: { maximum: 50_000 }
  validates :tokens_used, presence: true, numericality: { greater_than: 0 }

  # Скоупы
  scope :recent, -> { order(created_at: :desc) }
  scope :by_user, ->(user) { where(user: user) }
  scope :by_document, ->(document) { where(document: document) }

  # Методы
  def cost_estimate
    # Примерная стоимость в долларах (OpenAI GPT-4)
    (tokens_used.to_f / 1000) * 0.03
  end
end
