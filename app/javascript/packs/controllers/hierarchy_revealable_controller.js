import {Controller} from "stimulus"

export default class extends Controller {
  static targets = ['choice']

  toggle() {
    $(this.choiceTargets).toggle()
  }
}
