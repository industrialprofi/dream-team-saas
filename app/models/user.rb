class User < ApplicationRecord
  # Подключаем модули Devise включая OmniAuth
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :omniauthable,
         omniauth_providers: [:google_oauth2]

  # Ассоциации
  has_many :documents, dependent: :destroy
  has_many :request_logs, dependent: :destroy

  # Валидации
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :provider, :uid, presence: true, if: :oauth_user?

  # Методы для OAuth
  def self.from_omniauth(auth)
    where(email: auth.info.email).first_or_create do |user|
      user.email = auth.info.email
      user.name = auth.info.name
      user.provider = auth.provider
      user.uid = auth.uid
      user.password = Devise.friendly_token[0, 20]
    end
  end

  def oauth_user?
    provider.present? && uid.present?
  end

  def display_name
    name.presence || email.split('@').first
  end
end
