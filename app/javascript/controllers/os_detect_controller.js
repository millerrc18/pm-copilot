import { Controller } from "@hotwired/stimulus"

// Shows only the keytip relevant to the user's OS.
// macOS and iPadOS: show mac target
// Windows and Linux: show nonMac target
// Touch only: show none, both remain hidden
export default class extends Controller {
  static targets = ["mac", "nonMac"]

  connect() {
    this.hideAll()

    if (this.isTouchOnlyDevice()) return

    if (this.isApplePlatform()) {
      this.showMac()
    } else {
      this.showNonMac()
    }
  }

  hideAll() {
    this.macTargets.forEach((el) => el.classList.add("hidden"))
    this.nonMacTargets.forEach((el) => el.classList.add("hidden"))
  }

  showMac() {
    this.macTargets.forEach((el) => el.classList.remove("hidden"))
  }

  showNonMac() {
    this.nonMacTargets.forEach((el) => el.classList.remove("hidden"))
  }

  isTouchOnlyDevice() {
    const touch = navigator.maxTouchPoints && navigator.maxTouchPoints > 0
    const smallScreen = window.matchMedia("(max-width: 768px)").matches
    return touch && smallScreen && !this.isIPadOS()
  }

  isApplePlatform() {
    const uad = navigator.userAgentData
    const platform = uad && uad.platform ? uad.platform : navigator.platform

    if (this.isIPadOS()) return true

    return /Mac|iPhone|iPad|iPod/i.test(platform || "")
  }

  isIPadOS() {
    return navigator.platform === "MacIntel" && navigator.maxTouchPoints > 1
  }
}
