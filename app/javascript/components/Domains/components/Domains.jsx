import 'es6-shim';
import PropTypes from "prop-types";
import React, {useEffect, useState} from 'react';
import ReactSelect from 'react-select';

const selectStyles = {menu: styles => ({...styles, zIndex: 2000})};

const Domains = (props) => {
  const {
    domains: domainsProps,
    inputId,
    options,
    placeholder,
    noOptionsMessage,
  } = props

  const [domains, setDomains] = useState(domainsProps ? domainsProps : [])

  useEffect(() => {
    setDomains(domainsProps ? domainsProps : [])
  }, domainsProps)

  function getSubset(keys, obj) {
    return keys.reduce((a, c) => ({...a, [c]: obj[c]}), {})
  }

  function handleSelectChange(values) {
    let v = values == null ? [] : values
    // Keep only label, value & attribution properties
    let selection = v.map(l => getSubset(['label', 'value'], l));
    // Populate the hidden field with the selected values
    document.getElementById(inputId).value = JSON.stringify(selection);
  }

  function getNoOptionsMessage() {
    return () => noOptionsMessage;
  }

  return (
    <ReactSelect
      styles={selectStyles}
      defaultValue={domains}
      isMulti
      isSearchable={true}
      isClearable={true}
      name="domains"
      options={options}
      onChange={handleSelectChange}
      className="basic-multi-select"
      classNamePrefix="select"
      placeholder={placeholder}
      noOptionsMessage={getNoOptionsMessage()}
    />
  );
}

Domains.propTypes = {
  domains: PropTypes.array.isRequired,
  options: PropTypes.array,
  inputId: PropTypes.string.isRequired,
  placeholder: PropTypes.string.isRequired,
  noOptionsMessage: PropTypes.string.isRequired
}

export default Domains;
