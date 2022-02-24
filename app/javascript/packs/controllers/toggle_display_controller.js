import {Controller} from "stimulus"

export default class extends Controller {
  static targets = ["revealable", "source"]

  connect() {
    if (this.data.get("value") && this.hasSourceTarget) {
      this.show = !(this.sourceTarget.value === this.data.get("value"))
    } else {
      this.show = false
    }
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
  }

  hideElement(el) {
    this.show = !this.show
    el.classList.remove('is-visible')
  }
}
