import {Controller} from "stimulus"

export default class extends Controller {
  static targets = ["revealable", "upArrow", "downArrow"]

  connect() {
    this.reveal()
    this.revealableTargets.forEach(function (el, _) {
      el.classList.add("toggle-display")
    })
  }

  reveal(e) {
    if (this.hasRevealableTarget && !this.revealableTarget.classList.contains('is-visible')) {
      if (this.hasRevealableTarget) {
        this.revealableTarget.classList.add('is-visible')
        this.revealableTarget.classList.remove('d-none')
        if (this.hasUpArrowTarget) {
          this.upArrowTarget.classList.add('d-none')
        }
        if (this.hasDownArrowTarget) {
          this.downArrowTarget.classList.remove('d-none')
        }
      }
    } else {
      if (this.hasRevealableTarget) {
        this.revealableTarget.classList.remove('is-visible')
        if (this.hasUpArrowTarget) {
          this.upArrowTarget.classList.remove('d-none')
        }
        if (this.hasDownArrowTarget) {
          this.downArrowTarget.classList.add('d-none')
        }
      }
    }
  }

  showAllElements(e) {
    e.preventDefault()
    document.querySelectorAll('[data-toggle-display-line-target="revealable"]').forEach(target => target.classList.add('is-visible'))
    document.querySelectorAll('[data-toggle-display-line-target="revealable"]').forEach(target => target.classList.remove('d-none'))
    document.querySelectorAll('[data-toggle-display-line-target="upArrow"]').forEach(target => target.classList.add('d-none'))
    document.querySelectorAll('[data-toggle-display-line-target="downArrow"]').forEach(target => target.classList.remove('d-none'))
  }

  hideAllElements(e) {
    e.preventDefault()
    document.querySelectorAll('[data-toggle-display-line-target="revealable"]').forEach(target => target.classList.remove('is-visible'))
    document.querySelectorAll('[data-toggle-display-line-target="upArrow"]').forEach(target => target.classList.remove('d-none'))
    document.querySelectorAll('[data-toggle-display-line-target="downArrow"]').forEach(target => target.classList.add('d-none'))
  }
}
