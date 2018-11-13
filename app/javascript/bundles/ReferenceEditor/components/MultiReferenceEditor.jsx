import React, { Component } from 'react';
import ReactDOM from 'react-dom';
import ReactSelect from 'react-select';
import striptags from 'striptags';

class MultiReferenceEditor extends Component {
  constructor(props){
    super(props);

    // Load the selected items
    const v = document.getElementById(this.props.srcRef).value;
    const selItems = this._load(v);

    this.state = {
      selectedItems: selItems,
      selectedFilter: null,
      filterAvailableInputValue: '',
      filterSelectedInputValue: ''
    };

    this.editorId = `${this.props.srcRef}-editor`;
    this.filterId = `${this.props.srcRef}-filters`;

    this.highlightItem = this._highlightItem.bind(this);
    this.selectItems = this._selectItems.bind(this);
    this.unselectItems = this._unselectItems.bind(this);
    this.selectFilter = this._selectFilter.bind(this);
    this.filterAvailableReferences = this._filterAvailableReferences.bind(this);
    this.filterSelectedReferences = this._filterSelectedReferences.bind(this);
  }

  _highlightItem(e){
    e.target.classList.toggle('highlighted');
    this.updateButtonStatus();
  }

  _selectItems(){
    const itms = this.highlightedItems('availableReferences');
    this.setState(
      { selectedItems: this.state.selectedItems.concat(itms) },
      () => this._save()
    );
  }

  _unselectItems(){
    const itms = this.highlightedItems('selectedReferences');
    this.setState(
      {
        selectedItems: this.state.selectedItems.filter(itm =>
          itms.indexOf(itm) == -1
        )
      },
      () => this._save()
    );
  }

  _load(v){
    if (v == null || v == '') return [];
    let selItems = JSON.parse(v);
    if (typeof(selItems) !== 'object') return [ parseInt(selItems) ];
    return selItems && selItems.map( v => parseInt(v) );
  }

  _save(){
    this.updateButtonStatus();
    const v = JSON.stringify(
      this.state.selectedItems.map( v =>
        v.toString()
      )
    );
    document.getElementById(this.props.srcRef).value = v;
  }

  _itemName(item){
    if(typeof this.state === 'undefined') return striptags(item.default_display_name);
    if(typeof this.state !== 'undefined' && this.state.selectedFilter === null) return striptags(item.default_display_name);
    return striptags(item.default_display_name) + ' - ' + item[this.state.selectedFilter.value];
  }

  _selectButtonId(status){
    return `${this.editorId}-${status}`;
  }

  _selectFilter(filter){
    this.setState({ selectedFilter: filter });
  }

  _getFilterOptions(){
    var optionsList = [];
    optionsList = this.props.fields.filter(field => field.primary !== true);

    optionsList = optionsList.map(field =>
      this._getJSONFilter(field)
    );

    return optionsList;
  }

  _getJSONFilter(field) {
    if(!field.primary) return {value: field.slug, label: field.name};
  }

  _filterAvailableReferences(e) {
    this.setState({filterAvailableInputValue: e.target.value});
  }

  _filterSelectedReferences(e) {
    this.setState({filterSelectedInputValue: e.target.value});
  }

  highlightedItems(className){
    return Array.prototype.map.call(
      document.querySelectorAll(`#${this.editorId} .${className} .item.highlighted`),
      itm =>
        parseInt(itm.id.split('-')[1])
    );
  }

  updateButtonStatus(){
    if (this.highlightedItems('availableReferences').length > 0)
      document.querySelector(`#${this.editorId} .referenceControls .btn-success`).removeAttribute('disabled');
    else
      document.querySelector(`#${this.editorId} .referenceControls .btn-success`).setAttribute('disabled', 'disabled');

    if (this.highlightedItems('selectedReferences').length > 0)
      document.querySelector(`#${this.editorId} .referenceControls .btn-danger`).removeAttribute('disabled');
    else
      document.querySelector(`#${this.editorId} .referenceControls .btn-danger`).setAttribute('disabled', 'disabled');
  }

  renderItemDiv(item, selectedItems){
    const itemDivId = `${this.props.srcId}-${item.id}`;
    if (selectedItems == false && this.state.selectedItems.indexOf(item.id) > -1) return null;
    if (selectedItems == true && this.state.selectedItems.indexOf(item.id) == -1) return null;

    // Filtering the unselected items ItemList
    if(selectedItems == false && this.state.filterAvailableInputValue !== '') {
      var isInString = -1;
      if(this.state.selectedFilter !== null) {
        var searchString = item.default_display_name.toLowerCase() + ' - ' + item[this.state.selectedFilter.value].toLowerCase();
          isInString = searchString.indexOf(this.state.filterAvailableInputValue.toLowerCase());
      } else {
          isInString = item.default_display_name.toLowerCase().indexOf(this.state.filterAvailableInputValue.toLowerCase());
      }

      if(isInString === -1) return null;
    }

    // Filtering the selected items ItemList
    if(selectedItems == true && this.state.filterSelectedInputValue !== '') {
      var isInString = -1;
      if(this.state.selectedFilter !== null) {
        var searchString = item.default_display_name.toLowerCase() + ' - ' + item[this.state.selectedFilter.value].toLowerCase();
          isInString = searchString.indexOf(this.state.filterSelectedInputValue.toLowerCase());
      } else {
          isInString = item.default_display_name.toLowerCase().indexOf(this.state.filterSelectedInputValue.toLowerCase());
      }

      if(isInString === -1) return null;
    }

    return (
      <div id={itemDivId} key={itemDivId} className="item" onClick={this.highlightItem}>
        {this._itemName(item)}
      </div>
    );
  }

  render(){
    return (
      <div>
        <ReactSelect id={this.filterId} isSearchable={false} isClearable={true} value={this.state.selectedFilter} onChange={this.selectFilter} options={this._getFilterOptions()}/>
        <input className="form-control" type="text" value={this.state.filterAvailableInputValue} onChange={this.filterAvailableReferences}/>
        <input className="form-control" type="text" value={this.state.filterSelectedInputValue} onChange={this.filterSelectedReferences}/>
        <div id={this.editorId} className="wrapper">
          <div className="availableReferences">
            {this.props.items.map(item =>
              this.renderItemDiv(item, false)
            )}
          </div>
          <div className="referenceControls">
            <div id={this._selectButtonId('select')} className="btn btn-success" onClick={this.selectItems} disabled>
              <i className="fa fa-arrow-right"></i>
            </div>
            <div id={this._selectButtonId('unselect')} className="btn btn-danger" onClick={this.unselectItems} disabled>
              <i className="fa fa-arrow-left"></i>
            </div>
          </div>
          <div className="selectedReferences">
            {this.props.items.map(item =>
              this.renderItemDiv(item, true)
            )}
          </div>
        </div>
      </div>
    );
  }
}

export default MultiReferenceEditor;
