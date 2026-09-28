import { Controller } from "@hotwired/stimulus"

// Lets people dismiss a flash message.
export default class extends Controller {
  dismiss() {
    this.element.remove()
  }
}
