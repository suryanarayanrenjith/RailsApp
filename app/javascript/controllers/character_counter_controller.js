import { Controller } from "@hotwired/stimulus"

// Shows how many characters remain in a field with a maxlength.
//
//   <div data-controller="character-counter">
//     <textarea maxlength="1000" data-character-counter-target="input"
//               data-action="character-counter#update"></textarea>
//     <span data-character-counter-target="counter"></span>
//   </div>
export default class extends Controller {
  static targets = [ "input", "counter" ]

  connect() {
    this.update()
  }

  update() {
    const limit = this.inputTarget.maxLength
    if (limit < 0) return

    const remaining = limit - this.inputTarget.value.length
    this.counterTarget.textContent = `${remaining.toLocaleString()} characters left`
    this.counterTarget.classList.toggle("counter-warning", remaining <= limit * 0.1)
  }
}
