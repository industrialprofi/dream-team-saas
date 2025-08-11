require 'rails_helper'

RSpec.describe Llm::Client do
  let(:client) { described_class.new }
  let(:prompt) { 'Напиши эссе о важности образования' }

  describe '#generate_text' do
    context 'когда OpenAI API недоступен' do
      before do
        allow(ENV).to receive(:fetch).with('OPENAI_API_KEY', nil).and_return(nil)
      end

      it 'возвращает мок-ответ' do
        result = client.generate_text(prompt)
        
        expect(result[:success]).to be true
        expect(result[:text]).to include('Образование играет ключевую роль')
        expect(result[:tokens_used]).to be > 0
      end

      it 'возвращает разные ответы для разных промптов' do
        result1 = client.generate_text('Тема 1')
        result2 = client.generate_text('Тема 2')
        
        expect(result1[:text]).not_to eq(result2[:text])
      end
    end

    context 'когда OpenAI API доступен' do
      let(:mock_response) do
        {
          'choices' => [
            {
              'message' => {
                'content' => 'Сгенерированный текст от OpenAI'
              }
            }
          ],
          'usage' => {
            'total_tokens' => 150
          }
        }
      end

      before do
        allow(ENV).to receive(:fetch).with('OPENAI_API_KEY', nil).and_return('test-api-key')
        allow(client).to receive(:make_openai_request).and_return(mock_response)
      end

      it 'возвращает ответ от OpenAI' do
        result = client.generate_text(prompt)
        
        expect(result[:success]).to be true
        expect(result[:text]).to eq('Сгенерированный текст от OpenAI')
        expect(result[:tokens_used]).to eq(150)
      end
    end

    context 'при ошибке API' do
      before do
        allow(ENV).to receive(:fetch).with('OPENAI_API_KEY', nil).and_return('test-api-key')
        allow(client).to receive(:make_openai_request).and_raise(StandardError.new('API Error'))
      end

      it 'возвращает ошибку' do
        result = client.generate_text(prompt)
        
        expect(result[:success]).to be false
        expect(result[:error]).to include('API Error')
      end
    end
  end

  describe '#available?' do
    it 'возвращает true когда API ключ установлен' do
      allow(ENV).to receive(:fetch).with('OPENAI_API_KEY', nil).and_return('test-key')
      expect(client.available?).to be true
    end

    it 'возвращает false когда API ключ не установлен' do
      allow(ENV).to receive(:fetch).with('OPENAI_API_KEY', nil).and_return(nil)
      expect(client.available?).to be false
    end
  end

  describe 'private methods' do
    describe '#generate_mock_response' do
      it 'генерирует осмысленный мок-ответ' do
        mock_response = client.send(:generate_mock_response, prompt)
        
        expect(mock_response).to be_a(String)
        expect(mock_response.length).to be > 100
        expect(mock_response).to include('образовани')
      end

      it 'генерирует разные ответы для разных промптов' do
        response1 = client.send(:generate_mock_response, 'Тема 1')
        response2 = client.send(:generate_mock_response, 'Тема 2')
        
        expect(response1).not_to eq(response2)
      end
    end

    describe '#calculate_mock_tokens' do
      it 'рассчитывает количество токенов на основе длины текста' do
        text = 'Короткий текст'
        tokens = client.send(:calculate_mock_tokens, text)
        
        expect(tokens).to be > 0
        expect(tokens).to be < 100
      end

      it 'возвращает больше токенов для длинного текста' do
        short_text = 'Короткий'
        long_text = 'Очень длинный текст с множеством слов и предложений для тестирования'
        
        short_tokens = client.send(:calculate_mock_tokens, short_text)
        long_tokens = client.send(:calculate_mock_tokens, long_text)
        
        expect(long_tokens).to be > short_tokens
      end
    end
  end
end
