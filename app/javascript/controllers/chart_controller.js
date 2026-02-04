import { Controller } from "@hotwired/stimulus"
import Chart from "chart.js/auto"

export default class extends Controller {
  static values = {
    labels: Array,
    datasets: Array,
    type: String,
    stacked: Boolean
  }

  connect() {
    this.chart = new Chart(this.element, {
      type: this.typeValue || "line",
      data: {
        labels: this.labelsValue || [],
        datasets: this.datasetsValue || []
      },
      options: this.chartOptions()
    })
  }

  disconnect() {
    if (this.chart) {
      this.chart.destroy()
      this.chart = null
    }
  }

  chartOptions() {
    const stacked = this.stackedValue || false

    return {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: {
          position: "bottom",
          align: "start",
          labels: {
            color: "#C9CFDA",
            boxWidth: 10,
            boxHeight: 10,
            padding: 12,
            font: {
              size: 11
            }
          }
        },
        tooltip: {
          backgroundColor: "rgba(15, 23, 42, 0.95)",
          borderColor: "rgba(148, 163, 184, 0.4)",
          borderWidth: 1,
          titleColor: "#F8FAFC",
          bodyColor: "#E2E8F0"
        }
      },
      layout: {
        padding: {
          left: 8,
          right: 8
        }
      },
      scales: {
        x: {
          stacked: stacked,
          ticks: {
            color: "#94A3B8"
          },
          grid: {
            color: "rgba(148, 163, 184, 0.15)"
          }
        },
        y: {
          stacked: stacked,
          ticks: {
            color: "#94A3B8"
          },
          grid: {
            color: "rgba(148, 163, 184, 0.15)"
          }
        }
      }
    }
  }
}
