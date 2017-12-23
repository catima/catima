import 'es6-shim';
import PropTypes from 'prop-types';
import React from 'react';
import FontMenu from './FontMenu';
import FontSize from './FontSize';
import FontStyle from './FontStyle';
import FontColorButton from './FontColorButton';
import FontExample from './FontExample';

class StyleControl extends React.Component {
  constructor(props){
    super(props)
    this.state = $.extend(
      {
        fontFamily: '', 'fontSize': '',
        fontWeight: 'normal', fontStyle: 'normal', textDecoration: 'none',
        color: '', 'backgroundColor': ''
      },
      this.getData()
    );
    this.handleChange = this._handleChange.bind(this);
  }

  getData(){
    const value = this.getInput().val();
    if (value === '') {
      return {};
    }
    const v = JSON.parse(value);
    return (this.props.element ? v[this.props.element] : v);
  }

  setData(d){
    const dobj = $.extend(this.getData(), d);
    let s = JSON.parse(this.getInput().val() || {});
    if (this.props.element) {
      s[this.props.element] = dobj;
    } else {
      s = dobj
    }
    this.getInput().val(JSON.stringify(s));
  }

  getInput(){
    return $(this.props.input);
  }

  _handleChange(d){
    this.setState(d);
    this.setData(d);
  }

  render(){
    return (
      <div>
        <FontMenu value={this.state.fontFamily} onChange={this.handleChange} />
        <FontSize value={this.state.fontSize} onChange={this.handleChange} />
        <FontStyle
          fontWeight={this.state.bold}
          fontStyle={this.state.italic}
          textDecoration={this.state.underline}
          onChange={this.handleChange}
        />
        <FontColorButton
          name="Font color:"
          elem="color"
          value={this.state.color}
          onChange={this.handleChange}
        />
        <FontColorButton
          name="Background color:"
          elem="backgroundColor"
          value={this.state.backgroundColor}
          onChange={this.handleChange}
        />
        <FontExample
          fontFamily={this.state.fontFamily}
          fontSize={this.state.fontSize}
          fontWeight={this.state.bold}
          fontStyle={this.state.italic}
          textDecoration={this.state.underline}
          color={this.state.color}
          backgroundColor={this.state.backgroundColor}
        />

      </div>
    );
  }
};

export default StyleControl;
