import React, {useState, useEffect} from 'react';
import ReactSelect from 'react-select';
import axios from 'axios';
// import $ from 'jquery';
import 'moment';

import DateTimeSearch from '../../AdvancedDateTimeSearch/components/DateTimeSearch';

const LinkedCategoryInput = (props) => {
  const {
    inputName: inputNameProps,
    selectedCondition: selectedConditionProps,
    // req,
    catalog,
    locale,
    updateSelectCondition,
    itemType,
    searchPlaceholder,
    selectedCategory: selectedCategoryProps,
    defaultValue,
  } = props

  const [isLoading, setIsLoading] = useState(true)
  const [inputName, setInputName] = useState(inputNameProps)
  const [inputNameArray, setInputNameArray] = useState([])
  const [startDateInputName, setStartDateInputName] = useState('')
  const [endDateInputName, setEndDateInputName] = useState('')
  const [dateFormat, setDateFormat] = useState('')
  const [inputType, setInputType] = useState('Field::Text')
  const [inputData, setInputData] = useState(null)
  // const [inputOptions, setInputOptions] = useState(null)
  const [localizedDateTimeData, setLocalizedDateTimeData] = useState([])
  // const [selectedFilter, setSelectedFilter] = useState({})
//   const [selectedItem, setSelectedItem] = useState([])
  // const [selectCondition, setSelectCondition] = useState([])
  const [selectedCondition, setSelectedCondition] = useState(selectedConditionProps)
  // const [hiddenInputValue, setHiddenInputValue] = useState([])
  const [selectedCategory, setSelectedCategory] = useState([])

  useEffect(() => {
    _getDataFromServer();
    _buildDateTimeInputNames(inputType, inputNameProps, selectedConditionProps, inputNameArray);
  }, [])

  useEffect(() => {
      if (selectedCategoryProps !== selectedCategory) {
      _getDataFromServer(selectedCategoryProps);
      setSelectedCategory(selectedCategoryProps);
    }
  }, [selectedCategoryProps])

  useEffect(() => {
    if (inputNameProps !== inputName && selectedConditionProps === selectedCondition) {
      _buildDateTimeInputNames(inputType, inputNameProps, selectedCondition, inputNameArray);
      setInputName(inputNameProps);
    } else if (inputNameProps === inputName && selectedConditionProps !== selectedCondition) {
      _buildDateTimeInputNames(inputType, inputName, selectedConditionProps, inputNameArray);
      setSelectedCondition(selectedConditionProps);
    } else {
      _buildDateTimeInputNames(inputType, inputNameProps, selectedConditionProps, inputNameArray);
      setInputName(inputNameProps);
      setSelectedCondition(selectedConditionProps);
    }
  }, [inputNameProps, selectedConditionProps, selectedCondition])

//   useEffect(() => {
//     _save()
//   }, [selectedItem])

  function _buildDateTimeInputNames(type, inputName, condition, inputNameArray) {
    if (type === 'Field::DateTime') {
      let endName = inputName.split(inputNameArray[0]);
      setStartDateInputName(inputNameArray[0] + '[start]' + endName[1] + '[' + condition + ']');
      setEndDateInputName(inputNameArray[0] + '[end]' + endName[1] + '[' + condition + ']');
    }
  }

  function _buildInputNameCondition(condition) {
    let nameArray = inputNameProps.split("[category_criteria]");
    if (nameArray.length === 2) {
      if (condition !== '') return nameArray[0] + "[category_criteria]" + '[' + condition + ']' + nameArray[1];
      else return nameArray[0] + "[category_criteria]" + '[default]' + nameArray[1];
    } else {
      return inputNameProps;
    }
  }

//   function _save() {
//     console.log("save");
//     console.log(selectedItem);
//     if (selectedItem !== null && selectedItem.length !== 0) {
//       let idArray = [];
//       selectedItem.forEach((item) => {
//         idArray.push(item.value);
//       });
//       setHiddenInputValue(idArray);
//       console.log("idArray", idArray)
//       document.getElementsByName(inputNameProps)[0].value = hiddenInputValue;
//     }
//   }

//   function _selectItem(event) {
//         console.log("selecteditem", event.target.value);
//     if (typeof event === 'undefined' || event === null || event.action !== "pop-value" || !req) {
//       if (typeof item !== 'undefined' && item !== null) {
//         console.log("item", item);
//         setSelectedItem(event.target.value)
//       } else {
//         setSelectedItem([])
//       }
//     }
//   }

  function _getDataFromServer(selectedCategoryArg) {
    let selectedCategoryVar = selectedCategoryProps
    let config = {
      retry: 3,
      retryDelay: 1000,
    };

    if (typeof selectedCategoryArg !== 'undefined' 
        // && selectedItem !== null
    ) {
      selectedCategoryVar.value = selectedCategoryArg.value;
      selectedCategoryVar.label = selectedCategoryArg.label;
    }

    axios.get(`/react/${catalog}/${locale}/categories/${selectedCategoryProps.choiceSetId}/${selectedCategoryProps.value}`, config)
      .then(res => {
        if (res.data.inputData === null) setInputData([]);
        else setInputData(res.data.inputData);

        const inputNameArray = inputName.split('[' + res.data.selectCondition[0].key + ']');

        updateSelectCondition(res.data.selectCondition);
        setInputNameArray(inputNameArray);
        _buildDateTimeInputNames(res.data.inputType, inputName, res.data.selectCondition[0].key, inputNameArray);
        // setInputOptions(res.data.inputOptions);
        _updateDateTimeFormatOption(res.data.inputOptions);
        _updateLocalizedDateTimeData(res.data.inputOptions);
        setInputType(res.data.inputType);
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

  // function _updateSelectCondition(array) {
  //   updateSelectCondition(array);
  //   setSelectCondition(array);
  // }

  function _updateDateTimeFormatOption(format) {
    let formatOption = _searchInArray(format, 'format');
    if (formatOption === false) {
      setDateFormat('');
    } else {
      setDateFormat(formatOption.format);
    }
  }

  function _updateLocalizedDateTimeData(options) {
    let option = _searchInArray(options, 'localizedDateTimeData');
    if (option !== false) {
      setLocalizedDateTimeData(option.localizedDateTimeData);
    }
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
        selectCondition={[]}
        // selectConditionDefault={selectedCondition}
        disableInputByCondition={selectedConditionProps}
        startDateInputName={startDateInputName}
        endDateInputName={endDateInputName}
        localizedDateTimeData={localizedDateTimeData}
        catalog={catalog}
        itemType={itemType}
        inputStart='input1'
        inputEnd='input2'
        isRange={true}
        format={dateFormat}
        locale={locale}
        parentSelectedCondition={selectedCondition}
        defaultStart={defaultValue?.["start"]?.[selectedCondition]}
        defaultEnd={defaultValue?.["end"]?.[selectedCondition]}
      />
    } else if (inputType === 'Field::Email') {
      return <input name={_buildInputNameCondition(selectedCondition)}
                    type="text" className="form-control" defaultValue={defaultValue?.[selectedCondition]}/>
    } else if (inputType === 'Field::Int') {
      return <input name={_buildInputNameCondition(selectedCondition)}
                    type="number" className="form-control" defaultValue={defaultValue?.[selectedCondition]}/>
    } else if (inputType === 'Field::Decimal') {
      return <input name={_buildInputNameCondition(selectedCondition)}
                    type="number" className="form-control" step="any" defaultValue={defaultValue?.[selectedCondition]}/>
    } else if (inputType === 'Field::URL') {
      return <input name={_buildInputNameCondition(selectedCondition)}
                    type="url" className="form-control" defaultValue={defaultValue?.[selectedCondition]}/>
    } else if (inputType === 'Field::Boolean') {
      return (
        <select name={_buildInputNameCondition(selectedCondition)}
                className="form-select" defaultValue={defaultValue?.[selectedCondition]}>
          {inputData.map((item) => {
            return <option key={item.key}>{item.value}</option>
          })
          }
        </select>
      );
    } else if (inputType === 'Field::ChoiceSet') {
      
      const options = _getMultipleChoiceSetOptions();
      const defaultOption = options.find(option => option.value == defaultValue?.["default"]);

      return (
        <ReactSelect
          name={_buildInputNameCondition('default')}
          isSearchable={true}
          isClearable={true}
          options={options}
          className="basic-select"
          classNamePrefix="select"
          placeholder={searchPlaceholder}
          defaultValue={defaultOption}
        />
      );
    } else {
      return <input name={_buildInputNameCondition(selectedCondition)} 
                    type="text" className="form-control" defaultValue={defaultValue?.[selectedCondition]} />
    }
  }

  return (
    <div className="single-reference-container">
      {isLoading && <div className="loader"></div>}
      {renderInput()}
      {selectedCondition}<br/>
      {selectedConditionProps}<br/>
      {startDateInputName}
    </div>
  );
}

export default LinkedCategoryInput;
