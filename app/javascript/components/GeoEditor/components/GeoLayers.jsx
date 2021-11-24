import 'es6-shim';
import PropTypes from "prop-types";
import React, {useEffect, useState} from 'react';
import Creatable, { makeCreatableSelect } from 'react-select/creatable';

const selectStyles = {menu: styles => ({...styles, zIndex: 2000})};

const GeoLayers = (props) => {
  const {
    layers: layersProps,
    inputId,
    options,
    placeholder,
    noOptionsMessage,
  } = props

  const [layers, setLayers] = useState(layersProps ? layersProps : [])

  useEffect(() => {
    setLayers(layersProps ? layersProps : [])
  }, layersProps)

  function getSubset(keys, obj) {
    return keys.reduce((a, c) => ({...a, [c]: obj[c]}), {})
  }

  function handleSelectChange(values) {
    if (!values) {
      document.getElementById(inputId).value = '';
      return;
    }

    // Keep only label, value & attribution properties
    let selection = values.map(l => getSubset(['label', 'value', 'attribution'], l));
    // Populate the hidden field with the selected values
    document.getElementById(inputId).value = JSON.stringify(selection);
  }

  function getNoOptionsMessage() {
    return () => noOptionsMessage;
  }

  return (
    <Creatable
      styles={selectStyles}
      defaultValue={layers}
      isMulti
      isSearchable={true}
      isClearable={true}
      name="layers"
      options={options}
      onChange={handleSelectChange}
      className="basic-multi-select"
      classNamePrefix="select"
      placeholder={placeholder}
      noOptionsMessage={getNoOptionsMessage()}
    />
  );
}

GeoLayers.propTypes = {
  layers: PropTypes.array.isRequired,
  options: PropTypes.array,
  inputId: PropTypes.string.isRequired,
  placeholder: PropTypes.string.isRequired,
  noOptionsMessage: PropTypes.string.isRequired
}

export default GeoLayers;
