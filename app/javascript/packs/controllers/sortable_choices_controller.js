import {Controller} from "stimulus"
import Sortable from 'sortablejs';
import axios from 'axios'

export default class extends Controller {
  static targets = ["sortableList", "enabler"]

  connect() {
    this.initializeSortable();
  }

  initializeSortable() {
    this.sortables = [];
    this.sortableListTargets.forEach((el) => {
      let sortable = new Sortable(el, {
        group: "sortable-choices",
        animation: 150,
        fallbackOnBody: true,
        swapThreshold: 0.65,
        dataIdAttr: 'data-sortable-choices-id',
        ghostClass: 'bg-light',
        emptyInsertThreshold: 25,
        onStart: () => {
          this.element.classList.add("sorting");
        },
        onEnd: (e) => {
          this.element.classList.remove("sorting");
          let params = this.sortables.map((sortable) => (
            {
              parent_id: sortable.el.dataset.sortableChoicesParentId,
              children_ids: sortable.toArray()
            }
          ));
          axios.post(this.data.get("updateUrl"), {positions: params})
        }
      });
      this.sortables.push(sortable);
    })
  }
}
