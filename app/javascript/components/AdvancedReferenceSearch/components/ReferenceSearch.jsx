import React, {useEffect, useState} from "react";
import axios from 'axios';
import SelectedReferenceSearch from './SelectedReferenceSearch';
import ItemTypesReferenceSearch from './ItemTypesReferenceSearch';
import AsyncPaginate from 'react-select-async-paginate';

const ReferenceSearch = (props) => {
  const {
    itemTypeSearch: itemTypeSearchProps,
    selectCondition: selectConditionProps,
    inputName: inputNameProps,
    searchPlaceholder: searchPlaceholderProps,
    choosePlaceholder: choosePlaceholderProps,
    filterPlaceholder: filterPlaceholderProps,
    catalog,
    locale,
    itemType,
    req,
    addComponent: addComponentProps,
    itemId,
    deleteComponent: deleteComponentProps,
    noOptionsMessage,
    referenceFilterName,
    fieldConditionName,
    fieldConditionData,
    selectConditionName,
    componentList
  } = props

  const [loadingMessage, setLoadingMessage] = useState("")
  const [isInitialized, setIsInitialized] = useState(false)
  const [optionsList, setOptionsList] = useState([])
  const [items, setItems] = useState([])
  const [fields, setFields] = useState([])
  const [isLoading, setIsLoading] = useState(false)
  const [selectedFilter, setSelectedFilter] = useState([])
  const [itemTypeSearch, setItemTypeSearch] = useState(itemTypeSearchProps)
  const [selectCondition, setSelectCondition] = useState(selectConditionProps)
  const [inputName, setInputName] = useState(inputNameProps.split("[exact]"))
  const [selectedCondition, setSelectedCondition] = useState('')
  const [selectedFieldCondition, setSelectedFieldCondition] = useState('')
  const [selectedItem, setSelectedItem] = useState([])
  const [searchPlaceholder, setSearchPlaceholder] = useState(searchPlaceholderProps)
  const [choosePlaceholder, setChoosePlaceholder] = useState(choosePlaceholderProps)
  const [filterPlaceholder, setFilterPlaceholder] = useState(filterPlaceholderProps)

  useEffect(() => {
    _fetchLoadingMessage()
    if (typeof selectConditionProps !== 'undefined' && selectConditionProps.length !== 0) {
      setSelectedCondition(selectConditionProps[0].key);
    }
  }, [])

  useEffect(() => {
    if (selectCondition?.[0]?.key && selectCondition?.[0]?.key != selectCondition) {
      setSelectedCondition(selectCondition[0].key)
    }
  }, [selectCondition])

  async function _fetchLoadingMessage() {
    let {data} = await axios.get(
      `/react/${catalog}/${locale}/${itemType}?simple_fields=true&page=1`
    )
    setLoadingMessage(data.loading_message);
  }

  function _buildInputNameCondition(condition) {
    if (inputName.length === 2) {
      if (condition !== '') return inputName[0] + '[' + condition + ']' + inputName[1];
      else return inputName[0] + '[default]' + inputName[1];
    } else {
      return inputNameProps;
    }
  }

  function _updateSelectedItem(newVal) {
    setSelectedItem(newVal);
  }

  function _updateSelectCondition(newVal) {
    if (selectedCondition === '' && newVal.length !== selectCondition.length) {
      setSelectedCondition(newVal[0].key);
    }
    setSelectCondition(newVal);
  }

  function _isConditionDisabled() {
    if ((typeof selectedItem !== 'undefined'
        && selectedItem.length >= 0
        && selectedFilter === null)
      || selectCondition.length === 0) {
      return true;
    } else {
      return false;
    }
  }

  function _selectCondition(event) {
    if (typeof event === 'undefined' || event.action !== "pop-value" || !req) {
      if (typeof event !== 'undefined') {
        setSelectedCondition(event.target.value);
      } else {
        setSelectedCondition('');
      }
    }
  }

  function _setFields(fields) {
    setFields(fields)
  }

  function _selectFilter(value) {
    setSelectedFilter(value);
    if (typeof value !== 'undefined' && value === null) {
      setSelectedCondition('');
      setSelectCondition([]);
      setItemTypeSearch(false);
    } else {
      setItemTypeSearch(true);
    }
  }

  function _getFilterOptions(providedFields = false) {
    let computedFields = providedFields ? providedFields : fields
    let optionsList = computedFields.filter(
      field => (
        field.displayable_to_user
      )
    );

    optionsList = optionsList.map(field =>
      _getJSONFilter(field)
    );

    return optionsList;
  }

  function _isFilterDisabled() {
    if (typeof selectedItem !== 'undefined' && selectedItem.length > 0) {
      return true;
    } else {
      return false;
    }
  }

  async function _loadOptions(search, loadedOptions, {page}) {
    if (optionsList.length < 25 && isInitialized) {
      if (search.length > 0) {
        let regexExp = new RegExp(search, 'i')

        let items = optionsList.filter(function (item) {
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
        options: _getFilterOptions(),
        hasMore: fields.length === 25,
        additional: {
          page: page,
        },
      };
    }


    const res = await axios.get(`/react/${catalog}/${locale}/${itemType}?simple_fields=true&page=${page}`)
    if (!isInitialized) {
      setItems(res.data.items)
      setFields(res.data.fields)
      setIsLoading(false)
      setLoadingMessage(res.data.loading_message)
      setIsInitialized(search.length === 0)
      setOptionsList(res.data.fields.map(field => _getJSONFilter(field)))

      return {
        options: _getFilterOptions(res.data.fields),
        hasMore: false,
        additional: {
          page: page + 1,
        },
      };
    }
  }

  function _getJSONFilter(field) {
    return {value: field.uuid, label: field.name};
  }

  function _addComponent() {
    addComponentProps(itemId);
  }

  function _deleteComponent() {
    deleteComponentProps(itemId);
  }

  function _getNoOptionsMessage() {
    return () => noOptionsMessage;
  }

  function _selectFieldCondition(event) {
    if (typeof event === 'undefined' || event.action !== "pop-value" || !this.props.req) {
      if (typeof event !== 'undefined') {
        setSelectedFieldCondition(event.target.value);
      } else {
        setSelectedFieldCondition('');
      }
    }
  }

  function renderSearch() {
    if (isLoading) return null;
    if (itemTypeSearch)
      return <ItemTypesReferenceSearch
        updateSelectCondition={_updateSelectCondition}
        searchPlaceholder={searchPlaceholder}
        choosePlaceholder={choosePlaceholder}
        noOptionsMessage={_getNoOptionsMessage()}
        items={items}
        fields={fields}
        selectedFilter={selectedFilter}
        selectedCondition={selectedCondition}
        selectCondition={selectCondition}
        itemType={itemType}
        inputName={_buildInputNameCondition(selectedCondition)}
        req={req}
        catalog={catalog}
        locale={locale}/>
    else
      return <SelectedReferenceSearch
        updateSelectedItem={_updateSelectedItem}
        searchPlaceholder={searchPlaceholder}
        loadingMessage={loadingMessage}
        noOptionsMessage={_getNoOptionsMessage()}
        items={items}
        fields={fields}
        inputName={_buildInputNameCondition(selectedCondition)}
        req={req}
        itemsUrl={`/react/${catalog}/${locale}/${itemType}?simple_fields=true`}
        onFocus={_setFields}/>
  }

  function renderFilter() {
    return <AsyncPaginate
      className="single-reference-filter"
      delimiter=","
      loadOptions={_loadOptions}
      debounceTimeout={800}
      isSearchable={false}
      isClearable={true}
      isDisabled={_isFilterDisabled()}
      loadingMessage={() => loadingMessage}
      additional={{
        page: 1,
      }}
      name={referenceFilterName}
      value={selectedFilter}
      onChange={_selectFilter}
      options={_getFilterOptions()}
      placeholder={filterPlaceholder}
      noOptionsMessage={_getNoOptionsMessage()}
    />
  }

  function renderFieldConditionElement() {
    return (
      <select className="form-select filter-condition" name={fieldConditionName} value={selectedFieldCondition}
              onChange={_selectFieldCondition}>
        {fieldConditionData.map((item) => {
          return <option key={item.key} value={item.key}>{item.value}</option>
        })}
      </select>
    );
  }

  function renderSelectConditionElement() {
    return (
      <select className="form-select filter-condition" name={selectConditionName} value={selectedCondition}
              onChange={_selectCondition} disabled={_isConditionDisabled()}>
        {selectCondition.map((item) => {
          return <option key={item.key} value={item.key}>{item.value}</option>
        })
        }
      </select>
    );
  }

  return (
    <React.Fragment>
      <div className="col-lg-2">
        {renderFieldConditionElement()}
      </div>
      <div className="col-lg-7">
        <div className="container">
          <div className="reference-search-container row">
            <div className="col-lg-11 reference-input-container">
              <div className="row">
                <div className="col-lg-7">
                  {renderSearch()}
                </div>
                <div className="col-lg-5">{renderFilter()}</div>
              </div>
            </div>
            {(itemId === componentList[0].itemId && componentList.length === 1) &&
            <div className="col-lg-1 icon-container">
              <a type="button" onClick={_addComponent}><i className="fa fa-plus"></i></a>
            </div>
            }
            {(((itemId !== componentList[0].itemId) && (itemId !== componentList[componentList.length - 1].itemId)) || (itemId === componentList[0].itemId && componentList.length > 1)) &&
            <div className="col-lg-1 icon-container">
              <a type="button" onClick={_deleteComponent}><i className="fa fa-trash"></i></a>
            </div>
            }
            {((itemId === componentList[componentList.length - 1].itemId) && (itemId !== componentList[0].itemId)) &&
            <div className="col-lg-1">
              <div className="row">
                <div className="col-lg-12"><a type="button" onClick={_addComponent}><i className="fa fa-plus"></i></a>
                </div>
                <div className="col-lg-12"><a type="button" onClick={_deleteComponent}>
                  <i className="fa fa-trash"></i></a></div>
              </div>
            </div>
            }
          </div>
        </div>
      </div>

      <div className="col-lg-3 condition-input-container">
        {renderSelectConditionElement()}
      </div>
    </React.Fragment>
  );
}

export default ReferenceSearch;
