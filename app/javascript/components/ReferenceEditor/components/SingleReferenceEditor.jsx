import React, {useState, useEffect} from 'react';
import AsyncPaginate from 'react-select-async-paginate';
import striptags from 'striptags';
import ReactSelect from 'react-select';
import Validation from '../modules/validation';
import {filterDropdownStyle} from '../modules/styles';

const SingleReferenceEditor = (props) => {
  const {
    srcRef,
    req,
    items: itemsProps,
    selectedReference,
    fields,
    itemsUrl,
    loadingMessage,
    searchPlaceholder,
    noOptionsMessage,
    filterPlaceholder
  } = props

  const [items, setItems] = useState(itemsProps)
  const [selectedItem, setSelectedItem] = useState(_load(document.getElementById(srcRef).value))
  const [selectedFilter, setSelectedFilter] = useState(null)
  const [optionsList, setOptionsList] = useState([])
  const [isValid, setIsValid] = useState(Validation.isValid(
    req,
    srcRef,
    'SingleReferenceEditor'
  ))

  const editorId = `${srcRef}-editor`;
  const filterId = `${srcRef}-filters`;

  useEffect(() => {
    // If reference value is empty but field is required, insert the default value.
    if (document.getElementById(srcRef).value == '' && req) {
      _selectItem(optionsList[0]);
    }
  }, [])

  useEffect(() => {
    _save()
  }, [selectedItem])

  function _selectItem(item, event) {
    if (typeof event === 'undefined' || event.action !== "pop-value" || !req) {
      if (typeof item !== 'undefined' && item !== null) {
        setSelectedItem(item)
      } else {
        setSelectedItem([])
      }
    }
  }

  function _load(v) {
    if (v !== null && v !== '') {
      let initItem = selectedReference;
      if (initItem.length === 1) return _getJSONItem(initItem[0]);
    }
    return [];
  }

  function _save() {
    if (selectedItem) {
      const v = (selectedItem.value == '' || selectedItem.value == null) ? '' : JSON.stringify(selectedItem.value);
      document.getElementById(srcRef).value = v;
      setIsValid(Validation.isValid(
        req,
        srcRef,
        'SingleReferenceEditor'
      ))
    }
  }

  function _getItemOptions(itemsVar) {
    let optionsListVar = [];
    let stateItems = items;
    if (itemsVar) {
      stateItems = stateItems.concat(itemsVar);
    }
    optionsListVar = stateItems.map(item => _getJSONItem(item));
    setItems(stateItems)
    setOptionsList(optionsListVar)
    return optionsList;
  }

  function _getJSONItem(item) {
    return {value: item.id, label: _itemName(item)};
  }

  function _itemName(item) {
    if ((!selectedFilter
      || item[selectedFilter.value] === null
      || item[selectedFilter.value].length === 0)
    ) {
      return striptags(item.default_display_name);
    }
    return striptags(item.default_display_name) + ' - ' + item[selectedFilter.value];
  }

  useEffect(() => {
    let optionsList = _getItemOptions();
    if (typeof selectedItem !== 'undefined' && selectedItem !== null) {
      const currentItem = optionsList.find(item => item.value === selectedItem.value);
      setSelectedItem(currentItem);
    } else {
      setSelectedItem([]);
    }
  }, [selectedFilter])

  function _selectFilter(filter) {
    setSelectedFilter(filter)
  }

  function _getFilterOptions() {
    let optionsListVar = [];
    optionsListVar = fields.filter(field => (field.human_readable));
    optionsListVar = optionsListVar.map(field =>
      _getJSONFilter(field)
    );

    return optionsListVar;
  }

  function _getJSONFilter(field) {
    return {value: field.slug, label: field.name};
  }

  async function _loadOptions(search, loadedOptions, {page}) {
    // Avoid useless API calls if there are less than 25 loaded items and
    // the user searches by filtering options with JS
    if (itemsProps.length < 25) {
      let regexExp = new RegExp(search, 'i')
      let optionsListVar = _getItemOptions();
      let itemsVar = optionsListVar.filter(function (item) {
        return item.label !== null && item.label.match(regexExp) !== null && item.label.match(regexExp).length > 0
      });

      if (search.length === 0) {
        if (optionsListVar === items && selectedFilter === null) {
          itemsVar = [];
        } else {
          itemsVar = itemsProps.map(item => _getJSONItem(item));
        }
      }

      return {
        options: itemsVar,
        hasMore: false,
        additional: {
          page: page,
        },
      };
    }

    if (items.length === 25) {
      let hasMore;
      let newOptions;
      const response = await fetch(`${itemsUrl}?search=${search}&page=${page}`);
      const responseJSON = await response.json();
      newOptions = responseJSON.items.map(item => _getJSONItem(item));
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

  return (
    <div className="input-group single-reference-container"
         style={Validation.getStyle(req, srcRef, 'SingleReferenceEditor')}
    >
      <AsyncPaginate
        cacheUniq={JSON.stringify(optionsList)} // used to update the options loaded on page load
        id={editorId}
        className="single-reference flex-fill"
        debounceTimeout={800}
        isClearable={!req}
        isMulti={false}
        isSearchable={true}
        loadingMessage={() => loadingMessage}
        loadOptions={_loadOptions}
        onChange={_selectItem}
        options={optionsList}
        placeholder={searchPlaceholder}
        noOptionsMessage={noOptionsMessage}
        value={selectedItem}
        additional={{
          page: 1,
        }}
      />
      <div className="input-group-addon">
        <ReactSelect
          id={filterId}
          className="single-reference-filter"
          isSearchable={false}
          isClearable={true}
          value={selectedFilter}
          onChange={_selectFilter}
          options={_getFilterOptions()}
          placeholder={filterPlaceholder}
          noOptionsMessage={noOptionsMessage}
          styles={filterDropdownStyle}
        />
      </div>
    </div>
  )
}

export default SingleReferenceEditor;
