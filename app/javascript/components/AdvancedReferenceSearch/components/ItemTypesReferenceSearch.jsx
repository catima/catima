import React, {useEffect, useState, useRef} from "react";
import ReactSelect from 'react-select';
import axios from 'axios';
import $ from 'jquery';
import 'moment';
import DateTimeSearch from '../../AdvancedDateTimeSearch/components/DateTimeSearch';

const ItemTypesReferenceSearch = (props) => {
  const {
    inputName: inputNameProps,
    selectCondition: selectConditionProps,
    selectedFilter: selectedFilterProps,
    srcId,
    srcRef,
    req,
    field,
    catalog,
    locale,
    itemType,
    updateSelectCondition,
    selectedCondition,
    choosePlaceholder,
    noOptionsMessage
  } = props

  const [isLoading, setIsLoading] = useState(true)
  const [inputName, setInputName] = useState(inputNameProps)
  const [inputNameArray, setInputNameArray] = useState([])
  const [startDateInputName, setStartDateInputName] = useState('')
  const [endDateInputName, setEndDateInputName] = useState('')
  const [inputType, setInputType] = useState('Field::Text')
  const [inputData, setInputData] = useState(null)
  const [inputOptions, setInputOptions] = useState(null)
  const [localizedDateTimeData, setLocalizedDateTimeData] = useState([])
  const [selectedFilter, setSelectedFilter] = useState({})
  const [selectedItem, setSelectedItem] = useState([])
  const [selectCondition, setSelectCondition] = useState(selectConditionProps)
  const [hiddenInputValue, setHiddenInputValue] = useState([])
  const [referenceSearchId, setReferenceSearchId] = useState(`${srcId}-search`)

  const referenceSearchRef = useRef(`${srcRef}-search`)

  useEffect(() => {
    _getDataFromServer();
  }, [])

  useEffect(() => {
    _getDataFromServer(selectedFilterProps);
    setSelectedFilter(selectedFilterProps);
  }, [selectedFilterProps])

  useEffect(() => {
    setInputName(inputNameProps)
    setSelectedFilter(selectedFilterProps);
  }, [inputNameProps, selectedFilterProps])

  useEffect(() => {
    _buildDateTimeInputNames(inputName, inputName.split(/^(.*)(\[.*\])$/))
  }, [selectCondition, inputName])

  useEffect(() => {
    if (selectedItem != []) _save();
  }, [selectedItem])

  function _buildDateTimeInputNames(inputName, inputNameArr) {
      let endName = inputName.split(inputNameArr[0]);
      setStartDateInputName(inputNameArr[1] + '[start]' + inputNameArr[2]);
      setEndDateInputName(inputNameArr[1] + '[end]' + inputNameArr[2]);
  }

  function _save() {
    if (selectedItem !== null && selectedItem.length !== 0) {
      let idArray = [];
      selectedItem.forEach((item) => {
        idArray.push(item.value);
      });
      setHiddenInputValue(idArray);
      document.getElementsByName(inputName)[0].value = hiddenInputValue;
    }
  }

  function _selectItem(event) {
    if (typeof event === 'undefined' || event === null || event.action !== "pop-value" || !req) {
      if (typeof item !== 'undefined' && item !== null) {
        setSelectedItem(event.target.value)
      } else {
        setSelectedItem([])
      }
    }
  }

  function _getDataFromServer(selectedFilter) {
    let config = {
      retry: 3,
      retryDelay: 1000,
    };
    let updatedFilter = selectedFilter
    if (typeof selectedFilter !== 'undefined' && selectedItem !== null) {
      updatedFilter.value = selectedFilter.value;
      updatedFilter.label = selectedFilter.label;
    } else {
      if (typeof field !== 'undefined') {
        updatedFilter.value = field;
      }
      setSelectedFilter(updatedFilter)
    }

    axios.get(`/react/${catalog}/${locale}/${itemType}/${selectedFilter?.value ? selectedFilter.value : selectedFilterProps.value}`, config)
      .then(res => {
        if (res.data.inputData === null) setInputData([]);
        else setInputData(res.data.inputData);

        _updateSelectCondition(res.data.selectCondition);
        setInputNameArray(inputName.split('[' + res.data.selectCondition[0].key + ']'));
        _updateLocalizedDateTimeData(res.data.inputOptions);
        setInputType(res.data.inputType);
        setInputOptions(res.data.inputOptions);
        setIsLoading(false);
      });

    // Retry failed requests
    axios.interceptors.response.use(undefined, (err) => {
      let config = err.config;
      if (!config || !config.retry) return Promise.reject(err);
      config.__retryCount = config.__retryCount || 0;
      if (config.__retryCount >= config.retry) {
        return Promise.reject(err);
      }
      config.__retryCount += 1;
      let backoff = new Promise(function (resolve) {
        setTimeout(function () {
          resolve();
        }, config.retryDelay || 1);
      });
      return backoff.then(function () {
        return axios(config);
      });
    });
  }

  function _updateSelectCondition(array) {
    updateSelectCondition(array);
    setSelectCondition(array);
  }

  function _getDateTimeFormatOption() {
    let formatOption = _searchInArray(inputOptions, 'format');
    if (formatOption === false) return 'YMDhms';
    else return formatOption.format;
  }

  function _updateLocalizedDateTimeData(options) {
    let option = _searchInArray(options, 'localizedDateTimeData');
    if (option !== false) {
      setLocalizedDateTimeData(option.localizedDateTimeData);
    }
  }

  function _getChoiceSetMultipleOption() {
    let multipleOption = _searchInArray(inputOptions, 'multiple');
    if (multipleOption === false) return false;
    else return multipleOption.multiple;
  }

  function _searchInArray(array, key) {
    if (array !== null) {
      for (let i = 0; i < array.length; i++) {
        if (typeof array[i][key] !== 'undefined') {
          return array[i];
        }
      }
    }
    return false;
  }

  function _getMultipleChoiceSetOptions() {
    let optionsList = [];
    optionsList = inputData.map(option =>
      _getJSONOption(option)
    );

    return optionsList;
  }

  function _getJSONOption(option) {
    return {value: option.key, label: option.label};
  }

  function renderInput() {
    if (isLoading) return null;
    if (inputType === 'Field::DateTime') {
      return <DateTimeSearch
        id={referenceSearchId}
        selectCondition={[]}
        disableInputByCondition={selectedCondition}
        startDateInputName={startDateInputName}
        endDateInputName={endDateInputName}
        localizedDateTimeData={localizedDateTimeData}
        catalog={catalog}
        itemType={itemType}
        inputStart='input1'
        inputEnd='input2'
        isRange={false}
        format={_getDateTimeFormatOption()}
        locale={locale}
        srcId={srcId}
        onChange={_selectItem}
      />
    } else if (inputType === 'Field::Decimal') {
      return <input id={referenceSearchId} ref={referenceSearchRef} name={inputName} onChange={_selectItem}
                    type="number" className="form-control" step="any"/>
    } else if (inputType === 'Field::Int') {
      return <input id={referenceSearchId} ref={referenceSearchRef} name={inputName} onChange={_selectItem}
                    type="number" className="form-control"/>
    } else if (inputType === 'Field::Boolean') {
      return (
        <select id={referenceSearchId} ref={referenceSearchRef} name={inputName} onChange={_selectItem}
                className="form-select">
          {inputData.map((item) => {
            return <option key={item.key} value={item.key}>{item.value}</option>
          })
          }
        </select>
      );
    } else if (inputType === 'Field::ChoiceSet') {
      return (
        <ReactSelect
          id={referenceSearchId}
          name={inputName}
          isSearchable={true}
          isClearable={true}
          options={_getMultipleChoiceSetOptions()}
          className="basic-select"
          onChange={_selectItem}
          classNamePrefix="select"
          placeholder={choosePlaceholder}
          noOptionsMessage={noOptionsMessage}
        />
      );
    } else {
      return <input id={referenceSearchId} ref={referenceSearchRef} name={inputName} onChange={_selectItem} type="text"
                    className="form-control"/>
    }
  }

  return (
    <div className="single-reference-container">
      {isLoading && <div className="loader"></div>}
      {renderInput()}
    </div>
  );
}

export default ItemTypesReferenceSearch;
