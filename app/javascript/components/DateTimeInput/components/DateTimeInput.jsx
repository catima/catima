import 'es6-shim';
import PropTypes from 'prop-types';
import React, {useState, useEffect} from 'react';
import Translations from '../../Translations/components/Translations';

const DateTimeInput = (props) => {
  const defaultValues = {Y: "", M: "", D: "", h: "", m: "", s: ""};
  const types = ["Y", "M", "h", "YM", "MD", "hm", "YMD", "hms", "MDh", "YMDh", "MDhm", "YMDhm", "MDhms", "YMDhms"];

  const {
    input,
    allowBC,
    preventNegativeInput
  } = props

  const [state, setState] = useState(false)
  const [date, setDate] = useState(getData())
  const [granularity, setGranularity] = useState(getFieldOptions().format)
  const [isRequired, setIsRequired] = useState(false)

  useEffect(() => {
    if (document.querySelector(input) !== null) {
      setIsRequired(document.querySelector(input).getAttribute('data-field-required') == 'true')
    }

    if (jQuery.isEmptyObject(getData())) return initData(defaultValues, getFieldOptions().format);
  }, [])

  useEffect(() => {
    let s = {}
    for (let i in granularity) {
      let k = granularity[i];
      s[k] = date[k] || (defaultValues)[k];
    }
    s['BC'] = date['BC'] || false
    setState(s);

  }, [granularity])

  let dateValid = isCurrentFormatValid();
  let errorStl = dateValid ? {} : {border: "2px solid #f00"};
  let errorMsg = dateValid ? "" : "Invalid value";
  let fmt = getFieldOptions().format;

  function _handleChangeDay(e) {
    let v = parseInt(e.target.value);
    if (v < 1 || v > 31) return;
    if (isNaN(v)) v = "";
    updateData({D: v});
  }

  function _handleChangeMonth(e) {
    let v = parseInt(e.target.value);
    if (v < 1 || v > 12) return;
    if (isNaN(v)) v = "";
    updateData({M: v});
  }

  function _handleChangeYear(e) {
    let v = parseInt(e.target.value);
    if (isNaN(v)) v = "";
    updateData({Y: v});
  }

  function _handleChangeHours(e) {
    let v = parseInt(e.target.value);
    if (v < 0 || v > 23) return;
    if (isNaN(v)) v = "";
    updateData({h: v});
  }

  function _handleChangeMinutes(e) {
    let v = parseInt(e.target.value);
    if (v < 0 || v > 59) return;
    if (isNaN(v)) v = "";
    updateData({m: v});
  }

  function _handleChangeSeconds(e) {
    let v = parseInt(e.target.value);
    if (v < 0 || v > 59) return;
    if (isNaN(v)) v = "";
    updateData({s: v});
  }

  function initData(data, format) {
    let dt = {};
    for (let i in data) {
      dt[i] = format.includes(i) ? data[i] || "" : null;
    }
    updateData(dt);
  }

  function updateData(h) {
    setState(state? {...state, ...h}: h);
    const d = getData();
    for (let k in h) d[k] = h[k];
    setData(d);
  }

  function getData() {
    const value = getInput().val();
    if (!value) return {};
    let v = JSON.parse(value);
    return v.raw_value ? rawValueToDateTime(v.raw_value) : v;
  }

  function rawValueToDateTime(v) {
    const dt = new Date(v * 1000);
    return {
      Y: dt.getFullYear(),
      M: dt.getMonth() + 1,
      D: dt.getDate(),
      h: dt.getHours(),
      m: dt.getMinutes(),
      s: dt.getSeconds()
    };
  }

  function setData(d) {
    getInput().val(JSON.stringify(d));
  }

  function getInput() {
    return $(input);
  }

  function getAllowedFormats() {
    const granularity = getFieldOptions().format;
    return types.filter(obj => {
      if (granularity.includes(obj) || granularity == obj) return obj;
    });
  }

  function getCurrentFormat() {
    let d = getData();
    let f = getFieldOptions().format;
    return f.split('').map(function (k) {
      return d[k] ? k : '';
    }).join('')
  }

  function isCurrentFormatValid() {
    let current = getCurrentFormat();
    if (current == '' && !isRequired) return true;   // allow empty value if field is not required
    let allowed = getAllowedFormats();
    return allowed.indexOf(current) > -1;
  }

  function getFieldOptions() {
    return getInput().data("field-options") || {format: 'YMD'};
  }

  function _handleChangeBC() {
    return function (e) {
      updateData({BC: e.target.checked});
    }
  }

  if (!state) return ""
  return (
    <div>
      <div className="dateTimeInput rails-bootstrap-forms-datetime-select">
        {allowBC ? (
          <div className="form-check" style={{display: 'inline-block', marginRight: '3rem', paddingLeft: '0'}}>
            <label className="form-check-label"
                   htmlFor={`bcCheck`}>{Translations.messages['catalog_admin.fields.complex_datation_option_inputs.BC']}</label>
            <input type="checkbox" value={true} className="form-check-input" id={`bcCheck`}
                   checked={state.BC}
                   onChange={_handleChangeBC()}/>
          </div>
        ) : null}
        {fmt.includes('D') ? (
          <input style={errorStl} type="number" min="0" max="31" className="input-2 form-control" value={state.D}
                 onChange={_handleChangeDay}/>
        ) : null
        }
        {fmt.includes('M') ? (
          <select style={errorStl} className="form-control" value={state.M} onChange={_handleChangeMonth}>
            <option value=""></option>
            <option value="1">
              {Translations.messages['catalog_admin.fields.date_time_option_inputs.months.january']}
            </option>
            <option value="2">
              {Translations.messages['catalog_admin.fields.date_time_option_inputs.months.february']}
            </option>
            <option value="3">
              {Translations.messages['catalog_admin.fields.date_time_option_inputs.months.march']}
            </option>
            <option value="4">
              {Translations.messages['catalog_admin.fields.date_time_option_inputs.months.april']}
            </option>
            <option value="5">
              {Translations.messages['catalog_admin.fields.date_time_option_inputs.months.may']}
            </option>
            <option value="6">
              {Translations.messages['catalog_admin.fields.date_time_option_inputs.months.june']}
            </option>
            <option value="7">
              {Translations.messages['catalog_admin.fields.date_time_option_inputs.months.july']}
            </option>
            <option value="8">
              {Translations.messages['catalog_admin.fields.date_time_option_inputs.months.august']}
            </option>
            <option value="9">
              {Translations.messages['catalog_admin.fields.date_time_option_inputs.months.september']}
            </option>
            <option value="10">
              {Translations.messages['catalog_admin.fields.date_time_option_inputs.months.october']}
            </option>
            <option value="11">
              {Translations.messages['catalog_admin.fields.date_time_option_inputs.months.november']}
            </option>
            <option value="12">
              {Translations.messages['catalog_admin.fields.date_time_option_inputs.months.december']}
            </option>
          </select>) : null
        }
        {fmt.includes('Y') ? (
          <input style={errorStl} type="number" min={preventNegativeInput ? "0" : "" } className="input-4 margin-right form-control" value={state.Y}
                 onChange={_handleChangeYear}/>
        ) : null
        }
        {fmt.includes('h') ? (
          <input style={errorStl} min="0" max="23" type="number" className="input-2 form-control" value={state.h}
                 onChange={_handleChangeHours}/>
        ) : null
        }
        {fmt.includes('m') ? (
          <input style={errorStl} min="0" max="59" type="number" className="input-2 form-control" value={state.m}
                 onChange={_handleChangeMinutes}/>
        ) : null
        }
        {fmt.includes('s') ? (
          <input style={errorStl} min="0" max="59" type="number" className="input-2 form-control" value={state.s}
                 onChange={_handleChangeSeconds}/>
        ) : null
        }
      </div>
      <span className="error helptext">{errorMsg}</span>
    </div>
  );
};

DateTimeInput.propTypes = {
  input: PropTypes.string.isRequired,
}

export default DateTimeInput;
