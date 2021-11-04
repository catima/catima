import 'es6-shim';
import React from 'react';

const FontExample = (props) => {
  return (
    <div className="example">
      <b>Example: </b>
      <span style={props}>Lorem ipsum dolor sit amet, consectetur adipiscing elit.</span>
    </div>
  );
};

export default FontExample;
