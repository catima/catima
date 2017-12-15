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
    this.state = {
      value: this._inputValue(),
    };
    this.handleChange = this._handleChange.bind(this);
  }

  _inputValue(){
    let val = document.getElementById(this.input).value;
    if (val == '' || val == null) return {};
    return JSON.parse(val);
  }

  _save(){
    document.getElementById(this.input).value = JSON.stringify(this.state.value);
  }

  _handleChange(e){
    const locale = e.target.getAttribute('data-locale');
    const newValue = this.state.value;
    newValue[locale] = e.target.value;
    this.setState({value: newValue});
    this._save();
  }

  render(){
    return (
      <div className="translatedTextField form-group">
        {this.locales.map((locale, i) =>
          (
            <div key={i} className="input-group">
              <span className="input-group-addon">{locale}</span>
              <input className="form-control" data-locale={locale} type="text" value={this.state.value[locale]} onChange={this.handleChange} />
            </div>
          )
        )}
      </div>
    );
  }
};


export default TranslatedTextField;
