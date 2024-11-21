import 'es6-shim';
import PropTypes from "prop-types";
import React, {useEffect, useState} from 'react';
import axios from "axios";
import ReactSelect from 'react-select';

const GeoFields = (props) => {
  const {
    defaults,
    inputId,
    itemTypeId,
    placeholder,
    noOptionsMessage,
    fetchUrl,
  } = props

  const [selectedValues, setSelectedValues] = useState(defaults || []);
  const [options, setOptions] = useState([]);
  const [isOptionsFetching, setIsOptionsFetching] = useState(false);

  const promiseOptions = async (itemTypeId) => {
    if (!itemTypeId) {
        return [];
    }
    setIsOptionsFetching(true);
    const res = await axios.get(fetchUrl.replace('item_types_id', itemTypeId));
    setIsOptionsFetching(false);
    return res.data.map(option => ({ label: option.name, value: option.id }));
  };

  const handleItemTypeSelectChange = (event) => {
    setSelectedValues([]);
    document.getElementById(inputId).value = '';
    promiseOptions(event.target.value).then((options) => setOptions(options));
  };

  useEffect(() => {
    const selectElement = document.getElementById(itemTypeId);
    let _itemTypeId = itemTypeId;

    if (selectElement) {
        // Listen to the change event of the item type select.
        selectElement.addEventListener('change', handleItemTypeSelectChange);
        _itemTypeId = selectElement.value;
    }

    // Initialize the options based on the default item type.
    promiseOptions(_itemTypeId).then((options) => setOptions(options));

    // Force the hidden input value to be updated according to the possible values.
    // This is usefull when the input value is invalid (if the geo field
    // were removed for example).
    updateInputValue(selectedValues);

    return () => {
      if (selectElement) {
        selectElement.removeEventListener('change', handleItemTypeSelectChange);
      }
    };
  }, []);

  function handleSelectChange(values) {
    // Needed because we manage ourself the selected values since we
    // passed the `selectedValues` state to the ReactSelect prop `value`.
    setSelectedValues(values || []);

    updateInputValue(values);
  }

  function updateInputValue(value) {
    if (!value) {
      document.getElementById(inputId).value = '';
      return;
    }

    document.getElementById(inputId).value = JSON.stringify(value.map(v => v.value));
  }

  return (
    <ReactSelect
      isDisabled={isOptionsFetching}
      isSearchable={true}
      styles={{menu: styles => ({...styles, zIndex: 2000})}}
      value={selectedValues}
      options={options}
      isMulti
      isClearable={true}
      name="geo-fields"
      onChange={handleSelectChange}
      className="basic-multi-select"
      classNamePrefix="select"
      placeholder={placeholder}
      noOptionsMessage={() => noOptionsMessage}
      closeMenuOnSelect={false}
    />
  );
}

GeoFields.propTypes = {
  defaults: PropTypes.array.isRequired,
  inputId: PropTypes.string.isRequired,

  // Can be the id of an HTML input element or the id of the `itemtype` directly.
  // If it's the id of the HTML input element, it will take the value of this
  // element as `itemtype` id and listen on the change event of this input to
  // update the options accordingly.
  itemTypeId: PropTypes.string.isRequired,

  placeholder: PropTypes.string.isRequired,
  noOptionsMessage: PropTypes.string.isRequired,
  fetchUrl: PropTypes.string.isRequired,
}

export default GeoFields;
