import {Controller} from "stimulus"

export default class extends Controller {
  static targets = ["revealable", "source", "upArrow", "downArrow"]

  connect() {
    this.show = true
    this.reveal()
    this.revealableTargets.forEach(function (el, _) {
      el.classList.add("toggle-display")
    })
  }

  reveal(e) {
    let target = e?.target || (this.hasSourceTarget ? this.sourceTarget : false)
    if (target) {
      switch (target.nodeName) {
        case "SELECT":
          this.show = target.options[target.selectedIndex].value === this.data.get("value");
          break;
        case "INPUT":
          switch (target.type) {
            case "radio":
              targets.forEach((el) => {
                if (el.checked) {
                  this.show = el.value;
                }
              });
              break;
            case "checkbox":
              this.show = target.checked ? target.id : "";
              break;
          }
      }
    }

    if (this.show) {
      if (this.hasRevealableTarget) {
        this.showElement(this.revealableTarget)
      }
    } else {
      if (this.hasRevealableTarget) {
        this.hideElement(this.revealableTarget)
      }
    }
  }

  showElement(el) {
    this.show = !this.show
    el.classList.add('is-visible')
    el.classList.remove('d-none')
    this.upArrowTarget.classList.add('d-none')
    this.downArrowTarget.classList.remove('d-none')
  }

  hideElement(el) {
    this.show = !this.show
    el.classList.remove('is-visible')
    this.upArrowTarget.classList.remove('d-none')
    this.downArrowTarget.classList.add('d-none')
  }

  showAllElements(e) {
    e.preventDefault()
    this.show = !this.show
    document.querySelectorAll('[data-toggle-display-line-target="revealable"]').forEach(target => target.classList.add('is-visible'))
    document.querySelectorAll('[data-toggle-display-line-target="revealable"]').forEach(target => target.classList.remove('d-none'))
    document.querySelectorAll('[data-toggle-display-line-target="upArrow"]').forEach(target => target.classList.add('d-none'))
    document.querySelectorAll('[data-toggle-display-line-target="downArrow"]').forEach(target => target.classList.remove('d-none'))
  }

  hideAllElements(e) {
    e.preventDefault()
    this.show = !this.show
    document.querySelectorAll('[data-toggle-display-line-target="revealable"]').forEach(target => target.classList.remove('is-visible'))
    document.querySelectorAll('[data-toggle-display-line-target="upArrow"]').forEach(target => target.classList.remove('d-none'))
    document.querySelectorAll('[data-toggle-display-line-target="downArrow"]').forEach(target => target.classList.add('d-none'))
  }
}
