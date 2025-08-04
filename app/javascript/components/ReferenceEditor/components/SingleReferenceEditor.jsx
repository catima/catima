import React, {useState, useEffect, useMemo} from 'react';
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

  const [selectedItem, setSelectedItem] = useState(null)
  const [selectedFilter, setSelectedFilter] = useState(null)
  const [isValid, setIsValid] = useState(Validation.isValid(req, srcRef, 'SingleReferenceEditor'))

  const editorId = `${srcRef}-editor`;
  const filterId = `${srcRef}-filters`;

  const getItemName = (item) => {
    if (!selectedFilter || !item[selectedFilter.value]) {
      return striptags(item.default_display_name);
    }
    return `${striptags(item.default_display_name)} - ${item[selectedFilter.value]}`;
  }

  const getJSONItem = (item) => ({
    value: item.id,
    label: getItemName(item)
  });

  const filterOptions = useMemo(() =>
    fields
      .filter(field => field.human_readable)
      .map(field => ({value: field.slug, label: field.name})),
    [fields]
  );

  // Initialize selected item
  useEffect(() => {
    if (selectedReference?.length === 1) {
      setSelectedItem(getJSONItem(selectedReference[0]));
    }
  }, [selectedReference]);

  // Update selected item when filter changes
  useEffect(() => {
    if (selectedItem && selectedReference?.length === 1) {
      setSelectedItem(getJSONItem(selectedReference[0]));
    }
  }, [selectedFilter]);

  // Save to DOM
  useEffect(() => {
    const domElement = document.getElementById(srcRef);
    if (domElement) {
      const value = selectedItem?.value ? JSON.stringify(selectedItem.value) : '';
      domElement.value = value;
      setIsValid(Validation.isValid(req, srcRef, 'SingleReferenceEditor'));
    }
  }, [selectedItem, req, srcRef]);

  const handleSelectItem = (item, event) => {
    if (!event || event.action !== "pop-value" || !req) {
      setSelectedItem(item || null);
    }
  };

  const handleSelectFilter = (filter) => {
    setSelectedFilter(filter);
  };

  const loadOptions = async (search, loadedOptions, {page}) => {
    if (itemsProps.length < 25) {
      const regex = new RegExp(search, 'i');
      const options = itemsProps
        .map(item => getJSONItem(item))
        .filter(item => !search || (item.label && regex.test(item.label)));

      return {
        options,
        hasMore: false,
        additional: { page }
      };
    }

    if (itemsProps.length === 25) {
      const response = await fetch(`${itemsUrl}?search=${search}&page=${page}`);
      const data = await response.json();

      return {
        options: data.items.map(item => getJSONItem(item)),
        hasMore: data.hasMore,
        additional: { page: page + 1 }
      };
    }

    return { options: [], hasMore: false, additional: { page } };
  };

  return (
    <div className="input-group single-reference-container"
         style={Validation.getStyle(req, srcRef, 'SingleReferenceEditor')}
    >
      <AsyncPaginate
        key={selectedFilter?.value || 'no-filter'} // Force re-render when filter changes
        id={editorId}
        className="single-reference flex-fill"
        debounceTimeout={800}
        isClearable={!req}
        isMulti={false}
        isSearchable={true}
        loadingMessage={() => loadingMessage}
        loadOptions={loadOptions}
        onChange={handleSelectItem}
        placeholder={searchPlaceholder}
        noOptionsMessage={noOptionsMessage}
        value={selectedItem}
        additional={{ page: 1 }}
      />
      <div className="input-group-addon">
        <ReactSelect
          id={filterId}
          className="single-reference-filter"
          isSearchable={false}
          isClearable={true}
          value={selectedFilter}
          onChange={handleSelectFilter}
          options={filterOptions}
          placeholder={filterPlaceholder}
          noOptionsMessage={noOptionsMessage}
          styles={filterDropdownStyle}
        />
      </div>
    </div>
  )
}

export default SingleReferenceEditor;
