import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

export default class extends Controller {
  static values = {
    url: String,
    interval: Number
  }

  connect() {
    this.startTimer()
  }

  disconnect() {
    this.stopTimer()
  }

  refresh() {
    if (this.hasUrlValue) {
      Turbo.visit(this.urlValue, { frame: this.element.id })
    }
  }

  startTimer() {
    if (!this.hasIntervalValue || this.intervalValue <= 0) {
      return
    }

    this.timer = window.setInterval(() => {
      this.refresh()
    }, this.intervalValue)
  }

  stopTimer() {
    if (this.timer) {
      window.clearInterval(this.timer)
      this.timer = null
    }
  }
}
