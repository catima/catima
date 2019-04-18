import 'es6-shim';
import React from 'react';
import ReactSelect from 'react-select/lib/Creatable';

class GeoLayers extends React.Component {
  getSubset = (keys, obj) => keys.reduce((a, c) => ({ ...a, [c]: obj[c] }), {});

  constructor(props){
    super(props);
  }

  handleSelectChange = (values) => {
    // Keep only the label et value properties
    let selection = values.map(l => this.getSubset(['label', 'value', 'attribution'], l));
    // Populate the hidden field with the selected values
    document.getElementById('field_layers').value = JSON.stringify(selection);
  };

  getNoOptionsMessage() {
    return () => this.props.noOptionsMessage;
  }

  render(){
    return (
      <ReactSelect
          defaultValue={ this.props.layers }
          isMulti
          name="layers"
          options={ this.props.options }
          onChange={ this.handleSelectChange }
          className="basic-multi-select"
          classNamePrefix="select"
          placeholder={ this.props.placeholder }
          noOptionsMessage={ this.getNoOptionsMessage() }
      />
    );
  }
}

export default GeoLayers;
