import React, { Component } from 'react';
import ReactSelect from 'react-select';
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
      this._selectItem(this._emptyOption());
    }
  }

  _selectItem(item){
    const sel = parseInt(item.value);
    this.setState({ selectedItem: item }, () => this._save());
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


  _emptyOption(){
    return this.props.req ? null : {key: null, value: "", label: ""};
  }

  _getOptionList(){
    var optionsList = [];
    optionsList = this.props.items.map(item =>
      this._getJSONItem(item)
    );

    optionsList.unshift(this._emptyOption());
    return optionsList;
  }

  _itemName(item){
    return striptags(item.default_display_name);
  }

  _getJSONItem(item) {
    return {value: item.id, label: this._itemName(item)};
  }

  render(){
    return (
      <div className="form-group">
        <ReactSelect id={this.editorId} value={this.state.selectedItem} onChange={this.selectItem} options={this._getOptionList()}/>
      </div>
    );
  }
}

export default SingleReferenceEditor;
