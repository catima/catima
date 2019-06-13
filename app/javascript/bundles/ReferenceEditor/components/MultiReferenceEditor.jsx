import React, { Component } from 'react';
import axios from 'axios';
import AsyncPaginate from 'react-select-async-paginate';
import ReactDOM from 'react-dom';
import ReactSelect from 'react-select';
import striptags from 'striptags';
import LoadingDots from '../../StyleControl/components/LoadingDots';

const WAIT_INTERVAL = 800;

class MultiReferenceEditor extends Component {
  constructor(props){
    super(props);

    this.state = {
      items: [],
      page: 1,
      loadMore: true,
      isFetching: false,
      isSearching: false,
      selectedItems: this.props.selectedReferences.map((item) => item.id),
      selectedItemsToRender: this.props.selectedReferences,
      availableRefsSelectedFilter: null,
      selectedRefsSelectedFilter: null,
      filterAvailableInputValue: '',
      filterSelectedInputValue: ''
    };

    this.editorId = `${this.props.srcRef}-editor`;
    this.availableRefsFilterId = `${this.props.srcRef}-available-filters`;
    this.selectedRefsFilterId = `${this.props.srcRef}-selected-filters`;

    this.highlightItem = this._highlightItem.bind(this);
    this.selectItems = this._selectItems.bind(this);
    this.unselectItems = this._unselectItems.bind(this);
    this.availableRefsSelectFilter = this._availableRefsSelectFilter.bind(this);
    this.selectedRefsSelectFilter = this._selectedRefsSelectFilter.bind(this);
    this.filterAvailableReferences = this._filterAvailableReferences.bind(this);
    this.filterSelectedReferences = this._filterSelectedReferences.bind(this);

    this.fetchItems = this._fetchItems.bind(this);
    this.state.items = this.props.items;
    if (this.props.items.length < 25) {
      this.state.loadMore = false;
    }
  }

  componentWillMount() {
    this.timer = null;
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

  _fetchItems = async (search, page) => {
    if (!this.state.isFetching && this.state.loadMore) {
      // Avoir useless API calls if there are less than 25 loaded items and the user searches
      if (this.props.items.length < 25 && search.length > 0) {
        var regexExp = new RegExp(search, 'i')

        this.setState({items:
          this.props.items.filter(function(item) {
            return item.name !== null && item.name.match(regexExp) !== null && item.name.match(regexExp).length > 0
          })
        });

        return {
          options: this.getItemOptions(this.state.items),
          hasMore: false,
          additional: {
            page: page,
          },
        };
      }

      const csrfToken = $('meta[name="csrf-token"]').attr('content');
      let config = {
        retry: 3,
        retryDelay: 1000,
        headers: {'X-CSRF-Token': csrfToken}
      };

      this.setState({
        isFetching: true
      })
      if (this.state.filterAvailableInputValue === null) {
        this.setState({filterAvailableInputValue: ''})
      }
      let currentPage = this.state.page+1;
      let currentItems = this.state.items;
      await axios.get(`${this.props.itemsUrl}?search=${this.state.filterAvailableInputValue}&page=${currentPage}`, config)
        .then(res => {
          this.setState({
            items: currentItems.concat(res.data.items),
            loadMore: res.data.items.length === 25,
            isFetching: false,
            page: currentPage
          });
        });
    }
  }

  _save(){
    this.updateButtonStatus();
    const v = JSON.stringify(
      this.state.selectedItems.map( v =>
        v.toString()
      )
    );
    document.getElementById(this.props.srcRef).value = v;

    this.setState({ selectedItemsToRender: [] });
    this.state.selectedItems.forEach((item) => {
      this.setState((state) =>
        ({ selectedItemsToRender: state.selectedItemsToRender.concat(state.items.filter(it => it.id === item)) })
      );
    });
  }

  _availableRefsItemName(item){
    if(typeof this.state === 'undefined') return striptags(item.default_display_name);
    if(typeof this.state !== 'undefined'
        && (this.state.availableRefsSelectedFilter === null
            || item[this.state.availableRefsSelectedFilter.value] === null
            || typeof item[this.state.availableRefsSelectedFilter.value] === 'undefined'
            || item[this.state.availableRefsSelectedFilter.value].length === 0)
    ) {
      return striptags(item.default_display_name);
    }
    return striptags(item.default_display_name) + ' - ' + item[this.state.availableRefsSelectedFilter.value];
  }

  _selectedRefsItemName(item){
    if(typeof this.state === 'undefined') return striptags(item.default_display_name);
    if(typeof this.state !== 'undefined'
        && (this.state.selectedRefsSelectedFilter === null
          || item[this.state.selectedRefsSelectedFilter.value] === null
          || typeof item[this.state.selectedRefsSelectedFilter.value] === 'undefined'
          || item[this.state.selectedRefsSelectedFilter.value].length === 0)
    ) {
      return striptags(item.default_display_name);
    }
    return striptags(item.default_display_name) + ' - ' + item[this.state.selectedRefsSelectedFilter.value];
  }

  _selectButtonId(status){
    return `${this.editorId}-${status}`;
  }

  _availableRefsSelectFilter(filter){
    this.setState({ availableRefsSelectedFilter: filter });
  }

  _selectedRefsSelectFilter(filter){
    this.setState({ selectedRefsSelectedFilter: filter });
  }

  _getFilterOptions(){
    var optionsList = [];
    optionsList = this.props.fields.filter(field => field.human_readable);

    optionsList = optionsList.map(field =>
      this._getJSONFilter(field)
    );

    return optionsList;
  }

  _getJSONFilter(field) {
    return {value: field.slug, label: field.name};
  }

  _filterAvailableReferences = async (e) => {
    clearTimeout(this.timer);

    var searchTerm = e.target.value;
    this.setState({
      filterAvailableInputValue: searchTerm,
      isSearching: true
    });

    this.timer = setTimeout(() => {
      if (!this.state.isFetching) {
        const csrfToken = $('meta[name="csrf-token"]').attr('content');
        let config = {
          retry: 3,
          retryDelay: 1000,
          headers: {'X-CSRF-Token': csrfToken}
        };

        this.state.page = 1;
        if (this.state.filterAvailableInputValue === null) {
          this.state.filterAvailableInputValue = '';
        }
        var itemsUrl = `${this.props.itemsUrl}?search=${searchTerm}&page=${this.state.page}`
        this.state.selectedItems.forEach((itemId) => {
          itemsUrl = itemsUrl + `&except[]=${itemId}`
        });

        axios.get(itemsUrl, config)
          .then(res => {
            this.setState({
              items: res.data.items,
              isSearching: false
            });
          });
      }
    }, WAIT_INTERVAL);
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

  handleScroll = (e) => {
    const bottom = e.target.clientHeight - (e.target.scrollHeight - e.target.scrollTop) > -10;

    if (bottom) {
      if (!this.state.isFetching && this.state.loadMore) {
        this.fetchItems();
      }
    }
  }

  renderAvailableItemDiv(item, selectedItems){
    if (item.default_display_name === null) {
      return null;
    }

    const itemDivId = `${this.props.srcId}-${item.id}`;
    if (selectedItems == false && this.state.selectedItems.indexOf(item.id) > -1) return null;
    if (selectedItems == true && this.state.selectedItems.indexOf(item.id) == -1) return null;

    // Filtering the unselected items ItemList
    if(selectedItems == false && this.state.filterAvailableInputValue !== '') {
      var isInString = -1;

      if(this.state.availableRefsSelectedFilter !== null) {
        if(item[this.state.availableRefsSelectedFilter.value] !== null && item[this.state.availableRefsSelectedFilter.value].length !== 0) {
          var searchString = item.default_display_name.toLowerCase() + ' - ' + JSON.stringify(item[this.state.availableRefsSelectedFilter.value]).toLowerCase();
          isInString = searchString.indexOf(this.state.filterAvailableInputValue.toLowerCase());
        } else {
          isInString = item.default_display_name.toLowerCase().indexOf(this.state.filterAvailableInputValue.toLowerCase());
        }
      } else {
        isInString = item.default_display_name.toLowerCase().indexOf(this.state.filterAvailableInputValue.toLowerCase());
      }

      if(isInString === -1) return null;
    }

    return (
      <div id={itemDivId} key={itemDivId} className="item" onClick={this.highlightItem}>
        {this._availableRefsItemName(item)}
      </div>
    );
  }

  renderSelectedItemDiv(item, selectedItems){
    const itemDivId = `${this.props.srcId}-${item.id}`;
    if (selectedItems == false && this.state.selectedItems.indexOf(item.id) > -1) return null;
    if (selectedItems == true && this.state.selectedItems.indexOf(item.id) == -1) return null;

    // Filtering the selected items ItemList
    if(selectedItems == true && this.state.filterSelectedInputValue !== '') {
      var isInString = -1;
      if(this.state.selectedRefsSelectedFilter !== null &&
          item[this.state.selectedRefsSelectedFilter.value] !== null &&
          item[this.state.selectedRefsSelectedFilter.value].length !== 0
      ) {
        var searchString = item.default_display_name.toLowerCase() + ' - ' + JSON.stringify(item[this.state.selectedRefsSelectedFilter.value]).toLowerCase();
          isInString = searchString.indexOf(this.state.filterSelectedInputValue.toLowerCase());
      } else {
          isInString = item.default_display_name.toLowerCase().indexOf(this.state.filterSelectedInputValue.toLowerCase());
      }

      if(isInString === -1) return null;
    }

    return (
      <div id={itemDivId} key={itemDivId} className="item" onClick={this.highlightItem}>
        {this._selectedRefsItemName(item)}
      </div>
    );
  }

  render(){
    const loadingDotsStyle = {
      minWidth: 20,
      verticalAlign: "top"
    };

    return (
      <div className="multiple-reference-container">
        <div id={this.editorId} className="wrapper">
          <div className="availableReferences" onScroll={this.handleScroll}>
              <div className="input-group">

                <input
                  className="form-control"
                  type="text"
                  value={this.state.filterAvailableInputValue}
                  onChange={this.filterAvailableReferences}
                  placeholder={this.props.searchPlaceholder}/>

                  {this.state.isSearching ? (
                    <div className="input-group-addon" style={loadingDotsStyle}>
                      <LoadingDots/>
                    </div> ) : ( '' )}

                <div className="input-group-addon">
                  <ReactSelect
                    id={this.availableRefsFilterId}
                    className="multiple-reference-filter"
                    isSearchable={false}
                    isClearable={true}
                    value={this.state.availableRefsSelectedFilter}
                    onChange={this.availableRefsSelectFilter}
                    options={this._getFilterOptions()}
                    placeholder={this.props.filterPlaceholder}
                    noOptionsMessage={this.props.noOptionsMessage}/>
                </div>
              </div>
            <div>
              {this.state.items.map(item =>
                this.renderAvailableItemDiv(item, false)
              )}
              { this.state.isFetching && <LoadingDots/> }
            </div>
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
            <div className="input-group">
              <input className="form-control" type="text" value={this.state.filterSelectedInputValue} onChange={this.filterSelectedReferences} placeholder={this.props.searchPlaceholder}/>
              <div className="input-group-addon"><ReactSelect id={this.selectedRefsFilterId} className="multiple-reference-filter" isSearchable={false} isClearable={true} value={this.state.selectedRefsSelectedFilter} onChange={this.selectedRefsSelectFilter} options={this._getFilterOptions()} placeholder={this.props.filterPlaceholder} noOptionsMessage={this.props.noOptionsMessage}/></div>
            </div>
            <div>
              {this.state.selectedItemsToRender.map(item =>
                this.renderSelectedItemDiv(item, true)
              )}
            </div>
          </div>
        </div>
      </div>
    );
  }
}

export default MultiReferenceEditor;
