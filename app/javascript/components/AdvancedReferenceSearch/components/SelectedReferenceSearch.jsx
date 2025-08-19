import React, {useState, useEffect, useMemo} from "react";
import AsyncPaginate from 'react-select-async-paginate';
import striptags from 'striptags';

const SelectedReferenceSearch = (props) => {
  const {
    fieldUuid,
    selectedCondition,
    itemId,
    itemsUrl,
    loadingMessage,
    searchPlaceholder,
    noOptionsMessage,
  } = props

  const [isInitialized, setIsInitialized] = useState(false)
  const [items, setItems] = useState([])
  const [optionsList, setOptionsList] = useState([])
  const [selectedItem, setSelectedItem] = useState([])

  const buildInputNameWithCondition = useMemo(() => {
      const currentCondition = selectedCondition || 'default';
      return `advanced_search[criteria][${fieldUuid}][${itemId}][${currentCondition}]`;
  }, [fieldUuid, selectedCondition, itemId]);

  function _getItemOptions(itemsArg) {
    let itemVar = (typeof itemsArg === 'undefined') ? items : itemsArg
    let optionsList = [];
    if (typeof itemVar !== 'undefined') {
      optionsList = itemVar.map(item =>
        _getJSONItem(item)
      );
    }
    console.log(optionsList);
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
        name={buildInputNameWithCondition}
        delimiter=","
        className="basic-multi-select"
        classNamePrefix="select"
        debounceTimeout={800}
        loadingMessage={loadingMessage}
        placeholder={searchPlaceholder}
        noOptionsMessage={noOptionsMessage}
        value={selectedItem}
        options={_getItemOptions()}
        loadOptions={_loadOptions}
        onChange={(item) => setSelectedItem(item || [])}
        additional={{
          page: 1,
        }}
      />
    </div>
  );
}

export default SelectedReferenceSearch;
