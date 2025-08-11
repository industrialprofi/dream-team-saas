require 'rails_helper'

RSpec.describe GenerateTextJob, type: :job do
  let(:user) { create(:user) }
  let(:document) { create(:document, :processing, user: user) }
  let(:prompt) { 'Напиши эссе о важности образования' }
  let(:job) { described_class.new }

  describe '#perform' do
    context 'при успешной генерации текста' do
      let(:successful_response) do
        {
          success: true,
          text: 'Сгенерированный текст об образовании',
          tokens_used: 150
        }
      end

      before do
        allow_any_instance_of(Llm::Client).to receive(:generate_text).and_return(successful_response)
      end

      it 'обновляет содержимое документа' do
        job.perform(document.id, prompt)
        document.reload
        
        expect(document.content).to include('Сгенерированный текст об образовании')
      end

      it 'изменяет статус документа на completed' do
        job.perform(document.id, prompt)
        document.reload
        
        expect(document.status).to eq('completed')
      end

      it 'создаёт лог запроса' do
        expect {
          job.perform(document.id, prompt)
        }.to change(RequestLog, :count).by(1)
        
        log = RequestLog.last
        expect(log.user).to eq(user)
        expect(log.document).to eq(document)
        expect(log.prompt).to eq(prompt)
        expect(log.response).to eq('Сгенерированный текст об образовании')
        expect(log.tokens_used).to eq(150)
      end

      it 'отправляет Turbo Stream обновление' do
        expect {
          job.perform(document.id, prompt)
        }.to have_broadcasted_to("document_#{document.id}").at_least(1)
      end
    end

    context 'при ошибке генерации текста' do
      let(:error_response) do
        {
          success: false,
          error: 'API Error: Rate limit exceeded'
        }
      end

      before do
        allow_any_instance_of(Llm::Client).to receive(:generate_text).and_return(error_response)
      end

      it 'изменяет статус документа на draft' do
        job.perform(document.id, prompt)
        document.reload
        
        expect(document.status).to eq('draft')
      end

      it 'не изменяет содержимое документа' do
        original_content = document.content
        job.perform(document.id, prompt)
        document.reload
        
        expect(document.content).to eq(original_content)
      end

      it 'не создаёт лог запроса' do
        expect {
          job.perform(document.id, prompt)
        }.not_to change(RequestLog, :count)
      end

      it 'отправляет Turbo Stream обновление с ошибкой' do
        expect {
          job.perform(document.id, prompt)
        }.to have_broadcasted_to("document_#{document.id}")
      end
    end

    context 'при исключении во время выполнения' do
      before do
        allow_any_instance_of(Llm::Client).to receive(:generate_text).and_raise(StandardError.new('Network error'))
      end

      it 'изменяет статус документа на draft' do
        expect {
          job.perform(document.id, prompt)
        }.not_to raise_error
        
        document.reload
        expect(document.status).to eq('draft')
      end

      it 'не создаёт лог запроса при исключении' do
        expect {
          job.perform(document.id, prompt)
        }.not_to change(RequestLog, :count)
      end
    end

    context 'когда документ не найден' do
      it 'не вызывает исключение' do
        expect {
          job.perform(99999, prompt)
        }.not_to raise_error
      end
    end
  end

  describe 'очередь задач' do
    it 'выполняется в очереди default' do
      expect(described_class.queue_name).to eq('default')
    end
  end

  describe 'интеграционный тест' do
    it 'может быть поставлена в очередь и выполнена' do
      expect {
        GenerateTextJob.perform_later(document.id, prompt)
      }.to have_enqueued_job(GenerateTextJob).with(document.id, prompt)
    end
  end
end
