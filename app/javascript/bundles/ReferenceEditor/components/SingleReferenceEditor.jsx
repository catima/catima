import React, { Component } from 'react';
import ReactSelect from 'react-select';
import striptags from 'striptags';

class SingleReferenceEditor extends Component {
  constructor(props){
    super(props);

    const selItem = document.getElementById(this.props.srcRef).value;

    this.state = {
      selectedItem: selItem
    };
    this.editorId = `${this.props.srcRef}-editor`;
    this.selectItem = this._selectItem.bind(this);
    this.handleChange = this._handleChange.bind(this);
  }

  componentDidMount(){
    // If reference value is empty but field is required, insert the default value.
    if (document.getElementById(this.props.srcRef).value == '' && this.props.req) {
      this._selectItem(this._emptyOption());
    }
  }

  _selectItem(item){
    this.setState({ selectedItem: item});
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
    return {key: `${this.props.srcId}-${item.id}`, value: item.id, label: this._itemName(item)};
  }

  _handleChange(option) {
    this.setState({selectedItem: option});
  }

  renderItem(item){
    return <option key={item.key} value={item.id}>{item.name}</option>
  }

  render(){
    return (
      <div className="form-group">
        <ReactSelect id={this.editorId} value={this.state.selectedItem} onChange={this.handleChange} options={this._getOptionList()}/>
      </div>
    );
  }
}

export default SingleReferenceEditor;
