import React, {useState, useEffect} from "react";
import AsyncPaginate from 'react-select-async-paginate';
import striptags from 'striptags';

const SelectedReferenceSearch = (props) => {
  const {
    multi,
    inputName,
    req,
    updateSelectedItem,
    itemsUrl,
    onFocus,
    loadingMessage,
    searchPlaceholder,
    noOptionsMessage,
    items: itemsProps
  } = props

  const [isInitialized, setIsInitialized] = useState(false)
  const [items, setItems] = useState([])
  const [optionsList, setOptionsList] = useState([])
  const [selectedItem, setSelectedItem] = useState([])
  const [hiddenInputValue, setHiddenInputValue] = useState([])

  useEffect(() => {
    if (itemsProps.length !== items.length) {
      setIsInitialized(true)
      setItems(itemsProps)
    }
  }, [itemsProps])

  useEffect(() => {
    if (selectedItem != []) {
      _save()
    }
  }, [selectedItem])

  function _save() {
    if (multi) {
      //selectedItem is an array
      if (selectedItem !== null && selectedItem.length !== 0) {
        let idArray = [];
        selectedItem.forEach((item) => {
          idArray.push(item.value);
        });
        setHiddenInputValue(idArray);
        document.getElementsByName(inputName)[0].value = hiddenInputValue;
      }
    } else {
      //selectedItem is a JSON
      if (selectedItem !== null && Object.keys(selectedItem).length !== 0) {
        setHiddenInputValue(selectedItem.value);
        document.getElementsByName(inputName)[0].value = hiddenInputValue;
      }
    }
  }

  function _selectItem(item, event) {
    if (typeof event === 'undefined' || event.action !== "pop-value" || !req) {
      if (typeof item !== 'undefined') {
        setSelectedItem(item)
      } else {
        setSelectedItem([])
      }
      updateSelectedItem(item);
    }
  }

  function _getItemOptions(itemsArg) {
    let itemVar = (typeof itemsArg === 'undefined') ? items : itemsArg
    let optionsList = [];
    if (typeof itemVar !== 'undefined') {
      optionsList = itemVar.map(item =>
        _getJSONItem(item)
      );
    }
    return optionsList;
  }

  function _itemName(item) {
    return striptags(item.default_display_name);
  }

  function _getJSONItem(item) {
    return {value: item.id, label: _itemName(item)};
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
        options: _getItemOptions(),
        hasMore: items.length === 25,
        additional: {
          page: page,
        },
      };
    }

    const response = await fetch(`${itemsUrl}&search=${search}&page=${page}`);
    const responseJSON = await response.json();

    if (!isInitialized) {
      setIsInitialized(search.length === 0)
      setOptionsList(responseJSON.items.map(item => _getJSONItem(item)))
      onFocus(responseJSON.fields);
    }

    return {
      options: _getItemOptions(responseJSON.items),
      hasMore: responseJSON.hasMore,
      additional: {
        page: page + 1,
      },
    };
  }

  return (
    <div>
      <AsyncPaginate
        name={inputName}
        delimiter=","
        className="basic-multi-select"
        classNamePrefix="select"
        debounceTimeout={800}
        loadingMessage={() => loadingMessage}
        placeholder={searchPlaceholder}
        noOptionsMessage={noOptionsMessage}
        value={selectedItem}
        options={_getItemOptions()}
        loadOptions={_loadOptions}
        onChange={_selectItem}
        additional={{
          page: 1,
        }}
      />
    </div>
  );
}

export default SelectedReferenceSearch;
