import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["field", "total"]

  connect() {
    this.recalculate()
  }

  recalculate() {
    const labor = {}
    let material = 0
    let other = 0

    this.fieldTargets.forEach((field) => {
      const kind = field.dataset.costTotalKind
      const category = field.dataset.costTotalCategory
      const value = parseFloat(field.value) || 0

      if (kind === "material") {
        material = value
        return
      }

      if (kind === "other") {
        other = value
        return
      }

      if (!labor[category]) {
        labor[category] = { hours: 0, rate: 0 }
      }

      labor[category][kind] = value
    })

    const laborTotal = Object.values(labor).reduce((sum, entry) => {
      return sum + (entry.hours || 0) * (entry.rate || 0)
    }, 0)

    const total = laborTotal + material + other
    this.totalTarget.textContent = this.formatCurrency(total)
  }

  formatCurrency(value) {
    return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(value || 0)
  }
}
