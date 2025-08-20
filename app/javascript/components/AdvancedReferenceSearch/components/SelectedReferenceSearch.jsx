import React, {useState, useRef, useMemo} from "react";
import AsyncPaginate from 'react-select-async-paginate';
import striptags from 'striptags';

const SelectedReferenceSearch = (props) => {
  const {
    fieldUuid,
    defaultValues,
    selectedCondition,
    itemId,
    itemsUrl,
    loadingMessage,
    searchPlaceholder,
    noOptionsMessage,
  } = props;

  const [selectedItem, setSelectedItem] = useState([])

  const isFirstLoadOptionsRef = useRef(true);

  const buildInputNameWithCondition = useMemo(() => {
      const currentCondition = selectedCondition || 'default';
      return `advanced_search[criteria][${fieldUuid}][${itemId}][${currentCondition}]`;
  }, [fieldUuid, selectedCondition, itemId]);

  function _itemName(item) {
    return striptags(item.default_display_name);
  }

  async function loadOptions(search, loadedOptions, {page}) {
    let url = itemsUrl;
    if (isFirstLoadOptionsRef.current && defaultValues?.["default"]) {
      url += `&default=${defaultValues["default"]}&page=${page}`;
    } else {
      url += `&search=${search}&page=${page}`;
    }

    const response = await fetch(url);
    const responseJSON = await response.json();

    const options = responseJSON.items.map(item => ({
      value: item.id,
      label: _itemName(item),
    }));

    // The first time we load the options, we want to select the default item
    // if specified.
    if (isFirstLoadOptionsRef.current) {
      isFirstLoadOptionsRef.current = false;

      const _selectedItem = options.find(item => item.value == defaultValues["default"]);
      if (_selectedItem) {
        setSelectedItem([_selectedItem]);
      }
    }

    return {
      options: options,
      hasMore: responseJSON.hasMore,
      additional: {
        page: page + 1,
      },
    };
  }
  console.log(defaultValues);

  return (
    <div>
      <AsyncPaginate
        defaultOptions={!!defaultValues["default"]}
        name={buildInputNameWithCondition}
        delimiter=","
        className="basic-multi-select"
        classNamePrefix="select"
        debounceTimeout={800}
        isClearable={true}
        loadingMessage={loadingMessage}
        placeholder={searchPlaceholder}
        noOptionsMessage={noOptionsMessage}
        value={selectedItem}
        loadOptions={loadOptions}
        onChange={(item) => setSelectedItem(item || [])}
        additional={{
          page: 1,
        }}
      />
    </div>
  );
}

export default SelectedReferenceSearch;
