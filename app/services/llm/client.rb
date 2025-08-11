module Llm
  class Client
    include HTTParty
    base_uri 'https://api.openai.com/v1'

    def initialize(api_key = nil)
      @api_key = api_key || ENV['OPENAI_API_KEY']
      # В тестовой среде разрешаем работу без API ключа (используем моки)
      unless Rails.env.test?
        raise ArgumentError, 'OpenAI API key не найден' unless @api_key
      end
    end

    # Генерация текста на основе промпта
    def generate_text(prompt, max_tokens: 1000, temperature: 0.7)
      response = self.class.post('/chat/completions',
        headers: headers,
        body: {
          model: 'gpt-3.5-turbo',
          messages: [
            {
              role: 'system',
              content: 'Ты помощник для написания сочинений и эссе. Отвечай на русском языке.'
            },
            {
              role: 'user',
              content: prompt
            }
          ],
          max_tokens: max_tokens,
          temperature: temperature
        }.to_json
      )

      handle_response(response)
    end

    # Улучшение существующего текста
    def improve_text(content, instructions = nil)
      prompt = if instructions.present?
        "Улучши следующий текст согласно инструкциям: #{instructions}\n\nТекст:\n#{content}"
      else
        "Улучши следующий текст, сделай его более читаемым и структурированным:\n\n#{content}"
      end

      generate_text(prompt)
    end

    # Генерация сочинения по теме
    def generate_essay(topic, word_count: 500, essay_type: 'рассуждение')
      prompt = "Напиши сочинение-#{essay_type} на тему: \"#{topic}\". " \
               "Объём примерно #{word_count} слов. " \
               "Структура: введение, основная часть, заключение."

      generate_text(prompt, max_tokens: (word_count * 1.5).to_i)
    end

    private

    def headers
      {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{@api_key}"
      }
    end

    def handle_response(response)
      case response.code
      when 200
        content = response.dig('choices', 0, 'message', 'content')
        tokens = response.dig('usage', 'total_tokens')
        
        {
          success: true,
          content: content&.strip,
          tokens_used: tokens || 0,
          raw_response: response.parsed_response
        }
      when 401
        {
          success: false,
          error: 'Неверный API ключ OpenAI',
          error_code: 'unauthorized'
        }
      when 429
        {
          success: false,
          error: 'Превышен лимит запросов к OpenAI API',
          error_code: 'rate_limit'
        }
      when 500..599
        {
          success: false,
          error: 'Ошибка сервера OpenAI',
          error_code: 'server_error'
        }
      else
        {
          success: false,
          error: "Неизвестная ошибка: #{response.code}",
          error_code: 'unknown_error',
          raw_response: response.parsed_response
        }
      end
    rescue JSON::ParserError
      {
        success: false,
        error: 'Ошибка парсинга ответа от OpenAI',
        error_code: 'parse_error'
      }
    end
  end
end
