import 'es6-shim';
import React from 'react';
import { translations } from "../../../../assets/i18n/translations";
import { defaultMessages } from "../../../../assets/i18n/default";

class Translations extends React.Component {
  static messages = translations[document.querySelector('html').getAttribute('lang')] || defaultMessages;

  constructor(props){
    super(props)
  }

  render(){}
}

export default Translations;
