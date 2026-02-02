import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  connect() {
    this.applyFromSelection()
  }

  change() {
    this.applyFromSelection()
  }

  applyFromSelection() {
    const selected = this.inputTargets.find((input) => input.checked)
    const value = selected ? selected.value : "dark-coral"
    const html = document.documentElement

    html.classList.remove("theme-dark-coral", "theme-dark-blue", "theme-light")

    if (value === "dark-blue") {
      html.classList.add("theme-dark-blue")
    } else if (value === "light") {
      html.classList.add("theme-light")
    } else {
      html.classList.add("theme-dark-coral")
    }
  }
}
