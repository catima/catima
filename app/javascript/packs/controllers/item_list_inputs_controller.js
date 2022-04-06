import axios from 'axios'
import {Controller} from "stimulus"

const PRIMARY_ASCENDING = 'f-asc';
const PRIMARY_DESCENDING = 'f-desc';
const CREATED_AT_ASCENDING = 'ca-asc';
const CREATED_AT_DESCENDING = 'ca-desc';
const UPDATED_AT_ASCENDING = 'ua-asc';
const UPDATED_AT_DESCENDING = 'ua-desc';
const LINE_STYLE = 'line';

export default class extends Controller {
  static targets = ['itemTypeSelect', 'sortSelect', 'styleSelect', 'sortFieldSelect', 'sortFieldSelectWrapper']

  connect() {
    const csrfToken = (document.querySelector("meta[name=csrf-token]") || {}).content;
    axios.defaults.headers.common["X-CSRF-Token"] = csrfToken;
    axios.defaults.headers.common["X-Requested-With"] = 'XMLHttpRequest';
    this.urls = JSON.parse(this.data.get('urls'))

    if (this.styleSelectTarget.value === LINE_STYLE) {
      this.sortFieldSelectTarget.setAttribute('required', 'true')

      this.disableOptionsForLineStyle()
    }
  }

  updateSortFieldSelect(e) {
    axios.post(this.urls.sortFieldSelectOptionsUrl,
      {item_type_id: this.itemTypeSelectTarget.value})
      .then((response) => {
        this.sortFieldSelectTarget.options.length = 0;
        this.sortFieldSelectTarget.innerHTML = "<option value=''></option>" + response.data;
      });
  }

  toggleDisplaySortFieldSelect(e) {
    if (this.styleSelectTarget.value === LINE_STYLE) {
      this.updateSortFieldSelect({})

      this.sortFieldSelectWrapperTarget.classList.remove('d-none')
      this.sortFieldSelectTarget.setAttribute('required', 'true')

      this.getOptionByValue(this.sortSelectTarget, PRIMARY_ASCENDING)
          .setAttribute('selected', '')

      this.disableOptionsForLineStyle()
    } else {
      this.sortFieldSelectWrapperTarget.classList.add('d-none')
      this.sortFieldSelectTarget.removeAttribute('required')

      this.enableAllOptions()

      this.getOptionByValue(this.sortSelectTarget, PRIMARY_ASCENDING)
          .removeAttribute('selected')
      this.getOptionByValue(this.sortSelectTarget, PRIMARY_DESCENDING)
          .removeAttribute('selected')
    }
  }

  getOptionByValue(selectElement, value) {
    return Array.from(selectElement.options)
        .find((option => option.value === value))
  }

  disableOptionsForLineStyle() {
    this.getOptionByValue(this.sortSelectTarget, CREATED_AT_ASCENDING)
        .removeAttribute('selected')
    this.getOptionByValue(this.sortSelectTarget, CREATED_AT_DESCENDING)
        .removeAttribute('selected')
    this.getOptionByValue(this.sortSelectTarget, UPDATED_AT_ASCENDING)
        .removeAttribute('selected')
    this.getOptionByValue(this.sortSelectTarget, UPDATED_AT_DESCENDING)
        .removeAttribute('selected')

    this.getOptionByValue(this.sortSelectTarget, CREATED_AT_ASCENDING)
        .setAttribute('disabled', '')
    this.getOptionByValue(this.sortSelectTarget, CREATED_AT_DESCENDING)
        .setAttribute('disabled', '')
    this.getOptionByValue(this.sortSelectTarget, UPDATED_AT_ASCENDING)
        .setAttribute('disabled', '')
    this.getOptionByValue(this.sortSelectTarget, UPDATED_AT_DESCENDING)
        .setAttribute('disabled', '')
  }

  enableAllOptions() {
    this.getOptionByValue(this.sortSelectTarget, CREATED_AT_ASCENDING)
        .removeAttribute('disabled')
    this.getOptionByValue(this.sortSelectTarget, CREATED_AT_DESCENDING)
        .removeAttribute('disabled')
    this.getOptionByValue(this.sortSelectTarget, UPDATED_AT_ASCENDING)
        .removeAttribute('disabled')
    this.getOptionByValue(this.sortSelectTarget, UPDATED_AT_DESCENDING)
        .removeAttribute('disabled')
  }
}
