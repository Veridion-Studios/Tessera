import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String, interval: { type: Number, default: 10000 } }

  connect() {
    this.poll()
    this.timer = setInterval(() => this.poll(), this.intervalValue)
  }

  disconnect() {
    clearInterval(this.timer)
  }

  poll() {
    fetch(this.urlValue, {
      headers: { "Accept": "text/vnd.turbo-stream.html, text/html" }
    })
      .then(r => r.text())
      .then(html => {
        const parser = new DOMParser()
        const doc = parser.parseFromString(html, "text/html")
        const frame = doc.querySelector("turbo-frame#escrow_status")
        const local = document.querySelector("turbo-frame#escrow_status")
        if (frame && local) local.innerHTML = frame.innerHTML
      })
      .catch(() => {}) // fail silently
  }
}