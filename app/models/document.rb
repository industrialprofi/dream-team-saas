class Document < ApplicationRecord
  # Ассоциации
  belongs_to :user
  has_many :request_logs, dependent: :destroy

  # Enum для статуса документа
  enum :status, {
    draft: 0,        # черновик
    processing: 1,   # обрабатывается
    completed: 2     # завершен
  }

  # Валидации
  validates :title, presence: true, length: { minimum: 1, maximum: 255 }
  validates :content, length: { maximum: 50_000 }
  validates :status, presence: true

  # Скоупы
  scope :recent, -> { order(updated_at: :desc) }
  scope :by_user, ->(user) { where(user: user) }

  # Методы
  def word_count
    content.to_s.split.size
  end

  def can_generate?
    draft? || completed?
  end

  def processing?
    status == 'processing'
  end
end
