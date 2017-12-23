import 'es6-shim';
import PropTypes from 'prop-types';
import React from 'react';
import 'jquery';
import '@claviska/jquery-minicolors';


function uuidv4() {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
    let r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
    return v.toString(16);
  });
}


class FontColorButton extends React.Component {
  constructor(props){
    super(props)
    this.state = {
      colorInputId: uuidv4()
    }
    this.handleChange = this._handleChange.bind(this);
  }

  componentDidMount(){
    let self = this;
    $('#'+this.state.colorInputId).minicolors({
      theme: 'bootstrap',
      change: function(value, opacity){
        self.handleChange(value);
      }
    });
  }

  componentWillUnmount(){
    $('#'+this.state.colorInputId).minicolors('destroy');
  }

  _handleChange(val){
    let newVal = {};
    newVal[this.props.elem] = val;
    this.props.onChange(newVal);
  }

  render(){
    return (
      <div className="colorButtonWrapper">
        {this.props.name}
        <div className="colorButton">
          <input id={this.state.colorInputId} type="hidden" value={this.props.value} onChange={this.handleChange} className="form-control" />
        </div>
      </div>
    );
  }
};

export default FontColorButton;
