import 'es6-shim';
import PropTypes from 'prop-types';
import React from 'react';


class GeoEditor extends React.Component {

  static propTypes = {};

  constructor(props){
    super(props);
    this.state = {};
  }

  render(){
    return (
      <div className="geoEditor">
        <p>GeoEditor control</p>
      </div>
    );
  }

};

export default GeoEditor;
