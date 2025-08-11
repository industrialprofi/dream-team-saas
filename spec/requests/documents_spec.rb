require 'rails_helper'

RSpec.describe "Documents", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:document) { create(:document, user: user) }
  let(:other_document) { create(:document, user: other_user) }

  before do
    sign_in user
  end

  describe "GET /documents" do
    it 'возвращает успешный ответ' do
      get documents_path
      expect(response).to have_http_status(:success)
    end

    it 'загружает только документы текущего пользователя' do
      document # создаём документ пользователя
      other_document # создаём документ другого пользователя
      
      get documents_path
      expect(response.body).to include(document.title)
      expect(response.body).not_to include(other_document.title)
    end
  end

  describe "GET /documents/:id" do
    it 'возвращает успешный ответ для документа пользователя' do
      get document_path(document)
      expect(response).to have_http_status(:success)
    end

    it 'запрещает доступ к чужому документу' do
      get document_path(other_document)
      expect(response).to have_http_status(:not_found)
    end

    it 'показывает логи запросов для документа' do
      create(:request_log, user: user, document: document)
      
      get document_path(document)
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /documents/new" do
    it 'возвращает успешный ответ' do
      get new_document_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /documents" do
    let(:valid_params) { { document: { title: 'New Document', content: 'New content' } } }
    let(:invalid_params) { { document: { title: '', content: 'Content' } } }

    it 'создаёт новый документ с валидными параметрами' do
      expect {
        post documents_path, params: valid_params
      }.to change(Document, :count).by(1)
    end

    it 'назначает текущего пользователя владельцем документа' do
      post documents_path, params: valid_params
      expect(Document.last.user).to eq(user)
    end

    it 'перенаправляет на страницу документа после создания' do
      post documents_path, params: valid_params
      expect(response).to redirect_to(Document.last)
    end

    it 'не создаёт документ с невалидными параметрами' do
      expect {
        post documents_path, params: invalid_params
      }.not_to change(Document, :count)
    end

    it 'рендерит форму при ошибках валидации' do
      post documents_path, params: invalid_params
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "GET /documents/:id/edit" do
    it 'возвращает успешный ответ для документа пользователя' do
      get edit_document_path(document)
      expect(response).to have_http_status(:success)
    end

    it 'запрещает редактирование чужого документа' do
      get edit_document_path(other_document)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "PATCH /documents/:id" do
    let(:valid_params) { { document: { title: 'Updated Title' } } }
    let(:invalid_params) { { document: { title: '' } } }

    it 'обновляет документ с валидными параметрами' do
      patch document_path(document), params: valid_params
      document.reload
      expect(document.title).to eq('Updated Title')
    end

    it 'перенаправляет на страницу документа после обновления' do
      patch document_path(document), params: valid_params
      expect(response).to redirect_to(document)
    end

    it 'не обновляет документ с невалидными параметрами' do
      original_title = document.title
      patch document_path(document), params: invalid_params
      document.reload
      expect(document.title).to eq(original_title)
    end

    it 'рендерит форму редактирования при ошибках' do
      patch document_path(document), params: invalid_params
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'запрещает обновление чужого документа' do
      patch document_path(other_document), params: { document: { title: 'Hacked' } }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /documents/:id" do
    it 'удаляет документ пользователя' do
      document # создаём документ
      expect {
        delete document_path(document)
      }.to change(Document, :count).by(-1)
    end

    it 'перенаправляет на список документов после удаления' do
      delete document_path(document)
      expect(response).to redirect_to(documents_path)
    end

    it 'запрещает удаление чужого документа' do
      delete document_path(other_document)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /documents/:id/generate_text" do
    it 'запускает фоновую задачу генерации текста' do
      expect {
        post generate_text_document_path(document), params: { prompt: 'Test prompt' }
      }.to have_enqueued_job(GenerateTextJob).with(document.id, 'Test prompt')
    end

    it 'обновляет статус документа на processing' do
      post generate_text_document_path(document), params: { prompt: 'Test prompt' }
      document.reload
      expect(document.status).to eq('processing')
    end

    it 'возвращает успешный ответ' do
      post generate_text_document_path(document), params: { prompt: 'Test prompt' }
      expect(response).to have_http_status(:ok)
    end

    it 'запрещает генерацию для чужого документа' do
      post generate_text_document_path(other_document), params: { prompt: 'Test prompt' }
      expect(response).to have_http_status(:not_found)
    end

    it 'не запускает генерацию для уже обрабатываемого документа' do
      document.update!(status: :processing)
      
      expect {
        post generate_text_document_path(document), params: { prompt: 'Test prompt' }
      }.not_to have_enqueued_job(GenerateTextJob)
      
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "PATCH /documents/:id/autosave" do
    let(:autosave_params) { { document: { content: 'Auto-saved content' } } }

    it 'обновляет содержимое документа' do
      patch autosave_document_path(document), params: autosave_params
      document.reload
      expect(document.content).to eq('Auto-saved content')
    end

    it 'возвращает JSON ответ' do
      patch autosave_document_path(document), params: autosave_params
      expect(response.content_type).to include('application/json')
    end

    it 'возвращает статус сохранения' do
      patch autosave_document_path(document), params: autosave_params
      json_response = JSON.parse(response.body)
      expect(json_response['saved']).to be true
    end

    it 'запрещает автосохранение чужого документа' do
      patch autosave_document_path(other_document), params: autosave_params
      expect(response).to have_http_status(:not_found)
    end
  end

  # Тесты для неаутентифицированных пользователей
  describe 'when not signed in' do
    before do
      sign_out user
    end

    it 'перенаправляет на страницу входа для index' do
      get documents_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it 'перенаправляет на страницу входа для show' do
      get document_path(document)
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
