import 'es6-shim';
import PropTypes from 'prop-types';
import React, {useState, useEffect, useRef, forwardRef} from 'react';
import $ from 'jquery';
import 'moment';
import 'bootstrap4-datetimepicker'
import Translations from "../../Translations/components/Translations";

const DateTimeInput = forwardRef((props, ref) => {
  const {
    disabled: disabledProps,
    isRange: isRangeProps,
    input,
    localizedDateTimeData: localizedDateTimeDataProps,
    format,
    datepicker,
    locale,
    req,
    inputId,
    inputSuffixId,
    inputName,
    allowBC,
    list,
    item,
    addComponent,
    deleteComponent
  } = props

  const {topRef, hiddenInputRef} = ref
  const selectRef = useRef()

  const defaultValues = {Y: '', M: '', D: '', h: '', m: '', s: ''};
  const types = ['Y', 'M', 'h', 'YM', 'MD', 'hm', 'YMD', 'hms', 'MDh', 'YMDh', 'MDhm', 'YMDhm', 'MDhms', 'YMDhms'];

  const [disabled, setDisabled] = useState(disabledProps)
  const [isRange, setIsRange] = useState(isRangeProps)
  const [selectedDate, setSelectedDate] = useState('')
  const [isDatepickerOpen, setIsDatepickerOpen] = useState(false)
  const [localizedDateTimeData, setLocalizedDateTimeData] = useState([])
  const [date, setDate] = useState(getData())
  const [granularity, setGranularity] = useState(getFieldOptions().format)
  const [styleMarginRight, setStyleMarginRight] = useState('')
  const [isRequired, setIsRequired] = useState(false)
  const [state, setState] = useState(false)
  const [initState, setInitState] = useState(false)

  let dateValid = isCurrentFormatValid()
  let errorStl = dateValid ? {} : {border: "2px solid #f00"};
  let errorMsg = dateValid ? "" : "Invalid value"
  let fmt = getFieldOptions().format;

  useEffect(() => {
    let s = {}
    for (let i in granularity) {
      let k = granularity[i];
      s[k] = date[k] || (defaultValues)[k];
    }
    setState(s);
  }, [granularity])


  useEffect(() => {
    if (topRef.current) {
      _initDatePicker();
      setLocalizedDateTimeData(localizedDateTimeDataProps);
      if (document.querySelector(input) !== null) {
        setIsRequired(document.querySelector(input).getAttribute('data-field-required') == 'true')
      }
    }
  }, [topRef])

  useEffect(() => {
    if (disabledProps !== disabled && JSON.stringify(initState) !== JSON.stringify(state)) {
      setDisabled(disabledProps);
      //When the selected condition changes, we clear the inputs if the user has left une field empty
      if (disabledProps) {
        let formatArray = format.split('');
        let count = 0;
        formatArray.forEach((item) => {
          if (state[item] !== '') {
            count++;
          }
        });
        if (count < formatArray.length) {
          //The user has left a field empty => clear all fields
          _clearDatepicker();
        }
      }
    }
  }, [disabledProps])

  useEffect(() => {
    if (isRangeProps !== isRange) {
      setIsRange(isRangeProps);
    }
  }, [isRangeProps])

  function _initDatePicker() {
    if (typeof datepicker !== 'undefined' && datepicker) {
      const node = topRef.current
      const dateInputElements = node.querySelectorAll('.form-control');

      if (dateInputElements.length > 3) {
        setStyleMarginRight(' margin-right');
      }

      $(hiddenInputRef.current).datetimepicker({
        format: format,
        locale: locale,
        debug: false, // pass to `true` to inspect widget
        icons: {
          time: 'fa fa-clock-o',
          date: 'fa fa-calendar',
          up: 'fa fa-chevron-up',
          down: 'fa fa-chevron-down',
          previous: 'fa fa-arrow-left',
          next: 'fa fa-arrow-right',
          close: 'fa fa-times'
        }
      });

      $(hiddenInputRef.current).datetimepicker().on('dp.change', (event) => _onDatepickerChangerDate(event));
    }
  }

  function _openCloseDatepicker() {
    if (isDatepickerOpen) {
      setIsDatepickerOpen(false);
      $(hiddenInputRef.current).data("DateTimePicker").hide();
    } else {
      setIsDatepickerOpen(true);
      $(hiddenInputRef.current).data("DateTimePicker").show();
    }
  }

  function _getSelectClassNames() {
    if (disabled) {
      return "form-control disabled";
    } else {
      return "form-control";
    }
  }

  function _clearDatepicker() {
    $(hiddenInputRef.current).data("DateTimePicker").clear();
    updateData({Y: '', M: '', D: '', h: '', m: '', s: ''});
  }

  function _onDatepickerChangerDate(data) {
    if (data.date !== false) {
      setSelectedDate(data.date);
      updateData({
        Y: data.date.year(),
        M: (data.date.month() + 1),
        D: data.date.date(),
        h: data.date.hour(),
        m: data.date.minute(),
        s: data.date.second()
      });
    } else {
      setSelectedDate('');
      updateData({Y: '', M: '', D: '', h: '', m: '', s: ''});
    }
  }

  function _selectDate(event) {
    if (typeof event === 'undefined' || event.action !== "pop-value" || !req) {
      if (typeof event !== 'undefined') {
        setSelectedDate(event.target.value);
      } else {
        setSelectedDate('');
      }
    }
  }

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
    setState(state ? {...state, ...h} : h);
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
    const dt = new Date(v * 1000)
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
    let f = format;
    return f.split('').map(function (k) {
      return d[k] ? k : '';
    }).join('');
  }

  function isCurrentFormatValid() {
    let current = getCurrentFormat();
    if (current == '' && !isRequired) return true;   // allow empty value if field is not required
    let allowed = getAllowedFormats();
    return allowed.indexOf(current) > -1;
  }

  function getFieldOptions() {
    return getInput().data("field-options") || {format: format};
  }

  function _handleChangeBC(e) {
    updateData({BC: e.target.checked});
  }

  return (
    <div id={inputId + '_' + inputSuffixId} ref={topRef}>
      {state && localizedDateTimeData.month_names && (
        <div className="dateTimeInput rails-bootstrap-forms-datetime-select">
          <div className="row">
            {allowBC == '1' ? (
              <div className="form-check" style={{display: 'inline-block', marginRight: '3rem', paddingLeft: '0'}}>
                <label className="form-check-label" htmlFor={`bcCheck-${input}`}>{Translations.messages['catalog_admin.fields.complex_datation_option_inputs.BC']}</label>
                <input type="checkbox" value={true} name={inputName + '[BC]'} className="form-check-input" id={`bcCheck-${input}`}
                       onChange={_handleChangeBC}/>
              </div>
            ) : null}
            {fmt.includes('D') ? (
              <input id={inputId + '_' + inputSuffixId + '_day'} name={inputName + '[D]'} style={errorStl} type="number"
                     min="0" max="31" className="input-2 form-control" value={state.D}
                     onChange={_handleChangeDay}/>
            ) : null
            }
            {fmt.includes('M') ? (
              <select id={inputId + '_' + inputSuffixId + '_month'} style={errorStl} name={inputName + '[M]'}
                      className={_getSelectClassNames()} value={state.M} onChange={_handleChangeMonth}
                      ref={selectRef}>
                {localizedDateTimeData.month_names.map((month, index) => {
                    if (month !== null) {
                      month = month.charAt(0).toUpperCase() + month.slice(1);
                    }
                    if (index === 0) {
                      index = ''
                    }

                    return <option key={index} value={index}>{month}</option>
                  }
                )}
              </select>
            ) : null
            }
            {fmt.includes('Y') ? (
              <input id={inputId + '_' + inputSuffixId + '_year'} name={inputName + '[Y]'} style={errorStl} type="number" min="0"
                     type="number"
                     className={'input-4 form-control' + styleMarginRight} value={state.Y}
                     onChange={_handleChangeYear}/>
            ) : null
            }
            {fmt.includes('h') ? (
              <input id={inputId + '_' + inputSuffixId + '_hour'} name={inputName + '[h]'} style={errorStl} min="0"
                     max="23" type="number" className="input-2 form-control" value={state.h}
                     onChange={_handleChangeHours}/>
            ) : null
            }
            {fmt.includes('m') ? (
              <input id={inputId + '_' + inputSuffixId + '_minute'} name={inputName + '[m]'} style={errorStl} min="0"
                     max="59" type="number" className="input-2 form-control" value={state.m}
                     onChange={_handleChangeMinutes}/>
            ) : null
            }
            {fmt.includes('s') ? (
              <input id={inputId + '_' + inputSuffixId + '_second'} name={inputName + '[s]'} style={errorStl} min="0"
                     max="59" type="number" className="input-2 form-control" value={state.s}
                     onChange={_handleChangeSeconds}/>
            ) : null
            }
            <div className="hidden-datepicker">
              <input type="text" ref={hiddenInputRef} value={selectedDate} onChange={_selectDate}/>
            </div>
            <div className="calendar-button-container">
              <a id={inputId + '_calendar_icon' + '_' + inputSuffixId} onClick={_openCloseDatepicker} type="button">
                <i className="fa fa-calendar"></i></a>
              <a onClick={_clearDatepicker} type="button"><i className="fa fa-times"></i></a>
            </div>
            {(list && list.length >= 1) &&
              <div className="col-lg-1 icon-container">
                <a type="button" onClick={() => {
                  addComponent(item)
                }}><i className="fa fa-plus"></i></a>
              </div>
            }
            {(list && (item !== list[0])) &&
              <div className="col-lg-1 icon-container">
                <a type="button" onClick={() => {
                  deleteComponent(item)
                }}><i className="fa fa-trash"></i></a>
              </div>
            }
          </div>
        </div>
      )}
      <span className="error helptext">{errorMsg}</span>
    </div>
  );
})

DateTimeInput.propTypes = {
  input: PropTypes.string.isRequired,
}

export default DateTimeInput;
