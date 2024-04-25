import React, {useState, useEffect, useRef, createRef} from 'react';
import DateTimeInput from './DateTimeInput';
import $ from 'jquery';
import 'moment';
import 'bootstrap4-datetimepicker';

const DateTimeSearch = (props) => {
  const {
    startDateInputName: startDateInputNameProps,
    endDateInputName: endDateInputNameProps,
    disableInputByCondition: disableInputByConditionProps,
    srcId,
    srcRef,
    selectCondition,
    selectConditionName,
    inputStart,
    localizedDateTimeData,
    locale,
    format,
    fieldConditionName,
    fieldConditionData,
    inputEnd,
  } = props

  const [selectedCondition, setSelectedCondition] = useState('')
  const [selectedFieldCondition, setSelectedFieldCondition] = useState('')
  const [startDateInputName, setStartDateInputName] = useState(startDateInputNameProps)
  const [endDateInputName, setEndDateInputName] = useState(endDateInputNameProps)
  const [startDateInputNameArray, setStartDateInputNameArray] = useState(startDateInputNameProps.split("[exact]"))
  const [endDateInputNameArray, setEndDateInputNameArray] = useState(endDateInputNameProps.split("[exact]"))
  const [disabled, setDisabled] = useState(false)
  const [isRange, setIsRange] = useState(false)

  const dateTimeSearchId = `${srcId}-datetime`;
  const dateTimeCollapseId = `${srcId}-collapse`;

  const dateTimeSearchRef1 = createRef()
  const dateTimeSearchRef2 = createRef()
  const hiddenInputRef1 = createRef()
  const hiddenInputRef2 = createRef()

  useEffect(() => {
    if (typeof selectCondition !== 'undefined' && selectCondition.length !== 0) {
      setSelectedCondition(selectCondition[0].key);
      setStartDateInputNameArray(startDateInputNameProps.split("[" + selectCondition[0].key + "]"))
      setEndDateInputNameArray(endDateInputNameProps.split("[" + selectCondition[0].key + "]"))
      _updateDisableState(selectCondition[0].key);
    }
  }, [])

  useEffect(() => {
    if (typeof disableInputByConditionProps !== 'undefined') {
      _updateDisableState(disableInputByConditionProps);
    }
  }, [])

  useEffect(() => {
    if (startDateInputNameProps !== startDateInputName) {
      setStartDateInputName(startDateInputNameProps);
      setStartDateInputNameArray(startDateInputNameProps.split("[exact]"))
    }
  }, [startDateInputNameProps])

  useEffect(() => {
    if (endDateInputNameProps !== endDateInputName) {
      setEndDateInputName(endDateInputNameProps);
      setEndDateInputNameArray(endDateInputNameProps.split("[exact]"))
    }
  }, [endDateInputNameProps])


  function _buildInputNameCondition(inputName, condition) {
    if (inputName.length === 2) {
      if (condition !== '') return inputName[0] + '[' + condition + ']' + inputName[1];
      else return inputName[0] + '[default]' + inputName[1];
    } else {
      return inputName;
    }
  }

  function _getDateTimeClassname() {
    if (selectCondition.length > 0) {
      return 'col-lg-7';
    } else {
      return 'col-lg-12';
    }
  }

  function _linkRangeDatepickers(ref1, ref2, disabled) {
    if (ref1 && ref2) {
      if (!disabled) {
        $(ref1).datetimepicker().on("dp.change", (e) => {
          $(ref2).data("DateTimePicker").minDate(e.date);
        });
        $(ref2).datetimepicker().on("dp.change", (e) => {
          $(ref1).data("DateTimePicker").maxDate(e.date);
        });
      } else {
        $(ref2).data("DateTimePicker").clear();
      }
    }
  }

  function _updateDisableState(value) {
    if (typeof value !== 'undefined') {
      if (value === 'between' || value === 'outside') {
        setDisabled(true);
        setIsRange(true);
        $('#' + dateTimeCollapseId).slideDown();
        _linkRangeDatepickers(hiddenInputRef1.current, hiddenInputRef2.current, false);
      } else if (value === 'after' || value === 'before') {
        setDisabled(true);
        setIsRange(false);
        $('#' + dateTimeCollapseId).slideUp();
        _linkRangeDatepickers(hiddenInputRef1.current, hiddenInputRef2.current, true);
      } else {
        setDisabled(false);
        setIsRange(false);
        $('#' + dateTimeCollapseId).slideUp();
        _linkRangeDatepickers(hiddenInputRef1.current, hiddenInputRef2.current, true);
      }
    }
  }

  function _selectCondition(event) {
    if (typeof event === 'undefined' || event.action !== "pop-value" || !req) {
      if (typeof event !== 'undefined') {
        setStartDateInputName(_buildInputNameCondition(startDateInputNameArray, event.target.value));
        setEndDateInputName(_buildInputNameCondition(endDateInputNameArray, event.target.value));
        setSelectedCondition(event.target.value);
        _updateDisableState(event.target.value);
      } else {
        setStartDateInputName(_buildInputNameCondition(startDateInputNameArray, 'exact'));
        setEndDateInputName(_buildInputNameCondition(endDateInputNameArray, 'exact'));
        setSelectedCondition('');
        _updateDisableState('');
      }
    }
  }

  function _selectFieldCondition(event) {
    if (typeof event === 'undefined' || event.action !== "pop-value" || !req) {
      if (typeof event !== 'undefined') {
        setSelectedFieldCondition(event.target.value);
      } else {
        setSelectedFieldCondition('');
      }
    }
  }

  function renderSelectConditionElement() {
    return (
      <select className="form-select filter-condition" name={selectConditionName} value={selectedCondition}
              onChange={_selectCondition}>
        {selectCondition.map((item) => {
          return <option key={item.key} value={item.key}>{item.value}</option>
        })}
      </select>
    );
  }

  function renderDateTimeElement() {
    return (
      <div className="col-lg-12">
        <DateTimeInput input={inputStart} inputId={dateTimeSearchId} inputSuffixId="start_date"
                       inputName={startDateInputName} ref={{
          topRef: dateTimeSearchRef1,
          hiddenInputRef: hiddenInputRef1
        }} localizedDateTimeData={localizedDateTimeData} disabled={disabled} isRange={isRange} datepicker={true}
                       locale={locale} format={format}/>
        {isRange &&
        <i className="fa fa-chevron-down"></i>
        }
      </div>
    );
  }

  function renderFieldConditionElement() {
    return (
      <select className="form-select filter-condition" name={fieldConditionName} value={selectedFieldCondition}
              onChange={_selectFieldCondition}>
        {fieldConditionData.map((item) => {
          return <option key={item.key} value={item.key}>{item.value}</option>
        })}
      </select>
    );
  }

  return (
    <div className="datetime-search-container row">
      {selectCondition.length > 0 &&
      <div className="col-lg-2">
        {renderFieldConditionElement()}
      </div>
      }
      <div className={_getDateTimeClassname()}>
        {renderDateTimeElement()}
        <div className="collapse" id={dateTimeCollapseId}>
          <div className="col-lg-12">
            <DateTimeInput input={inputEnd} inputId={dateTimeSearchId} inputSuffixId="end_date"
                           inputName={endDateInputName} localizedDateTimeData={localizedDateTimeData}
                           disabled={disabled} isRange={isRange} ref={{
              topRef: dateTimeSearchRef2,
              hiddenInputRef: hiddenInputRef2
            }} datepicker={true} locale={locale} format={format}/>
          </div>
        </div>
      </div>
      {selectCondition.length > 0 &&
      <div className="col-lg-3">
        {renderSelectConditionElement()}
      </div>
      }
    </div>
  );
}

export default DateTimeSearch;
