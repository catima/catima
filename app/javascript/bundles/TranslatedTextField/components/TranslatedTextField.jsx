import 'es6-shim';
import PropTypes from 'prop-types';
import React from 'react';


class TranslatedTextField extends React.Component {

  static propTypes = {
    input: PropTypes.string.isRequired,
    locales: PropTypes.array.isRequired,
  };

  constructor(props){
    super(props);
    this.input = props.input;
    this.locales = props.locales;
    this._value = this._inputValue();
    this._onChangeCallback = props.onChange;
    this.state = {
      disabled: this.props.disabled ? 'disabled' : '',
    };
    this.handleChange = this._handleChange.bind(this);
  }

  _inputValue(){
    let val = document.getElementById(this.input).value;
    if (val == '' || val == null) return {};
    return JSON.parse(val);
  }

  _save(){
    document.getElementById(this.input).value = JSON.stringify(this._value);
  }

  _handleChange(e){
    const locale = e.target.getAttribute('data-locale');
    this._value[locale] = e.target.value;
    this._save();
    if (this._onChangeCallback) this._onChangeCallback(this._value);
  }

  render(){
    return (
      <div className="translatedTextField form-group">
        {this.locales.map((locale, i) =>
          (
            <div key={i} className="input-group">
              <span className="input-group-addon">{locale}</span>
              <input className="form-control" data-locale={locale} type="text" value={this._value[locale]} onChange={this.handleChange} disabled={this.state.disabled} />
            </div>
          )
        )}
      </div>
    );
  }
};


export default TranslatedTextField;
