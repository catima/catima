import 'es6-shim';
import {translations} from "../../../../assets/i18n/translations";
import {defaultMessages} from "../../../../assets/i18n/default";

const Translations = (props) => {}

Translations.messages = translations[document.querySelector('html').getAttribute('lang')] || defaultMessages;

Translations.month_names = Translations.month_names || [
    Translations.messages["month_names.january"] ?? 'January',
    Translations.messages["month_names.february"] ?? 'February',
    Translations.messages["month_names.march"] ?? 'March',
    Translations.messages["month_names.april"] ?? 'April',
    Translations.messages["month_names.may"] ?? 'May',
    Translations.messages["month_names.june"] ?? 'June',
    Translations.messages["month_names.july"] ?? 'July',
    Translations.messages["month_names.august"] ?? 'August',
    Translations.messages["month_names.september"] ?? 'September',
    Translations.messages["month_names.october"] ?? 'October',
    Translations.messages["month_names.november"] ?? 'November',
    Translations.messages["month_names.december"] ?? 'December',
];

export default Translations;
