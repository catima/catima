import React, {useState, useRef, useMemo} from "react";
import AsyncPaginate from 'react-select-async-paginate';
import striptags from 'striptags';
import Translations from '../../Translations/components/Translations';

const SelectedReferenceSearch = (props) => {
  const {
    fieldUuid,
    defaultValues,
    selectedCondition,
    itemId,
    itemsUrl,
  } = props;

  const [selectedItem, setSelectedItem] = useState([])

  const isFirstLoadOptionsRef = useRef(true);

  const buildInputNameWithCondition = useMemo(() => {
    const currentCondition = selectedCondition || 'default';
    return `advanced_search[criteria][${fieldUuid}][${itemId}][${currentCondition}]`;
  }, [fieldUuid, selectedCondition, itemId]);

  async function loadOptions(search, loadedOptions, {page}) {
    let url = `${itemsUrl}&page=${page}`;
    if (isFirstLoadOptionsRef.current && defaultValues?.["default"]) {
      url += `&default=${defaultValues["default"]}`;
    } else {
      url += `&search=${search}`;
    }

    const response = await fetch(url);
    const responseJSON = await response.json();

    const options = responseJSON.items.map(item => ({
      value: item.id,
      label: striptags(item.default_display_name),
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
        loadingMessage={() => Translations.messages['loading']}
        placeholder={Translations.messages['advanced_searches.fields.reference_search_field.item_type_placeholder']}
        noOptionsMessage={() => Translations.messages['catalog_admin.items.reference_editor.no_options']}
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
