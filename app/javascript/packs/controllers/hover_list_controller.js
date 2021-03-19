import {Controller} from "stimulus"

export default class extends Controller {
  static targets = []

  on(e) {
    if (!this.element.classList.contains('sorting')) {
      e.stopPropagation();
      e.currentTarget.classList.add('bg-light');
    }
  }

  off(e) {
    if (!this.element.classList.contains('sorting')) {
      e.currentTarget.classList.remove('bg-light');
    }
  }
}
