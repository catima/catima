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
      this.showElement(this.revealableTarget)
    } else {
      this.hideElement(this.revealableTarget)
    }
  }

  showElement(el) {
    this.show = !this.show
    // Get the natural height of the element
    let getHeight = function () {
      el.style.display = 'block'
      let height = el.scrollHeight + 'px'
      el.style.display = ''
      return height
    }

    let height = getHeight()
    el.classList.add('is-visible') // Make the element visible
    el.style.height = height
  }

  hideElement(el) {
    this.show = !this.show
    // Give the element a height to change from
    el.style.height = el.scrollHeight + 'px'
    // Set the height back to height = 0
    window.setTimeout(function () {
      el.style.height = '0'
      el.style.overflow = ''
    }, 1)

    // When the transition is complete, hide it
    window.setTimeout(function () {
      el.classList.remove('is-visible')
    }, 250)
  }
}
