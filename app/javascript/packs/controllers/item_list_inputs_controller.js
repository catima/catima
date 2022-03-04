import axios from 'axios'
import {Controller} from "stimulus"

const CREATED_AT = 'ca';
const ASCENDING = 'asc';

export default class extends Controller {
  static targets = ['itemTypeSelect', 'sortSelect', 'styleSelect', 'sortFieldSelect', 'sortFieldSelectWrapper']

  connect() {
    const csrfToken = (document.querySelector("meta[name=csrf-token]") || {}).content;
    axios.defaults.headers.common["X-CSRF-Token"] = csrfToken;
    axios.defaults.headers.common["X-Requested-With"] = 'XMLHttpRequest';
    this.urls = JSON.parse(this.data.get('urls'))

    if (this.styleSelectTarget.value == 'line') {
      this.sortFieldSelectTarget.setAttribute('required', 'true')
      this.getOptionByValue(this.sortSelectTarget, CREATED_AT)
          .setAttribute('disabled', '')
    }
  }

  updateSortFieldSelect(e) {
    if (this.itemTypeSelectTarget.value == '') {
      this.sortFieldSelectWrapperTarget.selectedIndex = 0
      this.sortFieldSelectWrapperTarget.classList.add('d-none')
      this.sortFieldSelectTarget.removeAttribute('required')
    } else {
      if (this.styleSelectTarget.value == 'line') {
        this.sortFieldSelectWrapperTarget.classList.remove('d-none')
        this.sortFieldSelectTarget.setAttribute('required', 'true')
      }
      axios.post(this.urls.sortFieldSelectOptionsUrl,
        {item_type_id: this.itemTypeSelectTarget.value})
        .then((response) => {
          this.sortFieldSelectTarget.options.length = 0;
          this.sortFieldSelectTarget.innerHTML = "<option value=''></option>" + response.data;
        });
    }
  }

  toggleDisplaySortFieldSelect(e) {
    if (this.styleSelectTarget.value == 'line' && this.itemTypeSelectTarget.value != '') {
      this.sortFieldSelectWrapperTarget.classList.remove('d-none')
      this.updateSortFieldSelect({})

      this.getOptionByValue(this.sortSelectTarget, CREATED_AT)
          .setAttribute('disabled', '')
      this.getOptionByValue(this.sortSelectTarget, CREATED_AT)
          .removeAttribute('selected')
      this.getOptionByValue(this.sortSelectTarget, ASCENDING)
          .setAttribute('selected', '')
    } else {
      this.sortFieldSelectWrapperTarget.selectedIndex = 0
      this.sortFieldSelectWrapperTarget.classList.add('d-none')

      this.getOptionByValue(this.sortSelectTarget, CREATED_AT)
          .removeAttribute('disabled')
      this.getOptionByValue(this.sortSelectTarget, ASCENDING)
          .removeAttribute('selected')
      this.getOptionByValue(this.sortSelectTarget, CREATED_AT)
          .setAttribute('selected', '')
    }
  }

  getOptionByValue(selectElement, value) {
    return Array.from(selectElement.options)
        .find((option => option.value === value))
  }
}
