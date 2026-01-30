import { Controller } from "@hotwired/stimulus"

const COLLAPSE_KEY = "pm-copilot:sidebar-collapsed"

export default class extends Controller {
  static targets = ["sidebar", "backdrop"]

  connect() {
    this.restore()
  }

  toggleCollapse() {
    const collapsed = !document.body.classList.contains("sidebar-collapsed")
    document.body.classList.toggle("sidebar-collapsed", collapsed)
    window.localStorage.setItem(COLLAPSE_KEY, collapsed)
  }

  open() {
    if (this.hasSidebarTarget) {
      this.sidebarTarget.classList.add("is-open")
    }
    if (this.hasBackdropTarget) {
      this.backdropTarget.classList.add("is-open")
    }
    document.documentElement.classList.add("no-scroll")
  }

  close() {
    if (this.hasSidebarTarget) {
      this.sidebarTarget.classList.remove("is-open")
    }
    if (this.hasBackdropTarget) {
      this.backdropTarget.classList.remove("is-open")
    }
    document.documentElement.classList.remove("no-scroll")
  }

  toggle() {
    if (this.hasSidebarTarget && this.sidebarTarget.classList.contains("is-open")) {
      this.close()
    } else {
      this.open()
    }
  }

  restore() {
    const collapsed = window.localStorage.getItem(COLLAPSE_KEY) === "true"
    document.body.classList.toggle("sidebar-collapsed", collapsed)
    const isMobile = window.matchMedia("(max-width: 767px)").matches
    if (isMobile) {
      this.close()
    }
  }
}
