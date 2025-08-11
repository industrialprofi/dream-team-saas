import { Controller } from "@hotwired/stimulus"

// Контроллер для автоматического сохранения документов
export default class extends Controller {
  static targets = ["status"]
  static values = { url: String }

  connect() {
    this.timeout = null
    this.saving = false
  }

  // Сохранить изменения с задержкой
  save() {
    if (this.saving) return

    // Отменяем предыдущий таймер
    if (this.timeout) {
      clearTimeout(this.timeout)
    }

    // Показываем статус "Сохраняется..."
    this.updateStatus("Сохраняется...", "text-yellow-600")

    // Устанавливаем новый таймер на 2 секунды
    this.timeout = setTimeout(() => {
      this.performSave()
    }, 2000)
  }

  // Выполнить сохранение
  async performSave() {
    if (this.saving) return

    this.saving = true

    try {
      const formData = new FormData(this.element)
      
      const response = await fetch(this.urlValue, {
        method: 'PATCH',
        body: formData,
        headers: {
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        }
      })

      if (response.ok) {
        this.updateStatus("Сохранено", "text-green-600")
        this.updateWordCount()
      } else {
        this.updateStatus("Ошибка сохранения", "text-red-600")
      }
    } catch (error) {
      console.error('Ошибка автосохранения:', error)
      this.updateStatus("Ошибка сохранения", "text-red-600")
    } finally {
      this.saving = false
    }
  }

  // Обновить статус сохранения
  updateStatus(text, className) {
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = text
      this.statusTarget.className = className
    }
  }

  // Обновить счётчик слов
  updateWordCount() {
    const contentField = this.element.querySelector('textarea[name*="content"]')
    const wordCountElement = document.getElementById('word-count')
    
    if (contentField && wordCountElement) {
      const wordCount = contentField.value.trim().split(/\s+/).filter(word => word.length > 0).length
      wordCountElement.textContent = wordCount
    }
  }
}
