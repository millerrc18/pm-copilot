import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog"]

  open() {
    if (this.dialogTarget.open) {
      return
    }
    this.dialogTarget.showModal()
  }

  close() {
    if (!this.dialogTarget.open) {
      return
    }
    this.dialogTarget.close()
  }
}
