import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["container"]
  static values = { url: String }

  connect() {
    this.loadCharts()
  }

  loadCharts() {
    this.containerTargets.forEach(container => {
      this.loadChart(container)
    })
  }

  async loadChart(container) {
    const chartType = container.dataset.chartType
    const scope = container.dataset.scope

    try {
      const response = await fetch(`${this.urlValue}?chart_type=${chartType}&scope=${scope}`, {
        headers: {
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest'
        }
      })

      if (response.ok) {
        const { data, top } = await response.json()
        this.renderChart(container, data, top, chartType)
      } else {
        this.showError(container, 'Failed to load chart data')
      }
    } catch (error) {
      console.error(`Error loading ${chartType} chart:`, error)
      this.showError(container, 'An error occurred while loading the chart')
    }
  }

  renderChart(container, data, top, chartType) {
    // Clear loading spinner
    container.innerHTML = ''

    // Create chart wrapper
    const chartWrapper = document.createElement('div')
    chartWrapper.className = 'stats-chart'

    // Add title
    const title = document.createElement('h4')
    title.textContent = `Pageview, ${chartType} (top ${top} catalogs)`
    chartWrapper.appendChild(title)

    // Create chart div with unique ID
    const chartId = `chart-${chartType}-${Date.now()}`
    const chartDiv = document.createElement('div')
    chartDiv.id = chartId
    chartDiv.style.height = '300px'
    chartWrapper.appendChild(chartDiv)

    container.appendChild(chartWrapper)

    // Render chart when Chartkick is ready
    this.whenChartkickReady(() => {
      new Chartkick.LineChart(chartId, data, {
        download: true,
        min: 0,
        library: {
          chart: {
            height: 300
          }
        }
      })
    })
  }

  whenChartkickReady(callback) {
    if (typeof Chartkick !== 'undefined' && Chartkick.LineChart) {
      // Chartkick is ready, execute immediately
      setTimeout(callback, 10)
    } else {
      // Wait for Chartkick to load
      setTimeout(() => this.whenChartkickReady(callback), 100)
    }
  }

  showError(container, message) {
    container.innerHTML = `
      <div class="alert alert-danger" role="alert">
        <strong>Error:</strong> ${message}
      </div>
    `
  }
}
