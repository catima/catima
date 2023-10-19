import 'es6-shim';
import {translations} from "../../../../assets/i18n/translations";
import {defaultMessages} from "../../../../assets/i18n/default";

const Translations = (props) => {}

Translations.messages = translations[document.querySelector('html').getAttribute('lang')] || defaultMessages;

export default Translations;
