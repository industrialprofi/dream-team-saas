require 'rails_helper'

RSpec.describe Document, type: :model do
  let(:user) { create(:user) }
  let(:document) { create(:document, user: user) }

  # Тестирование валидаций
  describe 'validations' do
    it 'требует наличие заголовка' do
      document = build(:document, title: nil)
      expect(document).not_to be_valid
      expect(document.errors[:title]).to include("can't be blank")
    end

    it 'требует минимальную длину заголовка' do
      document = build(:document, title: '')
      expect(document).not_to be_valid
      expect(document.errors[:title]).to include('is too short (minimum is 1 character)')
    end

    it 'ограничивает максимальную длину заголовка' do
      document = build(:document, title: 'a' * 256)
      expect(document).not_to be_valid
      expect(document.errors[:title]).to include('is too long (maximum is 255 characters)')
    end

    it 'ограничивает максимальную длину содержания' do
      document = build(:document, content: 'a' * 50_001)
      expect(document).not_to be_valid
      expect(document.errors[:content]).to include('is too long (maximum is 50000 characters)')
    end

    it 'требует наличие статуса' do
      document = build(:document, status: nil)
      expect(document).not_to be_valid
      expect(document.errors[:status]).to include("can't be blank")
    end
  end

  # Тестирование ассоциаций
  describe 'associations' do
    it 'принадлежит пользователю' do
      association = Document.reflect_on_association(:user)
      expect(association.macro).to eq(:belongs_to)
    end

    it 'имеет много логов запросов' do
      association = Document.reflect_on_association(:request_logs)
      expect(association.macro).to eq(:has_many)
      expect(association.options[:dependent]).to eq(:destroy)
    end
  end

  # Тестирование enum
  describe 'enums' do
    it 'имеет правильные статусы' do
      expect(Document.statuses).to eq({
        'draft' => 0,
        'processing' => 1,
        'completed' => 2
      })
    end

    it 'по умолчанию создаётся с статусом draft' do
      document = create(:document)
      expect(document.status).to eq('draft')
    end
  end

  # Тестирование методов
  describe 'methods' do
    describe '#word_count' do
      it 'подсчитывает количество слов' do
        document.update!(content: 'Привет мир это тест')
        expect(document.word_count).to eq(4)
      end

      it 'возвращает 0 для пустого содержания' do
        document.update!(content: nil)
        expect(document.word_count).to eq(0)
      end
    end

    describe '#can_generate?' do
      it 'возвращает true для черновика' do
        document.update!(status: :draft)
        expect(document.can_generate?).to be true
      end

      it 'возвращает true для завершённого документа' do
        document.update!(status: :completed)
        expect(document.can_generate?).to be true
      end

      it 'возвращает false для обрабатываемого документа' do
        document.update!(status: :processing)
        expect(document.can_generate?).to be false
      end
    end

    describe '#processing?' do
      it 'возвращает true для обрабатываемого документа' do
        document.update!(status: :processing)
        expect(document.processing?).to be true
      end

      it 'возвращает false для не обрабатываемого документа' do
        document.update!(status: :draft)
        expect(document.processing?).to be false
      end
    end
  end

  # Тестирование скоупов
  describe 'scopes' do
    let!(:old_document) { create(:document, user: user, updated_at: 2.days.ago) }
    let!(:new_document) { create(:document, user: user, updated_at: 1.day.ago) }

    describe '.recent' do
      it 'возвращает документы в порядке обновления' do
        expect(Document.recent).to eq([new_document, old_document])
      end
    end

    describe '.by_user' do
      let(:other_user) { create(:user) }
      let!(:other_document) { create(:document, user: other_user) }

      it 'возвращает документы конкретного пользователя' do
        expect(Document.by_user(user)).to include(old_document, new_document)
        expect(Document.by_user(user)).not_to include(other_document)
      end
    end
  end
end
