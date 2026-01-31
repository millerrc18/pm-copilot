import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sidebar", "backdrop"]

  connect() {
    this.closeIfMobile()
    this.beforeCacheHandler = this.handleBeforeCache.bind(this)
    document.addEventListener("turbo:before-cache", this.beforeCacheHandler)
  }

  disconnect() {
    if (this.beforeCacheHandler) {
      document.removeEventListener("turbo:before-cache", this.beforeCacheHandler)
    }
  }

  handleBeforeCache() {
    this.close()
  }

  open() {
    if (this.hasSidebarTarget) {
      this.sidebarTarget.classList.remove("-translate-x-full")
      this.sidebarTarget.classList.add("translate-x-0")
    }
    if (this.hasBackdropTarget) {
      this.backdropTarget.classList.remove("opacity-0", "pointer-events-none")
      this.backdropTarget.classList.add("opacity-100")
    }
  }

  close() {
    if (this.hasSidebarTarget) {
      this.sidebarTarget.classList.add("-translate-x-full")
      this.sidebarTarget.classList.remove("translate-x-0")
    }
    if (this.hasBackdropTarget) {
      this.backdropTarget.classList.add("opacity-0", "pointer-events-none")
      this.backdropTarget.classList.remove("opacity-100")
    }
  }

  toggle() {
    if (!this.hasSidebarTarget) return

    if (this.sidebarTarget.classList.contains("-translate-x-full")) {
      this.open()
    } else {
      this.close()
    }
  }

  closeIfMobile() {
    const isMobile = window.matchMedia("(max-width: 767px)").matches
    if (isMobile) {
      this.close()
    }
  }
}
