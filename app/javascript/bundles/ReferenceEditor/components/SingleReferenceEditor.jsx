import React, { Component } from 'react';
import striptags from 'striptags';

class SingleReferenceEditor extends Component {
  constructor(props){
    super(props);

    const v = document.getElementById(this.props.srcRef).value;
    const selItem = this._load(v);

    this.state = {
      selectedItem: selItem
    };
    this.editorId = `${this.props.srcRef}-editor`;
    this.selectItem = this._selectItem.bind(this);
  }

  componentDidMount(){
    // If reference value is empty but field is required, insert the default value.
    if (document.getElementById(this.props.srcRef).value == '' && this.props.req) {
      this._selectItem();
    }
  }

  _selectItem(){
    const sel = parseInt(document.querySelector(`#${this.editorId}`).value);
    this.setState({ selectedItem: isNaN(sel) ? '' : sel }, () => this._save());
  }

  _emptyOption(){
    return this.props.req ? null : <option key="null" value=""></option>;
  }

  _load(v){
    if (v == null || v == '') return '';
    let selItem = JSON.parse(v);
    if (selItem.hasOwnProperty('raw_value')) return selItem.raw_value ? selItem.raw_value : '';
    if (selItem.hasOwnProperty('length')) return selItem.length > 0 ? parseInt(selItem[0]) : '';
    return selItem ? selItem : '';
  }

  _save(){
    const v = (this.state.selectedItem == '' || this.state.selectedItem == null) ? '' : JSON.stringify(this.state.selectedItem);
    document.getElementById(this.props.srcRef).value = v;
  }

  _itemName(item){
    return striptags(item.default_display_name);
  }

  renderItem(item){
    const itemKey = `${this.props.srcId}-${item.id}`;
    return <option key={itemKey} value={item.id}>{this._itemName(item)}</option>
  }

  render(){
    return (
      <select id={this.editorId} onChange={this.selectItem} value={this.state.selectedItem} className="form-control">
        {this._emptyOption()}
        {this.props.items.map(item =>
          this.renderItem(item)
        )}
      </select>
    );
  }
}

export default SingleReferenceEditor;
