import { Controller } from "stimulus"

export default class extends Controller {
  static values = { id: Number }

  dismiss(event) {
    event.preventDefault()

    const token = document.querySelector('[name="csrf-token"]').content

    fetch(`/messages/${this.idValue}/dismiss`, {
      method: 'POST',
      headers: {
        'X-CSRF-Token': token,
        'Content-Type': 'application/json'
      }
    })
    .then(response => {
      if (response.ok) {
        this.element.remove()
      }
    })
    .catch(error => {
      console.error('Error dismissing message:', error)
    })
  }
}
