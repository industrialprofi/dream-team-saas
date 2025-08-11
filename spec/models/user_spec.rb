require 'rails_helper'

RSpec.describe User, type: :model do
  # Тестирование валидаций
  describe 'validations' do
    it 'требует наличие имени' do
      user = build(:user, name: nil)
      expect(user).not_to be_valid
      expect(user.errors[:name]).to include("can't be blank")
    end

    it 'требует наличие email' do
      user = build(:user, email: nil)
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("can't be blank")
    end

    it 'требует уникальность email' do
      existing_user = create(:user)
      user = build(:user, email: existing_user.email)
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include('has already been taken')
    end

    it 'требует provider и uid для OAuth пользователей' do
      user = build(:user, provider: 'google_oauth2', uid: nil)
      expect(user).not_to be_valid
      expect(user.errors[:uid]).to include("can't be blank")
    end
  end

  # Тестирование ассоциаций
  describe 'associations' do
    it 'имеет много документов' do
      association = User.reflect_on_association(:documents)
      expect(association.macro).to eq(:has_many)
      expect(association.options[:dependent]).to eq(:destroy)
    end

    it 'имеет много логов запросов' do
      association = User.reflect_on_association(:request_logs)
      expect(association.macro).to eq(:has_many)
      expect(association.options[:dependent]).to eq(:destroy)
    end
  end

  # Тестирование методов
  describe 'methods' do
    let(:user) { create(:user) }

    describe '#oauth_user?' do
      it 'возвращает true для OAuth пользователя' do
        oauth_user = create(:user, :oauth_user)
        expect(oauth_user.oauth_user?).to be true
      end

      it 'возвращает false для обычного пользователя' do
        expect(user.oauth_user?).to be false
      end
    end

    describe '#display_name' do
      it 'возвращает имя если оно есть' do
        expect(user.display_name).to eq(user.name)
      end

      it 'возвращает часть email если имени нет' do
        user_without_name = create(:user, name: nil)
        email_prefix = user_without_name.email.split('@').first
        expect(user_without_name.display_name).to eq(email_prefix)
      end
    end

    describe '.from_omniauth' do
      let(:auth) do
        double('auth', 
          info: double('info', email: 'oauth@example.com', name: 'OAuth User'),
          provider: 'google_oauth2',
          uid: '12345'
        )
      end

      it 'создаёт нового пользователя из OAuth данных' do
        expect {
          User.from_omniauth(auth)
        }.to change(User, :count).by(1)

        user = User.last
        expect(user.email).to eq('oauth@example.com')
        expect(user.name).to eq('OAuth User')
        expect(user.provider).to eq('google_oauth2')
        expect(user.uid).to eq('12345')
      end

      it 'находит существующего пользователя по email' do
        existing_user = create(:user, email: 'oauth@example.com')

        expect {
          User.from_omniauth(auth)
        }.not_to change(User, :count)

        user = User.from_omniauth(auth)
        expect(user.id).to eq(existing_user.id)
      end
    end
  end
end
