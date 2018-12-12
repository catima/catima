import React, { Component } from 'react';
import ReactDOM from 'react-dom';
import ReactSelect from 'react-select';
import striptags from 'striptags';

class SelectedReferenceSearch extends Component {
  constructor(props){
    super(props);

    this.state = {
      selectedItem: [],
      hiddenInputValue: []
    };

    this.referenceSearchId = `${this.props.srcRef}-editor`;
    this.filterId = `${this.props.srcRef}-filters`;
    this.selectItem = this._selectItem.bind(this);
  }

  _save(){
    if(this.props.multi) {
      //this.state.selectedItem is an array
      if(this.state.selectedItem !== null && this.state.selectedItem.length !== 0) {

        var idArray = [];
        this.state.selectedItem.forEach((item) => {
          idArray.push(item.value);
        });

        this.setState({ hiddenInputValue: idArray });

        document.getElementsByName(this.props.inputName)[0].value = this.state.hiddenInputValue;
      }
    } else {
      //this.state.selectedItem is a JSON
      if(this.state.selectedItem !== null && Object.keys(this.state.selectedItem).length !== 0) {

        this.setState({ hiddenInputValue: this.state.selectedItem.value });

        document.getElementsByName(this.props.inputName)[0].value = this.state.hiddenInputValue;
      }
    }


  }

  _selectItem(item, event){
    if(typeof event === 'undefined' || event.action !== "pop-value" || !this.props.req) {
      if(typeof item !== 'undefined') {
        this.setState({ selectedItem: item }, () => this._save());
      } else {
        this.setState({ selectedItem: [] }, () => this._save());
      }

      this.props.updateSelectedItem(item);
    }
  }

  _getItemOptions(){
    var optionsList = [];
    optionsList = this.props.items.map(item =>
      this._getJSONItem(item)
    );

    return optionsList;
  }

  _itemName(item){
    return striptags(item.default_display_name);
  }

  _getJSONItem(item) {
    return {value: item.id, label: this._itemName(item)};
  }

  render() {
    return (
      <div>
        <ReactSelect id={this.referenceSearchId} name={this.props.inputName} delimiter="," isMulti={this.props.multiple} options={this._getItemOptions()} className="basic-multi-select" onChange={this.selectItem} classNamePrefix="select" placeholder={this.props.searchPlaceholder} noOptionsMessage={this.props.noOptionsMessage}/>
      </div>
    );
  }
}

export default SelectedReferenceSearch;
