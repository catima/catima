import React, {useEffect, useState, useMemo} from "react";
import ReactSelect from 'react-select';
import axios from 'axios';
import $ from 'jquery';
import 'moment';
import DateTimeSearch from '../../AdvancedDateTimeSearch/components/DateTimeSearch';

const ItemTypesReferenceSearch = (props) => {
  const {
    fieldUuid,
    itemId,
    selectCondition,
    selectedFilter,
    catalog,
    locale,
    itemType,
    updateSelectCondition,
    selectedCondition,
    choosePlaceholder,
    noOptionsMessage
  } = props

  const [isLoading, setIsLoading] = useState(true)
  const [inputType, setInputType] = useState('Field::Text')
  const [inputData, setInputData] = useState(null)
  const [inputOptions, setInputOptions] = useState(null)
  const [localizedDateTimeData, setLocalizedDateTimeData] = useState([])

  const buildInputNameWithCondition = useMemo(() => {
      const currentCondition = selectedCondition || 'default';
      return `advanced_search[criteria][${fieldUuid}][${itemId}][${currentCondition}]`;
  }, [fieldUuid, selectedCondition, itemId]);

  useEffect(() => { getDataFromServer(); }, [selectedFilter]);

  function getDataFromServer() {
    let config = {
      retry: 3,
      retryDelay: 1000,
    };

    axios.get(`/react/${catalog}/${locale}/${itemType}/${selectedFilter?.value}`, config)
      .then(res => {
        if (res.data.inputData === null) setInputData([]);
        else setInputData(res.data.inputData);

        _updateSelectCondition(res.data.selectCondition);
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
  }

  function getDateTimeFormatOption() {
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
        fieldUuid={fieldUuid}
        itemId={itemId}
        parentSelectedCondition={selectedCondition}
        format={getDateTimeFormatOption()}
        locale={locale}
        localizedDateTimeData={localizedDateTimeData}
      />
    } else if (inputType === 'Field::Decimal') {
      return <input name={buildInputNameWithCondition}
                    type="number" className="form-control" step="any"/>
    } else if (inputType === 'Field::Int') {
      return <input name={buildInputNameWithCondition}
                    type="number" className="form-control"/>
    } else if (inputType === 'Field::Boolean') {
      return (
        <select name={buildInputNameWithCondition}
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
          name={buildInputNameWithCondition}
          isSearchable={true}
          isClearable={true}
          options={_getMultipleChoiceSetOptions()}
          className="basic-select"
          classNamePrefix="select"
          placeholder={choosePlaceholder}
          noOptionsMessage={noOptionsMessage}
        />
      );
    } else {
      return <input name={buildInputNameWithCondition} type="text"
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
