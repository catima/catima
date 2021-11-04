import 'es6-shim';
import React from 'react';
import {translations} from "../../../../assets/i18n/translations";
import {defaultMessages} from "../../../../assets/i18n/default";

const Translations = (props) => {

  return
}

Translations.messages = translations[document.querySelector('html').getAttribute('lang')] || defaultMessages;

export default Translations;
