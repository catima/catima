import React, { Component } from 'react';
import ReactSelect from 'react-select';
import striptags from 'striptags';

class SingleReferenceEditor extends Component {
  constructor(props){
    super(props);

    const v = document.getElementById(this.props.srcRef).value;
    const selItem = this._load(v);

    this.state = {
      selectedItem: selItem,
      selectedFilter: null
    };
    this.editorId = `${this.props.srcRef}-editor`;
    this.filterId = `${this.props.srcRef}-filters`;
    this.selectItem = this._selectItem.bind(this);
    this.selectFilter = this._selectFilter.bind(this);
  }

  componentDidMount(){
    // If reference value is empty but field is required, insert the default value.
    if (document.getElementById(this.props.srcRef).value == '' && this.props.req) {
      this._selectItem(this._emptyOption());
    }
  }

  _selectItem(item){
    const sel = parseInt(item.value);
    this.setState({ selectedItem: item }, () => this._save());
  }

  _emptyOption(){
    return this.props.req ? null : {key: null, value: "", label: ""};
  }

  _load(v){
    if (v !== null && v !== '') {
      let initItem = this.props.items.filter(item => item.id === parseInt(v));
      if(initItem.length === 1) return this._getJSONItem(initItem[0]);
    }
    return [];
  }

  _save(){
    const v = (this.state.selectedItem.value == '' || this.state.selectedItem.value == null) ? '' : JSON.stringify(this.state.selectedItem.value);
    document.getElementById(this.props.srcRef).value = v;
  }

  _getItemOptions(){
    var optionsList = [];
    optionsList = this.props.items.map(item =>
      this._getJSONItem(item)
    );

    return optionsList;
  }

  _itemName(item){
    if(typeof this.state === 'undefined') return striptags(item.default_display_name);
    if(typeof this.state !== 'undefined' && this.state.selectedFilter === null) return striptags(item.default_display_name);
    return striptags(item.default_display_name) + ' - ' + item[this.state.selectedFilter.value];
  }

  _getJSONItem(item) {
    return {value: item.id, label: this._itemName(item)};
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

  render(){
    return (
      <div className="form-group">
        <ReactSelect id={this.editorId} className="single-reference" value={this.state.selectedItem} onChange={this.selectItem} options={this._getItemOptions()}/>
        <ReactSelect id={this.filterId} className="single-reference-filters" isSearchable={false} isClearable={true} value={this.state.selectedFilter} onChange={this.selectFilter} options={this._getFilterOptions()}/>
      </div>
    );
  }
}

export default SingleReferenceEditor;
