import 'es6-shim';
import React from 'react';

class FontExample extends React.Component {
  constructor(props){
    super(props)
  }

  render(){
    return (
      <div className="example">
        <b>Example: </b>
        <span style={this.props}>Lorem ipsum dolor sit amet, consectetur adipiscing elit.</span>
      </div>
    );
  }
};

export default FontExample;