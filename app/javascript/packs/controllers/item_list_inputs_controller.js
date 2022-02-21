import axios from 'axios'
import {Controller} from "stimulus"

export default class extends Controller {
  static targets = ['itemTypeSelect', 'styleSelect', 'filterableFieldSelect', 'filterableFieldSelectWrapper']

  connect() {
    const csrfToken = (document.querySelector("meta[name=csrf-token]") || {}).content;
    axios.defaults.headers.common["X-CSRF-Token"] = csrfToken;
    axios.defaults.headers.common["X-Requested-With"] = 'XMLHttpRequest';
    this.urls = JSON.parse(this.data.get('urls'))
    if (this.styleSelectTarget.value == 'line') {
      this.filterableFieldSelectTarget.setAttribute('required', 'true')
    }
  }

  updateFilterableFieldSelect(e) {
    if (this.itemTypeSelectTarget.value == '') {
      this.filterableFieldSelectWrapperTarget.selectedIndex = -1
      this.filterableFieldSelectWrapperTarget.classList.add('d-none')
      this.filterableFieldSelectTarget.removeAttribute('required')
    } else {
      if (this.styleSelectTarget.value == 'line') {
        this.filterableFieldSelectWrapperTarget.classList.remove('d-none')
        this.filterableFieldSelectTarget.setAttribute('required', 'true')
      }
      axios.post(this.urls.filterableFieldSelectOptionsUrl,
        {item_type_id: this.itemTypeSelectTarget.value})
        .then((response) => {
          this.filterableFieldSelectTarget.options.length = 0;
          this.filterableFieldSelectTarget.innerHTML = "<option value=''></option>" + response.data;
        });
    }
  }

  toggleDisplayFilterableFieldSelect(e) {
    if (this.styleSelectTarget.value == 'line' && this.itemTypeSelectTarget.value != '') {
      this.filterableFieldSelectWrapperTarget.classList.remove('d-none')
      this.updateFilterableFieldSelect({})
    } else {
      this.filterableFieldSelectWrapperTarget.selectedIndex = -1
      this.filterableFieldSelectWrapperTarget.classList.add('d-none')
    }
  }
}
