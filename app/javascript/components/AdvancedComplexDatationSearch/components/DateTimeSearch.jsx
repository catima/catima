import React, {useState, useEffect, createRef} from 'react';
import DateTimeInput from './DateTimeInput';
import $ from 'jquery';
import 'moment';
import 'bootstrap4-datetimepicker';
import Translations from "../../Translations/components/Translations";

const DateTimeSearchComponent = (props) => {
  const {
    item,
    index,
    list,
    addComponent,
    deleteComponent,
    startDateInputNameProps,
    endDateInputNameProps,
    disableInputByConditionProps,
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
    allowBC
  } = props

  const [selectedCondition, setSelectedCondition] = useState('')
  const [selectedFieldCondition, setSelectedFieldCondition] = useState('')
  const [startDateInputName, setStartDateInputName] = useState(startDateInputNameProps.split(`[start]`)[0] + `[${item}]` + startDateInputNameProps.split(`[start]`)[1])
  const [endDateInputName, setEndDateInputName] = useState(endDateInputNameProps.split(`[end]`)[0] + `[${item}]` + endDateInputNameProps.split(`[end]`)[1])
  const [selectConditionInputName, setSelectConditionDateInputName] = useState(selectConditionName.split(`[condition]`)[0] + `[${item}]` + '[condition]')
  const [fieldConditionInputName, setFieldConditionInputName] = useState(fieldConditionName.split(`[field_condition]`)[0] + `[${item}]` + '[field_condition]')

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
      setStartDateInputName(startDateInputNameProps.split(`[start]`)[0] + `[${item}]` + '[start]' + startDateInputNameProps.split(`[start]`)[1]);
      setStartDateInputNameArray(startDateInputNameProps.split("[exact]"))
    }
  }, [startDateInputNameProps])

  useEffect(() => {
    if (endDateInputNameProps !== endDateInputName) {
      setEndDateInputName(endDateInputNameProps.split(`[end]`)[0] + `[${item}]` + '[end]' + endDateInputNameProps.split(`[end]`)[1]);
      setEndDateInputNameArray(endDateInputNameProps.split("[exact]"))
    }
  }, [endDateInputNameProps])

  useEffect(() => {
    if (selectConditionName !== selectConditionInputName) {
      setSelectConditionDateInputName(selectConditionName.split(`[condition]`)[0] + `[${item}]` + '[condition]')
    }
  }, [selectConditionName])

  useEffect(() => {
    if (fieldConditionName !== fieldConditionInputName) {
      setFieldConditionInputName(fieldConditionName.split(`[field_condition]`)[0] + `[${item}]` + '[field_condition]')
    }
  }, [selectConditionName])


  function _buildInputNameCondition(inputName, condition, index, name) {
    console.log(inputName)
    if (inputName.length === 2) {
      if (condition !== '') return inputName[0].split(`[${name}]`)[0] + `[${index}]` + `[${name}]` + '[' + condition + ']' + inputName[1];
      else return inputName[0].split(`[${name}]`)[0] + `[${index}]` + `[${name}]` + '[default]' + inputName[1];
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

  function _selectCondition(idx) {
    return (event) => {
      if (typeof event === 'undefined' || event.action !== "pop-value" || !req) {
        if (typeof event !== 'undefined') {
          setStartDateInputName(_buildInputNameCondition(startDateInputNameArray, event.target.value, idx, 'start'));
          setEndDateInputName(_buildInputNameCondition(endDateInputNameArray, event.target.value, idx, 'end'));
          setSelectedCondition(event.target.value);
          _updateDisableState(event.target.value);
        } else {
          setStartDateInputName(_buildInputNameCondition(startDateInputNameArray, 'exact', idx, 'start'));
          setEndDateInputName(_buildInputNameCondition(endDateInputNameArray, 'exact', idx, 'end'));
          setSelectedCondition('');
          _updateDisableState('');
        }
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

  function renderSelectConditionElement(idx) {
    return (
      <select className="form-control filter-condition" name={selectConditionInputName} value={selectedCondition}
              onChange={_selectCondition(idx)}>
        {selectCondition.map((item) => {
          return <option key={item.key} value={item.key}>{item.value}</option>
        })}
      </select>
    );
  }

  function renderDateTimeElement(list, item) {
    return (
      <div className="col-lg-12">
        <DateTimeInput input={inputStart} inputId={dateTimeSearchId} inputSuffixId="start_date"
                       inputName={startDateInputName} ref={{
          topRef: dateTimeSearchRef1,
          hiddenInputRef: hiddenInputRef1
        }} localizedDateTimeData={localizedDateTimeData} disabled={disabled} isRange={isRange} datepicker={true}
                       locale={locale} format={format} allowBC={allowBC} list={list} item={item}
                       addComponent={addComponent} deleteComponent={deleteComponent}/>
        {isRange &&
          <i className="fa fa-chevron-down"></i>
        }
      </div>
    );
  }

  function renderFieldConditionElement() {
    return (
      <select className="form-control filter-condition" name={fieldConditionInputName} value={selectedFieldCondition}
              onChange={_selectFieldCondition}>
        {fieldConditionData.map((item) => {
          return <option key={item.key} value={item.key}>{item.value}</option>
        })}
      </select>
    );
  }

  function renderComponent(item, index, list) {
    return (
      <div>
        <div className="datetime-search-container row">
          {selectCondition.length > 0 &&
            <div className="col-lg-2">
              {renderFieldConditionElement()}
            </div>
          }
          <div className={_getDateTimeClassname()}>
            {renderDateTimeElement(list, item)}
            <div className="collapse" id={dateTimeCollapseId}>
              <div className="col-lg-12">
                <DateTimeInput input={inputEnd} inputId={dateTimeSearchId} inputSuffixId="end_date"
                               inputName={endDateInputName} localizedDateTimeData={localizedDateTimeData}
                               disabled={disabled} isRange={isRange} ref={{
                  topRef: dateTimeSearchRef2,
                  hiddenInputRef: hiddenInputRef2
                }} datepicker={true} locale={locale} format={format} allowBC={allowBC}/>
              </div>
            </div>
          </div>
          {selectCondition.length > 0 &&
            <div className="col-lg-3">
              {renderSelectConditionElement(item)}
            </div>
          }
        </div>
        <div className="component-search-row row">
          <div className="col-lg-2">

          </div>
          <div className="col-lg-10">
            <div className="d-flex align-items-center">
              <div className="mr-2">
                {Translations.messages['catalog_admin.fields.complex_datation_option_inputs.tolerance']} :
              </div>
              <input id='tolerance' name={startDateInputName.split('[start]')[0] + '[tolerance]'} min="0"
                     type="number" className="input-4 form-control"/>
            </div>
          </div>
        </div>
      </div>
    )
  }

  return (
    <div>
      {renderComponent(item, index, list)}
    </div>
  )

}

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
    allowBC,
  } = props


  const [componentsList, setComponentsList] = useState([])

  useEffect(() => {
    let computedComponentList = componentsList;
    let id = 0;
    let item = id
    computedComponentList.push(item);
    setComponentsList([...computedComponentList]);
  }, [])

  function _addComponent(itemId) {
    let computedComponentList = componentsList;
    let id = itemId + 1;
    let item = id
    computedComponentList.push(item);
    setComponentsList([...computedComponentList]);
  }

  function _deleteComponent(itemId) {
    let computedComponentList = componentsList;
    computedComponentList.forEach((ref, index) => {
      if (ref === itemId) {
        computedComponentList.splice(index, 1);
      }
    });
    setComponentsList([...computedComponentList]);
  }


  function renderComponentList() {
    return componentsList.map((item, index, list) => <DateTimeSearchComponent
      key={index}
      item={item}
      index={index}
      list={list}
      addComponent={_addComponent}
      deleteComponent={_deleteComponent}
      startDateInputNameProps={startDateInputNameProps}
      endDateInputNameProps={endDateInputNameProps}
      disableInputByConditionProps={disableInputByConditionProps}
      srcId={srcId}
      srcRef={srcRef}
      selectCondition={selectCondition}
      selectConditionName={selectConditionName}
      inputStart={inputStart}
      localizedDateTimeData={localizedDateTimeData}
      locale={locale}
      format={format}
      fieldConditionName={fieldConditionName}
      fieldConditionData={fieldConditionData}
      inputEnd={inputEnd}
      allowBC={allowBC}
    />);
  }

  return (
    <div>
      {renderComponentList()}
    </div>
  );
}

export default DateTimeSearch;
