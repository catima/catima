import React, { Component } from 'react';
import AsyncPaginate from 'react-select-async-paginate';
import striptags from 'striptags';
import ReactSelect from 'react-select';

class SingleReferenceEditor extends Component {
  constructor(props){
    super(props);

    const v = document.getElementById(this.props.srcRef).value;
    const selItem = this._load(v);

    this.state = {
      items: [],
      selectedItem: selItem,
      selectedFilter: null,
      optionsList: this.props.items.map(item => this._getJSONItem(item))
    };

    this.editorId = `${this.props.srcRef}-editor`;
    this.filterId = `${this.props.srcRef}-filters`;
    this.selectItem = this._selectItem.bind(this);
    this.selectFilter = this._selectFilter.bind(this);
    this.loadOptions = this._loadOptions.bind(this);
    this.getItemOptions = this._getItemOptions.bind(this);
    this.state.items = this.props.items;
  }

  componentDidMount(){
    // If reference value is empty but field is required, insert the default value.
    if (document.getElementById(this.props.srcRef).value == '' && this.props.req) {
      this._selectItem(this.state.optionsList[0]);
    }
  }

  _selectItem(item, event){
    if(typeof event === 'undefined' || event.action !== "pop-value" || !this.props.req) {
      if(typeof item !== 'undefined' && item !== null) {
        this.setState({ selectedItem: item }, () => this._save());
      } else {
        this.setState({ selectedItem: [] }, () => this._save());
      }
    }
  }

  _load(v){
    if (v !== null && v !== '') {
      let initItem = this.props.items.filter(item => item.id === parseInt(JSON.parse(v)));
      if(initItem.length === 1) return this._getJSONItem(initItem[0]);
    }
    return [];
  }

  _save(){
    if(this.state.selectedItem !== null) {
      const v = (this.state.selectedItem.value == '' || this.state.selectedItem.value == null) ? '' : JSON.stringify(this.state.selectedItem.value);
      document.getElementById(this.props.srcRef).value = v;
    }
  }

  _getItemOptions(items) {
    var optionsList = [];

    var stateItems = this.state.items;
    if (typeof items !== 'undefined') { stateItems = stateItems.concat(items); }

    optionsList = stateItems.map(item => this._getJSONItem(item) );

    this.setState({
      items: stateItems,
      optionsList: optionsList
    });

    return optionsList;
  }

  _getJSONItem(item) {
    return {value: item.id, label: this._itemName(item)};
  }

  _itemName(item){
    if(typeof this.state === 'undefined') { return striptags(item.default_display_name); }

    if(typeof this.state !== 'undefined' &&
            (this.state.selectedFilter === null
          || item[this.state.selectedFilter.value] === null
          || item[this.state.selectedFilter.value].length === 0)
        ) {
      return striptags(item.default_display_name);
    }

    return striptags(item.default_display_name) + ' - ' + item[this.state.selectedFilter.value];
  }

  _selectFilter(filter){
    this.setState({ selectedFilter: filter}, () => {
      var optionsList = this._getItemOptions();
      if(typeof this.state.selectedItem !== 'undefined' && this.state.selectedItem !== null) {
        const currentItem = optionsList.find(item => item.value === this.state.selectedItem.value);
        this.setState({ selectedItem: currentItem });
      } else {
        this.setState({ selectedItem: [] });
      }
    });
  }

  _getFilterOptions(){
    var optionsList = [];
    optionsList = this.props.fields.filter(field => (field.human_readable));

    optionsList = optionsList.map(field =>
      this._getJSONFilter(field)
    );

    return optionsList;
  }

  _getJSONFilter(field) {
    return {value: field.slug, label: field.name};
  }

  async _loadOptions(search, loadedOptions, { page }) {
    // Avoir useless API calls if there are less than 25 loaded items and the user searches by filtering options with JS
    if (this.props.items.length < 25) {
      var regexExp = new RegExp(search, 'i')

      var items = this.state.optionsList.filter(function(item) {
        return item.label !== null && item.label.match(regexExp) !== null && item.label.match(regexExp).length > 0
      });

      if (search.length === 0) {
        items = [];
      }

      return {
        options: items,
        hasMore: false,
        additional: {
          page: page,
        },
      };
    }

    if (this.props.items.length === 25) {
      var hasMore;
      var newOptions;

      if (search.length === 0) { page++; }

      const csrfToken = $('meta[name="csrf-token"]').attr('content');
      let config = { headers: {'X-CSRF-Token': csrfToken} };
      const response = await fetch(`${this.props.itemsUrl}?search=${search}&page=${page}`, config);
      const responseJSON = await response.json();

      newOptions = responseJSON.items.map(item => this._getJSONItem(item));
      hasMore = responseJSON.hasMore;

      return {
        options: newOptions,
        hasMore: hasMore,
        additional: {
          page: page + 1,
        },
      };
    }

    return {
      options: [],
      hasMore: false,
      additional: {
        page: page,
      },
    };
  }

  render(){
    return (
      <div className="input-group single-reference-container">
        <AsyncPaginate
          cacheUniq={JSON.stringify(this.state.optionsList)} // used to update the options loaded on page load
          id={this.editorId}
          className="single-reference"
          debounceTimeout={800}
          isClearable={!this.props.req}
          isMulti={false}
          isSearchable={true}
          loadingMessage={() => this.props.loadingMessage}
          loadOptions={this.loadOptions}
          onChange={this.selectItem}
          options={this.state.optionsList}
          placeholder={this.props.searchPlaceholder}
          noOptionsMessage={this.props.noOptionsMessage}
          value={this.state.selectedItem}
          additional={{
            page: 1,
          }}
        />
        <div className="input-group-addon">
          <ReactSelect
            id={this.filterId}
            className="single-reference-filter"
            isSearchable={false}
            isClearable={true}
            value={this.state.selectedFilter}
            onChange={this.selectFilter}
            options={this._getFilterOptions()}
            placeholder={this.props.filterPlaceholder}
            noOptionsMessage={this.props.noOptionsMessage}
          />
        </div>
      </div>
    );
  }
}

export default SingleReferenceEditor;
