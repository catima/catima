import 'es6-shim';
import PropTypes from 'prop-types';
import React, {useState, useEffect} from 'react';
import Translations from '../../Translations/components/Translations';
import AsyncPaginate from 'react-select-async-paginate';
import axios from "axios";

const ComplexDatationInput = (props) => {
  const defaultValues = {Y: "", M: "", D: "", h: "", m: "", s: ""};
  const types = ["Y", "M", "h", "YM", "MD", "hm", "YMD", "hms", "MDh", "YMDh", "MDhm", "YMDhm", "MDhms", "YMDhms"];

  const {
    input,
    fetchUrl,
    selectedChoicesValue: selectedChoicesValueProps,
    selectedFormat: selectedFormatProps
  } = props

  const [state, setState] = useState(false)
  const [fromState, setFromState] = useState(false)
  const [toState, setToState] = useState(false)
  const [date, setDate] = useState(getData())
  const [granularity, setGranularity] = useState(getFieldOptions().format)
  const [isRequired, setIsRequired] = useState(false)

  const [allowedFormats, setAllowedFormats] = useState(getFieldOptions().allowed_formats.filter(f => f != ''))
  const [selectedFormat, setSelectedFormat] = useState(selectedFormatProps[0])
  const [allowBC, setAllowBC] = useState(getFieldOptions().allow_bc == '1' ? true : false)

  const [choices, setChoices] = useState([])
  const [isLoading, setIsLoading] = useState(false)
  const [loadingMessage, setLoadingMessage] = useState("")
  const [isInitialized, setIsInitialized] = useState(false)
  const [optionsList, setOptionsList] = useState([])
  const [selectedChoices, setSelectedChoices] = useState({BC: false, value: selectedChoicesValueProps})

  useEffect(() => {
    setSelectedFormat(selectedFormatProps[0])
  }, [selectedFormatProps])

  const setSelectedFormatAndUpdateData = (format) => {
    setSelectedFormat(format);
    if (format == 'date_time') {
      setData({...getData(), 'selected_format': format, selected_choices: {}, from: fromState, to: toState})
    } else {
      setData({...getData(), 'selected_format': format, selected_choices: selectedChoices, from: {}, to: {}})
    }
  }

  const renderAllowedFormatsSelector = () => {
    if (allowedFormats.length == 2) {
      return (
        allowedFormats.map((allowedFormat, idx) => (
          <div className="form-check" key={`allowedFormat-${idx}`}>
            <input className="form-check-input" type="radio" name="allowedFormat" id={`allowedFormat-${idx}`}
                   checked={selectedFormat === allowedFormat}
                   onChange={() => setSelectedFormatAndUpdateData(allowedFormat)}/>
            <label className=" form-check-label"
                   htmlFor={`allowedFormat-${idx}`}>{Translations.messages[`catalog_admin.fields.complex_datation_option_inputs.${allowedFormat}`]}</label>
          </div>
        ))
      )
    } else {
      return ''
    }
  }

  useEffect(() => {
    if (document.querySelector(input) !== null) {
      setIsRequired(document.querySelector(input).getAttribute('data-field-required') == 'true')
    }

    if (jQuery.isEmptyObject(getData()['from'])) return initData(defaultValues, getFieldOptions().format);
  }, [])

  const dateFromGranularityAndDate = (input) => {
    let s = {}
    for (let i in granularity) {
      let k = granularity[i];
      s[k] = date[input][k] || (defaultValues)[k];
    }
    s['BC'] = date[input]['BC'] || false
    return s
  }

  useEffect(() => {
    if (date['selected_format']) {
      setSelectedFormat(date['selected_format'])
    } else {
      setSelectedFormat(selectedFormatProps[0])
      setData({...getData(), 'selected_format': selectedFormatProps[0]})
    }
    setSelectedChoices(date['selected_choices'] ? {
      ...date['selected_choices'],
      value: selectedChoicesValueProps
    } : {BC: false, value: []})

    let from = dateFromGranularityAndDate('from')
    setFromState(from);
    let to = dateFromGranularityAndDate('to')
    setToState(to);
  }, [granularity])

  let dateValid = isCurrentFormatValid();
  let errorStl = dateValid ? {} : {border: "2px solid #f00"};
  let errorMsg = dateValid ? "" : "Invalid value";
  let fmt = getFieldOptions().format;

  function _handleChangeBC(input) {
    return function (e) {
      updateDateData(input, {BC: e.target.checked});
    }
  }


  function _handleChangeDay(input) {
    return function (e) {
      let v = parseInt(e.target.value);
      if (v < 1 || v > 31) return;
      if (isNaN(v)) v = "";
      updateDateData(input, {D: v});
    }
  }

  function _handleChangeMonth(input) {
    return function (e) {
      let v = parseInt(e.target.value);
      if (v < 1 || v > 12) return;
      if (isNaN(v)) v = "";
      updateDateData(input, {M: v});
    }
  }

  function _handleChangeYear(input) {
    return function (e) {
      let v = parseInt(e.target.value);
      if (isNaN(v)) v = "";
      updateDateData(input, {Y: v});
    }
  }

  function _handleChangeHours(input) {
    return function (e) {
      let v = parseInt(e.target.value);
      if (v < 0 || v > 23) return;
      if (isNaN(v)) v = "";
      updateDateData(input, {h: v});
    }
  }

  function _handleChangeMinutes(input) {
    return function (e) {
      let v = parseInt(e.target.value);
      if (v < 0 || v > 59) return;
      if (isNaN(v)) v = "";
      updateDateData(input, {m: v});
    }
  }

  function _handleChangeSeconds(input) {
    return function (e) {
      let v = parseInt(e.target.value);
      if (v < 0 || v > 59) return;
      if (isNaN(v)) v = "";
      updateDateData(input, {s: v});
    }
  }

  function initData(data, format) {
    let dt = {};
    for (let i in data) {
      dt[i] = format.includes(i) ? data[i] || "" : null;
    }
    updateDateData('from', {...dt, BC: false});
    updateDateData('to', {...dt, BC: false});
  }

  function updateDateData(input, h) {
    let newState
    if (input == 'from') {
      setFromState(fromState ? {...fromState, ...h} : h);
      newState = {from: fromState ? {...fromState, ...h} : h}
    } else if (input == 'to') {
      setToState(toState ? {...toState, ...h} : h);
      newState = {to: toState ? {...toState, ...h} : h}
    }

    setState(state ? {...state, ...newState} : newState);
    const d = getData();

    if (input == 'from') {
      for (let k in h) d['from'][k] = h[k];
    } else {
      for (let k in h) d['to'][k] = h[k];
    }

    setData(d);
  }

  function updateChoiceData(arr) {
    const d = getData();
    d['selected_choices'] = arr;
    setData({...getData(), 'selected_choices': {BC: selectedChoices.BC, value: arr}})
  }

  function _handleSelectedChoicesChangeBC(e) {
    setSelectedChoices({...selectedChoices, BC: e.target.checked})
    setData({...getData(), 'selected_choices': {...getData().selected_choices, BC: e.target.checked}})
  }

  function getData() {
    const value = getInput().val();
    if (!value) return {'from': {}, 'to': {}};
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
      return d['from'][k] ? k : d['to'][k] ? k : '';
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


  async function _loadOptions(search, loadedOptions, {page}) {
    if (optionsList.length < 25 && isInitialized) {
      if (search.length > 0) {
        let regexExp = new RegExp(search, 'i')

        let choices = optionsList.filter(function (choice) {
          return choice.label !== null && choice.label.match(regexExp) !== null && choice.label.match(regexExp).length > 0
        });
        return {
          options: choices,
          hasMore: false,
          additional: {
            page: page,
          },
        };
      }
      return {
        options: _getFilterOptions(),
        hasMore: choices.length === 25,
        additional: {
          page: page,
        },
      };
    }


    const res = await axios.get(fetchUrl)
    if (!isInitialized) {
      setChoices(res.data.choices)
      setIsLoading(false)
      setLoadingMessage(res.data.loading_message)
      setIsInitialized(search.length === 0)
      setOptionsList(res.data.choices.map(choice => _getJSONFilter(choice)))

      return {
        options: _getFilterOptions(res.data.choices),
        hasMore: false,
        additional: {
          page: page + 1,
        },
      };
    }
  }

  function _getFilterOptions(providedChoices = false) {
    let computedChoices = providedChoices ? providedChoices : choices
    computedChoices = computedChoices.map(choice =>
      _getJSONFilter(choice)
    );

    return computedChoices;
  }

  function _getJSONFilter(choice) {
    return {value: choice.id, label: choice.short_name};
  }

  function selectChoice(value) {
    setSelectedChoices({...selectedChoices, value: value});
    updateChoiceData(value.map(v => v.value))
  }

  const renderDateTimeInput = (input) => {
    return (
      <div className="dateTimeInput rails-bootstrap-forms-datetime-select">
        {allowBC ? (
          <div className="form-check" style={{display: 'inline-block', marginRight: '3rem', paddingLeft: '0'}}>
            <label className="form-check-label"
                   htmlFor={`bcCheck-${input}`}>{Translations.messages['catalog_admin.fields.complex_datation_option_inputs.BC']}</label>
            <input type="checkbox" value={true} className="form-check-input" id={`bcCheck-${input}`}
                   checked={input == 'from' ? fromState.BC : toState.BC}
                   onChange={_handleChangeBC(input)}/>
          </div>
        ) : null}
        {fmt.includes('D') ? (
          <input style={errorStl} type="number" min="0" max="31" className="input-2 form-control"
                 value={input == 'from' ? fromState.D : toState.D}
                 onChange={_handleChangeDay(input)}/>
        ) : null
        }
        {fmt.includes('M') ? (
          <select style={errorStl} className="form-control" value={input == 'from' ? fromState.M : toState.M}
                  onChange={_handleChangeMonth(input)}>
            <option value=""></option>
            <option value="1">
              {Translations.messages['catalog_admin.fields.date_time_option_inputs.months.january']}
            </option>
            <option value="2">
              {Translations.messages['catalog_admin.fields.date_time_option_inputs.months.fabruary']}
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
          <input style={errorStl} className="input-4 margin-right form-control"
                 value={input == 'from' ? fromState.Y : toState.Y}
                 onChange={_handleChangeYear(input)}/>
        ) : null
        }
        {fmt.includes('h') ? (
          <input style={errorStl} min="0" max="23" type="number" className="input-2 form-control"
                 value={input == 'from' ? fromState.h : toState.h}
                 onChange={_handleChangeHours(input)}/>
        ) : null
        }
        {fmt.includes('m') ? (
          <input style={errorStl} min="0" max="59" type="number" className="input-2 form-control"
                 value={input == 'from' ? fromState.m : toState.m}
                 onChange={_handleChangeMinutes(input)}/>
        ) : null
        }
        {fmt.includes('s') ? (
          <input style={errorStl} min="0" max="59" type="number" className="input-2 form-control"
                 value={input == 'from' ? fromState.s : toState.s}
                 onChange={_handleChangeSeconds(input)}/>
        ) : null
        }
      </div>
    )
  }

  if (!fromState || !toState) return ""
  return (
    <div>
      <div>{renderAllowedFormatsSelector()}</div>
      {selectedFormat == 'date_time' && (
        <div>
          <div>{renderDateTimeInput('from')}</div>
          <div>{renderDateTimeInput('to')}</div>
          <span className="error helptext">{errorMsg}</span>
        </div>
      )}
      {selectedFormat == 'datation_choice' && (
        <div className="dateTimeInput rails-bootstrap-forms-datetime-select" style={{display: 'flex'}}>
          {allowBC && (
            <div className="form-check" style={{display: 'inline-block', marginRight: '3rem', paddingLeft: '0'}}>
              <label className="form-check-label"
                     htmlFor={`bcCheck-selected-choices`}>{Translations.messages['catalog_admin.fields.complex_datation_option_inputs.BC']}</label>
              <input type="checkbox" value={true} className="form-check-input" id={`bcCheck-selected-choices`}
                     checked={selectedChoices.BC}
                     onChange={_handleSelectedChoicesChangeBC}/>
            </div>
          )}
          <div style={{width: '100%'}}>
            <AsyncPaginate
              className="single-reference-filter"
              delimiter=","
              loadOptions={_loadOptions}
              debounceTimeout={800}
              isSearchable={true}
              isClearable={true}
              isMulti={true}
              loadingMessage={() => loadingMessage}
              additional={{
                page: 1,
              }}
              styles={{menuPortal: base => ({...base, zIndex: 9999})}}
              name="choices"
              value={selectedChoices.value}
              onChange={selectChoice}
              options={_getFilterOptions(selectedChoices.value)}
            />
          </div>
        </div>

      )}
    </div>
  )
}

ComplexDatationInput.propTypes = {
  input: PropTypes.string.isRequired,
}

export default ComplexDatationInput;
