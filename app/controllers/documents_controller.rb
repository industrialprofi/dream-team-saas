class DocumentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_document, only: [:show, :edit, :update, :destroy, :generate_text]
  before_action :ensure_owner, only: [:show, :edit, :update, :destroy, :generate_text]

  # GET /documents
  def index
    @documents = current_user.documents.recent.page(params[:page])
  end

  # GET /documents/:id
  def show
    @request_logs = @document.request_logs.recent.limit(10)
  end

  # GET /documents/new
  def new
    @document = current_user.documents.build
  end

  # POST /documents
  def create
    @document = current_user.documents.build(document_params)
    @document.status = :draft

    if @document.save
      redirect_to @document, notice: 'Документ успешно создан.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /documents/:id/edit
  def edit
  end

  # PATCH/PUT /documents/:id
  def update
    if @document.update(document_params)
      respond_to do |format|
        format.html { redirect_to @document, notice: 'Документ обновлён.' }
        format.turbo_stream # Для автосейва
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream { render turbo_stream: turbo_stream.replace(@document, partial: 'form_errors', locals: { document: @document }) }
      end
    end
  end

  # DELETE /documents/:id
  def destroy
    @document.destroy
    redirect_to documents_path, notice: 'Документ удалён.'
  end

  # POST /documents/:id/generate_text
  def generate_text
    unless @document.can_generate?
      redirect_to @document, alert: 'Нельзя генерировать текст для этого документа.'
      return
    end

    @document.update!(status: :processing)
    GenerateTextJob.perform_later(@document.id, params[:prompt])

    respond_to do |format|
      format.html { redirect_to @document, notice: 'Генерация текста начата...' }
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          'document_status',
          partial: 'status',
          locals: { document: @document }
        )
      end
    end
  end

  private

  def set_document
    @document = Document.find(params[:id])
  end

  def ensure_owner
    redirect_to documents_path, alert: 'Доступ запрещён.' unless @document.user == current_user
  end

  def document_params
    params.require(:document).permit(:title, :content)
  end
end
