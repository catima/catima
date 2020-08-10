import AsyncPaginate from 'react-select-async-paginate';
import React, { Component } from 'react';
import ReactDOM from 'react-dom';
import striptags from 'striptags';

class SelectedReferenceSearch extends Component {
  constructor(props){
    super(props);

    this.state = {
      isInitialized: false,
      items: [],
      optionsList: [],
      selectedItem: [],
      hiddenInputValue: []
    };

    this.referenceSearchId = `${this.props.srcRef}-editor`;
    this.filterId = `${this.props.srcRef}-filters`;
    this.selectItem = this._selectItem.bind(this);
    this.loadOptions = this._loadOptions.bind(this);
    this.getItemOptions = this._getItemOptions.bind(this);
  }

  componentDidUpdate(prevProps, prevState, snapshot) {
    if (prevProps.items.length !== this.state.items.length) {
      this.setState({
        isInitialized: true,
        items: prevProps.items
      });
    }
  }

  _save(){
    if(this.props.multi) {
      //this.state.selectedItem is an array
      if(this.state.selectedItem !== null && this.state.selectedItem.length !== 0) {

        let idArray = [];
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

  _getItemOptions(items){
    if (typeof items === 'undefined') {
     items = this.state.items;
    }

    let optionsList = [];

    if (typeof items !== 'undefined') {
      optionsList = items.map(item =>
        this._getJSONItem(item)
      );
    }

    return optionsList;
  }

  _itemName(item){
    return striptags(item.default_display_name);
  }

  _getJSONItem(item) {
    return {value: item.id, label: this._itemName(item)};
  }

  async _loadOptions(search, loadedOptions, { page }) {
    if (this.state.optionsList.length < 25 && this.state.isInitialized) {
      if (search.length > 0) {
        let regexExp = new RegExp(search, 'i')

        let items = this.state.optionsList.filter(function (item) {
          return item.label !== null && item.label.match(regexExp) !== null && item.label.match(regexExp).length > 0
        });

        return {
          options: items,
          hasMore: false,
          additional: {
            page: page,
          },
        };
      }

      return {
        options: this.getItemOptions(),
        hasMore: this.state.items.length === 25,
        additional: {
          page: page,
        },
      };
    }

    const csrfToken = $('meta[name="csrf-token"]').attr('content');
    let config = { headers: {'X-CSRF-Token': csrfToken} };
    const response = await fetch(`${this.props.itemsUrl}&search=${search}&page=${page}`, config);
    const responseJSON = await response.json();

    if (!this.state.isInitialized) {
      this.setState({
        isInitialized: search.length === 0,
        optionsList: responseJSON.items.map(item => this._getJSONItem(item))
      });
      this.props.onFocus(responseJSON.fields);
    }

    return {
      options: this.getItemOptions(responseJSON.items),
      hasMore: responseJSON.hasMore,
      additional: {
        page: page + 1,
      },
    };
  }

  render() {
    return (
      <div>
        <AsyncPaginate
          id={this.referenceSearchId}
          name={this.props.inputName}
          delimiter=","
          isMulti={this.props.multiple}
          className="basic-multi-select"
          classNamePrefix="select"
          debounceTimeout={800}
          loadingMessage={() => this.props.loadingMessage}
          placeholder={this.props.searchPlaceholder}
          noOptionsMessage={this.props.noOptionsMessage}
          value={this.state.selectedItem}
          options={this.getItemOptions()}
          loadOptions={this.loadOptions}
          onChange={this.selectItem}
          additional={{
            page: 1,
          }}
        />
      </div>
    );
  }
}

export default SelectedReferenceSearch;
