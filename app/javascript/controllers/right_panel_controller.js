import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "backdrop"]

  connect() {
    this.closeIfMobile()
  }

  open() {
    if (this.hasPanelTarget) {
      this.panelTarget.classList.remove("translate-y-full")
      this.panelTarget.classList.add("translate-y-0")
    }
    if (this.hasBackdropTarget) {
      this.backdropTarget.classList.remove("opacity-0", "pointer-events-none")
      this.backdropTarget.classList.add("opacity-100")
    }
  }

  close() {
    if (this.hasPanelTarget) {
      this.panelTarget.classList.add("translate-y-full")
      this.panelTarget.classList.remove("translate-y-0")
    }
    if (this.hasBackdropTarget) {
      this.backdropTarget.classList.add("opacity-0", "pointer-events-none")
      this.backdropTarget.classList.remove("opacity-100")
    }
  }

  closeIfMobile() {
    const isMobile = window.matchMedia("(max-width: 767px)").matches
    if (isMobile) {
      this.close()
    }
  }
}
