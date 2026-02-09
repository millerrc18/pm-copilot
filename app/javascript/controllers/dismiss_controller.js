import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { timeout: Number }

  connect() {
    if (this.hasTimeoutValue) {
      this.timer = setTimeout(() => this.close(), this.timeoutValue)
    }
  }

  close() {
    this.element.remove()
  }

  disconnect() {
    if (this.timer) {
      clearTimeout(this.timer)
    }
  }
}
