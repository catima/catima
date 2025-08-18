import React, {useEffect, useState, useCallback} from "react";
import axios from 'axios';
import SelectedReferenceSearch from './SelectedReferenceSearch';
import ItemTypesReferenceSearch from './ItemTypesReferenceSearch';
import AsyncPaginate from 'react-select-async-paginate';

// Default configuration for HTTP requests.
const HTTP_CONFIG = {
  retry: 3,
  retryDelay: 1000,
};

const ReferenceSearch = (props) => {
  const {
    fieldUuid,
    itemId,
    catalog,
    itemType,
    locale,
    searchPlaceholder: searchPlaceholderProps,
    choosePlaceholder: choosePlaceholderProps,
    filterPlaceholder: filterPlaceholderProps,
    selectCondition: selectConditionProps,
    fieldConditionData,
    noOptionsMessage,
    addComponent,
    deleteComponent,
    canAddComponent,
    canRemoveComponent,
  } = props

  const [loadingMessage, setLoadingMessage] = useState("")
  const [isInitialized, setIsInitialized] = useState(false)
  const [optionsList, setOptionsList] = useState([])
  const [items, setItems] = useState([])
  const [fields, setFields] = useState([])
  const [isLoading, setIsLoading] = useState(false)
  const [selectedFilter, setSelectedFilter] = useState([])
  const [itemTypeSearch, setItemTypeSearch] = useState(false)
  const [selectCondition, setSelectCondition] = useState(selectConditionProps)
  const [selectedCondition, setSelectedCondition] = useState('')
  const [selectedFieldCondition, setSelectedFieldCondition] = useState('')
  const [selectedItem, setSelectedItem] = useState([])
  const [searchPlaceholder, setSearchPlaceholder] = useState(searchPlaceholderProps)
  const [choosePlaceholder, setChoosePlaceholder] = useState(choosePlaceholderProps)
  const [filterPlaceholder, setFilterPlaceholder] = useState(filterPlaceholderProps)
  const [referenceData, setReferenceData] = useState({
    inputData: null,
    inputType: 'Field::Text',
    dateFormat: '',
    localizedDateTimeData: [],
    isLoading: false
  });

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

  useEffect(() => {
    if (selectedFilter?.value) {
      fetchReferenceData(selectedFilter);
    }
  }, [selectedFilter])

  const fetchReferenceData = useCallback(async (filter) => {
    if (!filter || !filter.value) {
      return;
    }

    setReferenceData(prev => ({ ...prev, isLoading: true }));

    try {
      const url = `/react/${catalog}/${locale}/${itemType}/${filter.value}`;
      const response = await axios.get(url, HTTP_CONFIG);
      const { data } = response;

      const formatOption = data.inputOptions?.find(option => option && 'format' in option);
      const localizedOption = data.inputOptions?.find(option => option && 'localizedDateTimeData' in option);

      setReferenceData({
        inputData: data.inputData || [],
        inputType: data.inputType || 'Field::Text',
        dateFormat: formatOption ? formatOption.format : '',
        localizedDateTimeData: localizedOption ? localizedOption.localizedDateTimeData : [],
        isLoading: false
      });

      if (data.selectCondition?.length > 0) {
        _updateSelectCondition(data.selectCondition);
      }

    } catch (error) {
      console.error('Erreur lors de la récupération des données:', error);
      setReferenceData(prev => ({ ...prev, isLoading: false }));
    }
  }, [catalog, locale, itemType]);

  async function _fetchLoadingMessage() {
    let {data} = await axios.get(
      `/react/${catalog}/${locale}/${itemType}?simple_fields=true&page=1`
    )
    setLoadingMessage(data.loading_message);
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
    if (typeof event === 'undefined' || event.action !== "pop-value") {
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
      // TODO REMOVE REMPLACER PAR SELECTEDFILTER === NULL
      setItemTypeSearch(false);
      setReferenceData({
        inputData: null,
        inputType: 'Field::Text',
        dateFormat: '',
        localizedDateTimeData: [],
        isLoading: false
      });
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

  function _selectFieldCondition(event) {
    if (typeof event === 'undefined' || event.action !== "pop-value") {
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
        fieldUuid={fieldUuid}
        itemId={itemId}
        selectedCondition={selectedCondition}
        choosePlaceholder={choosePlaceholder}
        noOptionsMessage={noOptionsMessage}
        locale={locale}
        referenceData={referenceData}
      />
    else
      return <SelectedReferenceSearch
        fieldUuid={fieldUuid}
        selectedCondition={selectedCondition}
        itemId={itemId}
        updateSelectedItem={_updateSelectedItem}
        searchPlaceholder={searchPlaceholder}
        loadingMessage={loadingMessage}
        noOptionsMessage={noOptionsMessage}
        items={items}
        fields={fields}
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
      name={`advanced_search[criteria][${fieldUuid}][${itemId}][sort_field_uuid]`}
      value={selectedFilter}
      onChange={_selectFilter}
      options={_getFilterOptions()}
      placeholder={filterPlaceholder}
      noOptionsMessage={noOptionsMessage}
    />
  }

  function renderFieldConditionElement() {
    return (
      <select className="form-select filter-condition" name={`advanced_search[criteria][${fieldUuid}][${itemId}][field_condition]`} value={selectedFieldCondition}
              onChange={_selectFieldCondition}>
        {fieldConditionData.map((item) => {
          return <option key={item.key} value={item.key}>{item.value}</option>
        })}
      </select>
    );
  }

  function renderSelectConditionElement() {
    return (
      <select className="form-select filter-condition" name={`advanced_search[criteria][${fieldUuid}][${itemId}][condition]`} value={selectedCondition}
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
            <div className="col-lg-1">
              <div className="row">
                  {canAddComponent &&
                  <div className="col-lg-12">
                      <a type="button" onClick={addComponent}>
                      <i className="fa fa-plus"></i>
                      </a>
                  </div>
                  }
                  {canRemoveComponent &&
                  <div className="col-lg-12">
                      <a type="button" onClick={deleteComponent}>
                      <i className="fa fa-trash"></i>
                      </a>
                  </div>
                  }
              </div>
            </div>
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
