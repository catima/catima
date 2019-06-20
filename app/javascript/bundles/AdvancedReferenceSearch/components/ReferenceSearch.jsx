import React, { Component } from 'react';
import ReactDOM from 'react-dom';
import axios from 'axios';
import SelectedReferenceSearch from './SelectedReferenceSearch';
import ItemTypesReferenceSearch from './ItemTypesReferenceSearch';
import ReactSelect from 'react-select';

class ReferenceSearch extends Component {
  constructor(props){
    super(props);

    this.state = {
      items: [],
      fields: [],
      isLoading: false,
      selectedFilter: null,
      itemTypeSearch: this.props.itemTypeSearch,
      selectCondition: this.props.selectCondition,
      inputName: this.props.inputName.split("[exact]"),
      selectedCondition: '',
      selectedItem: [],
      searchPlaceholder: this.props.searchPlaceholder,
      choosePlaceholder: this.props.choosePlaceholder,
      filterPlaceholder: this.props.filterPlaceholder
    };

    this.selectFilter = this._selectFilter.bind(this);
    this.selectCondition = this._selectCondition.bind(this);
    this.updateSelectedItem = this._updateSelectedItem.bind(this);
    this.updateSelectCondition = this._updateSelectCondition.bind(this);
    this.addComponent = this._addComponent.bind(this);
    this.deleteComponent = this._deleteComponent.bind(this);
    this.fetchItems = this._fetchItems.bind(this);
    this.setFields = this._setFields.bind(this);
  }

  componentDidMount(){
    if(typeof this.props.selectCondition !== 'undefined' && this.props.selectCondition.length !== 0) {
        this.setState({selectedCondition: this.props.selectCondition[0].key});
    }
  }

  _fetchItems() {
    if (this.state.items.length !== 0 || this.state.fields.length !== 0) {
      return;
    }

    const csrfToken = $('meta[name="csrf-token"]').attr('content');
    let config = {
      retry: 3,
      retryDelay: 1000,
      headers: {'X-CSRF-Token': csrfToken}
    };

    axios.get(
      `/api/v2/${this.props.catalog}/${this.props.locale}/${this.props.itemType}?simple_fields=true&page=1`,
      config
    ).then(res => {
      this.setState({
        items: res.data.items,
        fields: res.data.fields,
        isLoading: false,
        loadingMessage: res.data.loading_message
      });
    });

    // Retry failed requests
    axios.interceptors.response.use(undefined, (err) => {
      let config = err.config;

      if(!config || !config.retry) return Promise.reject(err);

      config.__retryCount = config.__retryCount || 0;

      if(config.__retryCount >= config.retry) {
        return Promise.reject(err);
      }

      config.__retryCount += 1;

      let backoff = new Promise(function(resolve) {
        setTimeout(function() {
          resolve();
        }, config.retryDelay || 1);
      });

      return backoff.then(function() {
        return axios(config);
      });
    });
  }

  _buildInputNameCondition(condition) {
      if(this.state.inputName.length === 2) {
        if(condition !== '') return this.state.inputName[0] + '[' + condition + ']' + this.state.inputName[1];
        else return this.state.inputName[0] + '[default]' + this.state.inputName[1];
      } else {
        return this.props.inputName;
      }
  }

  _updateSelectedItem(newVal) {
    this.setState({ selectedItem: newVal });
  }

  _updateSelectCondition(newVal) {
    if(this.state.selectedCondition === '' && newVal.length !== this.state.selectCondition.length) {
      this.setState({selectedCondition: newVal[0].key});
    }

    this.setState({ selectCondition: newVal });
  }

  _isConditionDisabled() {
    if ((typeof this.state.selectedItem !== 'undefined'
        && this.state.selectedItem.length >= 0
        && this.state.selectedFilter === null)
        || this.state.selectCondition.length === 0) {
       return true;
    }
    else {
      return false;
    }
  }

  _selectCondition(event){
    if(typeof event === 'undefined' || event.action !== "pop-value" || !this.props.req) {
      if(typeof event !== 'undefined') {
        this.setState({ selectedCondition: event.target.value });
      } else {
        this.setState({ selectedCondition: '' });
      }
    }
  }

  _setFields(fields) {
    this.setState({fields: fields})
  }

  _selectFilter(value){
    this.setState({ selectedFilter: value });

    if(typeof value !== 'undefined' && value === null) {
        this.setState({ selectedCondition: '' });
        this.setState({ selectCondition: [] });
      this.setState({ itemTypeSearch: false });
    } else {
      this.setState({ itemTypeSearch: true });
    }
  }

  _getFilterOptions(){
    let optionsList = this.state.fields.filter(
        field => (
            field.displayable_to_user
        )
    );

    optionsList = optionsList.map(field =>
      this._getJSONFilter(field)
    );

    return optionsList;
  }

  _isFilterDisabled() {
    if(typeof this.state.selectedItem !== 'undefined' && this.state.selectedItem.length > 0) {
       return true;
    }
    else {
      return false;
    }
  }

  _getJSONFilter(field) {
    return {value: field.uuid, label: field.name};
  }

  _getConditionOptions(){
    var optionsList = [];
    optionsList = this.state.selectCondition.map(item =>
      this._getJSONItem(item)
    );

    return optionsList;
  }

  _addComponent() {
    this.props.addComponent(this.props.itemId);
  }

  _deleteComponent() {
    this.props.deleteComponent(this.props.itemId);
  }

  _getNoOptionsMessage() {
    return () => this.props.noOptionsMessage;
  }

  renderSearch(){
    if (this.state.isLoading) return null;
    if (this.state.itemTypeSearch)
      return <ItemTypesReferenceSearch
                updateSelectCondition={this.updateSelectCondition}
                searchPlaceholder={this.state.searchPlaceholder}
                choosePlaceholder={this.state.choosePlaceholder}
                noOptionsMessage={this._getNoOptionsMessage()}
                items={this.state.items}
                fields={this.state.fields}
                selectedFilter={this.state.selectedFilter}
                selectedCondition={this.state.selectedCondition}
                selectCondition={this.state.selectCondition}
                itemType={this.props.itemType}
                inputName={this._buildInputNameCondition(this.state.selectedCondition)}
                srcRef={this.props.srcRef}
                srcId={this.props.srcId}
                req={this.props.req}
                catalog={this.props.catalog}
                locale={this.props.locale} />
    else
      return <SelectedReferenceSearch
                updateSelectedItem={this.updateSelectedItem}
                searchPlaceholder={this.state.searchPlaceholder}
                loadingMessage={this.state.loadingMessage}
                noOptionsMessage={this._getNoOptionsMessage()}
                items={this.state.items}
                fields={this.state.fields}
                multiple={this.props.multiple}
                inputName={this._buildInputNameCondition(this.state.selectedCondition)}
                srcRef={this.props.srcRef}
                srcId={this.props.srcId}
                req={this.props.req}
                itemsUrl={`/api/v2/${this.props.catalog}/${this.props.locale}/${this.props.itemType}?simple_fields=true`}
                onFocus={this.setFields} />
  }

  renderFilter(){
    return <ReactSelect
      className="single-reference-filter"
      name={this.props.referenceFilterName}
      isSearchable={false}
      isClearable={true}
      isDisabled={this._isFilterDisabled()}
      value={this.state.selectedFilter}
      onChange={this.selectFilter}
      options={this._getFilterOptions()}
      placeholder={this.state.filterPlaceholder}
      noOptionsMessage={this._getNoOptionsMessage()}
      onFocus={this.fetchItems} />
  }

  renderFieldConditionElement(){
    return (
      <select className="form-control filter-condition" name={this.props.fieldConditionName} value={this.state.selectedFieldCondition} onChange={this.selectFieldCondition}>
      { this.props.fieldConditionData.map((item) => {
        return <option key={item.key} value={item.key}>{item.value}</option>
      })}
      </select>
    );
  }

  renderSelectConditionElement(){
    return (
      <select className="form-control filter-condition" name={this.props.selectConditionName} value={this.state.selectedCondition} onChange={this.selectCondition} disabled={this._isConditionDisabled()}>
          { this.state.selectCondition.map((item) => {
              return <option key={item.key} value={item.key}>{item.value}</option>
            })
          }
        </select>
    );
  }

  render() {
    return (
      <div>
        <div className="col-md-2">
          { this.renderFieldConditionElement() }
        </div>
        <div className="col-md-7">
          <div className="reference-search-container">
            <div className="col-md-11 reference-input-container">
              <div className="row">
                <div className="col-md-7">
                  { this.state.isLoading && <div className="loader"></div> }
                  { this.renderSearch() }
                </div>
                <div className="col-md-5">{ this.renderFilter() }</div>
              </div>
            </div>
            { (this.props.itemId === this.props.componentList[0].itemId && this.props.componentList.length === 1) &&
            <div className="col-md-1 icon-container">
              <a type="button" onClick={this.addComponent}><i className="fa fa-plus"></i></a>
            </div>
            }
            { (((this.props.itemId !== this.props.componentList[0].itemId) && (this.props.itemId !== this.props.componentList[this.props.componentList.length - 1].itemId)) || (this.props.itemId === this.props.componentList[0].itemId && this.props.componentList.length > 1)) &&
            <div className="col-md-1 icon-container">
              <a type="button" onClick={this.deleteComponent}><i className="fa fa-trash"></i></a>
            </div>
            }
            { ((this.props.itemId === this.props.componentList[this.props.componentList.length - 1].itemId) && (this.props.itemId !== this.props.componentList[0].itemId)) &&
            <div className="col-md-1">
              <div className="row">
                <div className="col-md-12"><a type="button" onClick={this.addComponent}><i className="fa fa-plus"></i></a></div>
                <div className="col-md-12"><a type="button" onClick={this.deleteComponent}><i className="fa fa-trash"></i></a></div>
              </div>
            </div>
            }
          </div>
        </div>
        <div className="col-md-3 condition-input-container">
            { this.renderSelectConditionElement() }
        </div>
      </div>
    );
  }
}

export default ReferenceSearch;
