class GenerateTextJob < ApplicationJob
  queue_as :default
  
  # Повторить до 3 раз при ошибке
  retry_on StandardError, wait: 30.seconds, attempts: 3

  def perform(document_id, prompt)
    document = Document.find(document_id)
    user = document.user

    begin
      # Инициализируем клиент LLM
      llm_client = Llm::Client.new
      
      # Генерируем текст
      result = llm_client.generate_text(prompt)
      
      if result[:success]
        # Обновляем документ
        document.update!(
          content: result[:text],
          status: :completed
        )
        
        # Логируем запрос
        RequestLog.create!(
          user: user,
          document: document,
          prompt: prompt,
          response: result[:text],
          tokens_used: result[:tokens_used]
        )
        
        # Отправляем уведомление через Turbo Stream
        broadcast_update(document, 'success', 'Текст успешно сгенерирован!')
      else
        # Обрабатываем ошибку
        handle_error(document, result[:error])
      end
      
    rescue => e
      Rails.logger.error "GenerateTextJob failed: #{e.message}"
      handle_error(document, "Произошла ошибка: #{e.message}")
      raise e # Для повторных попыток
    end
  end

  private

  def broadcast_update(document, status, message)
    # Обновляем статус документа через Turbo Stream
    Turbo::StreamsChannel.broadcast_replace_to(
      "document_#{document.id}",
      target: 'document_status',
      partial: 'documents/status',
      locals: { document: document, message: message, status: status }
    )
    
    # Обновляем содержимое документа
    Turbo::StreamsChannel.broadcast_replace_to(
      "document_#{document.id}",
      target: 'document_content',
      partial: 'documents/content',
      locals: { document: document }
    )
  end

  def handle_error(document, error_message)
    # Возвращаем статус в draft
    document.update!(status: :draft)
    
    # Отправляем уведомление об ошибке
    broadcast_update(document, 'error', error_message)
  end
end
