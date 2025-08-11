require 'rails_helper'

RSpec.describe RequestLog, type: :model do
  let(:user) { create(:user) }
  let(:document) { create(:document, user: user) }
  let(:request_log) { create(:request_log, user: user, document: document) }

  # Тестирование валидаций
  describe 'validations' do
    it 'требует наличие prompt' do
      log = build(:request_log, prompt: nil)
      expect(log).not_to be_valid
      expect(log.errors[:prompt]).to include("can't be blank")
    end

    it 'требует минимальную длину prompt' do
      log = build(:request_log, prompt: '')
      expect(log).not_to be_valid
      expect(log.errors[:prompt]).to include('is too short (minimum is 1 character)')
    end

    it 'ограничивает максимальную длину prompt' do
      log = build(:request_log, prompt: 'a' * 5_001)
      expect(log).not_to be_valid
      expect(log.errors[:prompt]).to include('is too long (maximum is 5000 characters)')
    end

    it 'ограничивает максимальную длину response' do
      log = build(:request_log, response: 'a' * 50_001)
      expect(log).not_to be_valid
      expect(log.errors[:response]).to include('is too long (maximum is 50000 characters)')
    end

    it 'требует положительное количество токенов' do
      log = build(:request_log, tokens_used: 0)
      expect(log).not_to be_valid
      expect(log.errors[:tokens_used]).to include('must be greater than 0')
    end

    it 'требует числовое значение tokens_used' do
      log = build(:request_log, tokens_used: 'abc')
      expect(log).not_to be_valid
      expect(log.errors[:tokens_used]).to include('is not a number')
    end
  end

  # Тестирование ассоциаций
  describe 'associations' do
    it 'принадлежит пользователю' do
      association = RequestLog.reflect_on_association(:user)
      expect(association.macro).to eq(:belongs_to)
    end

    it 'принадлежит документу' do
      association = RequestLog.reflect_on_association(:document)
      expect(association.macro).to eq(:belongs_to)
    end
  end

  # Тестирование методов
  describe 'methods' do
    describe '#cost_estimate' do
      it 'вычисляет примерную стоимость' do
        log = RequestLog.new(tokens_used: 1000)
        expect(log.cost_estimate).to eq(0.03)
      end

      it 'обрабатывает нулевое количество токенов' do
        log = RequestLog.new(tokens_used: 0)
        expect(log.cost_estimate).to eq(0.0)
      end

      it 'вычисляет стоимость для малого количества токенов' do
        log = RequestLog.new(tokens_used: 100)
        expect(log.cost_estimate).to eq(0.003)
      end
    end
  end

  # Тестирование скоупов
  describe 'scopes' do
    let!(:old_log) { create(:request_log, user: user, document: document, created_at: 2.days.ago) }
    let!(:new_log) { create(:request_log, user: user, document: document, created_at: 1.day.ago) }

    describe '.recent' do
      it 'возвращает логи в порядке создания' do
        expect(RequestLog.recent).to eq([new_log, old_log])
      end
    end

    describe '.by_user' do
      let(:other_user) { create(:user) }
      let(:other_document) { create(:document, user: other_user) }
      let!(:other_log) { create(:request_log, user: other_user, document: other_document) }

      it 'возвращает логи конкретного пользователя' do
        expect(RequestLog.by_user(user)).to include(old_log, new_log)
        expect(RequestLog.by_user(user)).not_to include(other_log)
      end
    end

    describe '.by_document' do
      let(:other_document) { create(:document, user: user) }
      let!(:other_log) { create(:request_log, user: user, document: other_document) }

      it 'возвращает логи конкретного документа' do
        expect(RequestLog.by_document(document)).to include(old_log, new_log)
        expect(RequestLog.by_document(document)).not_to include(other_log)
      end
    end
  end
end
