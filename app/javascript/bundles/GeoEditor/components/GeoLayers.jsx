import 'es6-shim';
import React from 'react';
import ReactSelect from 'react-select/lib/Creatable';
import PropTypes from "prop-types";

class GeoLayers extends React.Component {
  static propTypes = {
    layers: PropTypes.array.isRequired,
    options: PropTypes.array,
    inputId: PropTypes.string.isRequired,
    placeholder: PropTypes.string.isRequired,
    noOptionsMessage: PropTypes.string.isRequired
  };

  constructor(props){
    super(props);

    this.layers = this.props.layers ? this.props.layers : [];
    this.inputId = this.props.inputId;
    this.options = this.props.options;
    this.placeholder = this.props.placeholder;
    this.noOptionsMessage = this.props.noOptionsMessage;
  }

  getSubset = (keys, obj) => keys.reduce((a, c) => ({ ...a, [c]: obj[c] }), {});

  handleSelectChange = (values) => {
    // Keep only the label et value properties
    let selection = values.map(l => this.getSubset(['label', 'value', 'attribution'], l));
    // Populate the hidden field with the selected values
    document.getElementById(this.inputId).value = JSON.stringify(selection);
  };

  getNoOptionsMessage() {
    return () => this.noOptionsMessage;
  }

  render(){
    return (
      <ReactSelect
          defaultValue={ this.layers }
          isMulti
          name="layers"
          options={ this.options }
          onChange={ this.handleSelectChange }
          className="basic-multi-select"
          classNamePrefix="select"
          placeholder={ this.placeholder }
          noOptionsMessage={ this.getNoOptionsMessage() }
      />
    );
  }
}

export default GeoLayers;
