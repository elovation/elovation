import { Controller } from "@hotwired/stimulus"

// Colours a Chartkick chart from the theme's CSS tokens. Each series names a
// token (e.g. "--chart-1"); Chart.js can't read oklch() or light-dark(), so
// each token is resolved to rgb by painting it on a 1x1 canvas. Re-applied
// when the system switches between light and dark.
export default class extends Controller {
  connect() {
    this.scheme = window.matchMedia("(prefers-color-scheme: dark)")
    this.apply = this.apply.bind(this)
    this.scheme.addEventListener("change", this.apply)
    this.whenChartReady(this.apply)
  }

  disconnect() {
    this.scheme.removeEventListener("change", this.apply)
  }

  whenChartReady(callback, attempts = 120) {
    const chart = this.chart
    if (chart && chart.getChartObject()) return callback()
    if (attempts > 0) requestAnimationFrame(() => this.whenChartReady(callback, attempts - 1))
  }

  get chart() {
    const element = this.element.querySelector("[id^='chart-']")
    return element && window.Chartkick && window.Chartkick.charts[element.id]
  }

  apply() {
    const chart = this.chart
    if (!chart) return

    if (window.Chart) {
      window.Chart.defaults.font.family = getComputedStyle(this.element).fontFamily
      window.Chart.defaults.font.size = 14
    }

    const text = this.resolve("--text-muted")
    const grid = this.resolve("--line")
    const axis = { ticks: { color: text }, grid: { color: grid }, title: { color: text } }
    const data = chart.dataSource.map((series) => ({ ...series, color: this.resolve(series.token) }))

    chart.updateData(data, { ...chart.getOptions(), library: { scales: { x: axis, y: axis } } })
  }

  resolve(token) {
    const probe = document.createElement("span")
    probe.style.color = `var(${token})`
    this.element.append(probe)
    const color = getComputedStyle(probe).color
    probe.remove()

    const context = this.canvas.getContext("2d", { willReadFrequently: true })
    context.clearRect(0, 0, 1, 1)
    context.fillStyle = color
    context.fillRect(0, 0, 1, 1)
    const [r, g, b] = context.getImageData(0, 0, 1, 1).data
    return `rgb(${r}, ${g}, ${b})`
  }

  get canvas() {
    this._canvas ||= Object.assign(document.createElement("canvas"), { width: 1, height: 1 })
    return this._canvas
  }
}
