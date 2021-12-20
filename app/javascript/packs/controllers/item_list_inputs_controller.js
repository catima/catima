import axios from 'axios'
import {Controller} from "stimulus"

export default class extends Controller {
  static targets = ['itemTypeSelect', 'styleSelect', 'filterableFieldSelect', , 'filterableFieldSelectWrapper', 'fieldFormatSelect', 'fieldFormatSelectWrapper']

  connect() {
    const csrfToken = (document.querySelector("meta[name=csrf-token]") || {}).content;
    axios.defaults.headers.common["X-CSRF-Token"] = csrfToken;
    axios.defaults.headers.common["X-Requested-With"] = 'XMLHttpRequest';
    this.urls = JSON.parse(this.data.get('urls'))
  }

  updateFilterableFieldSelect(e) {
    if (this.itemTypeSelectTarget.value == '') {
      this.fieldFormatSelectWrapperTarget.selectedIndex = -1
      this.fieldFormatSelectWrapperTarget.classList.add('d-none')
      this.filterableFieldSelectWrapperTarget.selectedIndex = -1
      this.filterableFieldSelectWrapperTarget.classList.add('d-none')
    } else {
      if (this.styleSelectTarget.value == 'timeline') {
        this.filterableFieldSelectWrapperTarget.classList.remove('d-none')
      }
      axios.post(this.urls.filterableFieldSelectOptionsUrl,
        {item_type_id: this.itemTypeSelectTarget.value})
        .then((response) => {
          this.filterableFieldSelectTarget.options.length = 0;
          this.filterableFieldSelectTarget.innerHTML = "<option value=''></option>" + response.data;
        });
    }
  }

  updateFieldFormatSelect(e) {
    if (this.filterableFieldSelectTarget.value == '') {
      this.fieldFormatSelectWrapperTarget.selectedIndex = -1
      this.fieldFormatSelectWrapperTarget.classList.add('d-none')
    } else {
      axios.post(this.urls.fieldFormatSelectOptionsUrl,
        {field_id: this.filterableFieldSelectTarget.value})
        .then((response) => {
          console.log(response.data.isDateTime)
          if (response.data.isDateTime) {
            this.fieldFormatSelectWrapperTarget.classList.remove('d-none')
          } else {
            this.fieldFormatSelectWrapperTarget.selectedIndex = -1
            this.fieldFormatSelectWrapperTarget.classList.add('d-none')
          }
        });
    }
  }

  toggleDisplayFilterableFieldSelect(e) {
    if (this.styleSelectTarget.value == 'timeline' && this.itemTypeSelectTarget.value != '') {
      this.filterableFieldSelectWrapperTarget.classList.remove('d-none')
      this.updateFilterableFieldSelect({})
      this.fieldFormatSelectWrapperTarget.selectedIndex = -1
      this.fieldFormatSelectWrapperTarget.classList.add('d-none')
    } else {
      this.filterableFieldSelectWrapperTarget.selectedIndex = -1
      this.filterableFieldSelectWrapperTarget.classList.add('d-none')
    }
  }
}
