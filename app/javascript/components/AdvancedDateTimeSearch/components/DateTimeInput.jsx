import 'es6-shim';
import PropTypes from 'prop-types';
import React, {useState, useEffect, useRef, forwardRef} from 'react';
import $ from 'jquery';
import {Namespace, TempusDominus} from '@eonasdan/tempus-dominus';

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
    defaultValue
  } = props

  const {topRef, datepickerRef} = ref
  const selectRef = useRef()
  const datepickerContainerRef = useRef()
  const defaultValues = defaultValue || {Y: '', M: '', D: '', h: '', m: '', s: ''};
  const types = ['Y', 'M', 'h', 'YM', 'MD', 'hm', 'YMD', 'hms', 'MDh', 'YMDh', 'MDhm', 'YMDhm', 'MDhms', 'YMDhms'];

  const [disabled, setDisabled] = useState(disabledProps)
  const [isRange, setIsRange] = useState(isRangeProps)
  const [selectedDate, setSelectedDate] = useState('')
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
    if (!datepickerRef.current) {
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
    if (!datepickerContainerRef.current)
      return

    if (typeof datepicker !== 'undefined' && datepicker) {

      let displayDate = format.includes('D');
      let displayMonth = format.includes('M');
      let displayYear = format.includes('Y');
      let displayHours = format.includes('h');
      let displayMinutes = format.includes('m');
      let displaySeconds = format.includes('s');

      let datepickerDT = new TempusDominus(datepickerContainerRef.current, {
        localization: {
          locale: locale
        },
        display: {
          icons: {
            type: 'icons',
            time: 'fa fa-clock-o',
            date: 'fa fa-calendar',
            up: 'fa fa-chevron-up',
            down: 'fa fa-chevron-down',
            previous: 'fa fa-arrow-left',
            next: 'fa fa-arrow-right',
            today: 'fa fa-calendar-check',
            clear: 'fa fa-trash',
            close: 'fa fa-times'
          },
          components: {
            calendar: displayDate || displayMonth || displayYear,
            date: displayDate,
            month: displayMonth,
            year: displayYear,
            clock: displayHours || displayMinutes || displaySeconds,
            hours: displayHours,
            minutes: displayMinutes,
            seconds: displaySeconds,
          },
        }
      });
      datepickerRef.current = datepickerDT;
      datepickerRef.current.subscribe(Namespace.events.change, _onDatepickerChangerDate);
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
    datepickerRef.current.clear()
    updateData({Y: '', M: '', D: '', h: '', m: '', s: ''});
  }

  function _onDatepickerChangerDate(event) {
    const date = event.date;
    if (date) {
      setSelectedDate(date);
      updateData({
        Y: date.year,
        M: (date.month + 1),
        D: date.date,
        h: date.hours,
        m: date.minutes,
        s: date.seconds
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

  return (
      <div id={inputId + '_' + inputSuffixId} ref={topRef}>
        {state && localizedDateTimeData.month_names && (
            <div className="dateTimeInput rails-bootstrap-forms-datetime-select">
              <div className="">
                {fmt.includes('D') ? (
                    <input id={inputId + '_' + inputSuffixId + '_day'} name={inputName + '[D]'} style={errorStl}
                           type="number"
                           min="0" max="31" className="input-2 form-control" value={state.D}
                           onChange={_handleChangeDay} readOnly={disabled || isRangeProps}/>
                ) : null
                }
                {fmt.includes('M') ? (
                    <select id={inputId + '_' + inputSuffixId + '_month'} style={errorStl} name={inputName + '[M]'}
                            className={_getSelectClassNames()} value={state.M} onChange={_handleChangeMonth}
                            ref={selectRef} readOnly={disabled || isRangeProps}>
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
                    <input id={inputId + '_' + inputSuffixId + '_year'} name={inputName + '[Y]'} style={errorStl}
                           type="number"
                           className={'input-4 form-control' + styleMarginRight} value={state.Y}
                           onChange={_handleChangeYear} readOnly={disabled || isRangeProps}/>
                ) : null
                }
                {fmt.includes('h') ? (
                    <input id={inputId + '_' + inputSuffixId + '_hour'} name={inputName + '[h]'} style={errorStl}
                           min="0"
                           max="23" type="number" className="input-2 form-control" value={state.h}
                           onChange={_handleChangeHours} readOnly={disabled || isRangeProps}/>
                ) : null
                }
                {fmt.includes('m') ? (
                    <input id={inputId + '_' + inputSuffixId + '_minute'} name={inputName + '[m]'} style={errorStl}
                           min="0"
                           max="59" type="number" className="input-2 form-control" value={state.m}
                           onChange={_handleChangeMinutes} readOnly={disabled || isRangeProps}/>
                ) : null
                }
                {fmt.includes('s') ? (
                    <input id={inputId + '_' + inputSuffixId + '_second'} name={inputName + '[s]'} style={errorStl}
                           min="0"
                           max="59" type="number" className="input-2 form-control" value={state.s}
                           onChange={_handleChangeSeconds} readOnly={disabled || isRangeProps}/>
                ) : null
                }
                <div className="calendar-button-container d-inline-flex flex-wrap">
                  <div id={"datetimepicker-" + inputId}
                       ref={datepickerContainerRef}
                       data-td-target-input="nearest"
                       data-td-target-toggle="nearest">
                    <input
                        data-td-target={"#datetimepicker-" + inputId}
                        className="d-none"
                        value={selectedDate}
                        onChange={_selectDate} type="text"/>
                    <a id={inputId + '_calendar_icon' + '_' + inputSuffixId}
                       data-td-target={"#datetimepicker-" + inputId}
                       type="button"
                       data-td-toggle="datetimepicker"><i className="fa fa-calendar"></i></a>
                  </div>
                  <a onClick={_clearDatepicker} type="button"><i className="fa fa-times"></i></a>
                </div>
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
