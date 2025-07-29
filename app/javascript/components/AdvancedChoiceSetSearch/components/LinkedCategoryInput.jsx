import React, { useState, useEffect, useCallback, useMemo } from 'react';
import ReactSelect from 'react-select';
import axios from 'axios';
import 'moment';

import DateTimeSearch from '../../AdvancedDateTimeSearch/components/DateTimeSearch';

// Constants for field types
const FIELD_TYPES = {
  TEXT: 'Field::Text',
  EMAIL: 'Field::Email',
  INT: 'Field::Int',
  DECIMAL: 'Field::Decimal',
  URL: 'Field::URL',
  BOOLEAN: 'Field::Boolean',
  CHOICE_SET: 'Field::ChoiceSet',
  DATE_TIME: 'Field::DateTime'
};

// Default configuration for HTTP requests
const HTTP_CONFIG = {
  retry: 3,
  retryDelay: 1000,
};

/**
 * LinkedCategoryInput Component - Handles dynamic inputs based on selected categories.
 * Displays different input types depending on the selected field type.
 */
const LinkedCategoryInput = (props) => {
  const {
    inputName: inputNameProps,
    selectedCondition: selectedConditionProps,
    catalog,
    locale,
    updateSelectCondition,
    itemType,
    searchPlaceholder,
    selectedCategory: selectedCategoryProps,
    defaultValue,
  } = props;

  const [isLoading, setIsLoading] = useState(true);
  const [inputName, setInputName] = useState(inputNameProps);
  const [inputNameArray, setInputNameArray] = useState([]);
  const [dateInputNames, setDateInputNames] = useState({
    start: '',
    end: ''
  });
  const [dateFormat, setDateFormat] = useState('');
  const [inputType, setInputType] = useState(FIELD_TYPES.TEXT);
  const [inputData, setInputData] = useState(null);
  const [localizedDateTimeData, setLocalizedDateTimeData] = useState([]);
  const [selectedCondition, setSelectedCondition] = useState(selectedConditionProps);
  const [selectedCategory, setSelectedCategory] = useState([]);

  const findInArray = useCallback((array, key) => {
    if (!array) return false;
    
    return array.find(item => item && typeof item[key] !== 'undefined') || false;
  }, []);

  const buildInputNameWithCondition = useCallback((condition) => {
    const nameArray = inputNameProps.split("[category_criteria]");
    
    if (nameArray.length === 2) {
      const conditionValue = condition || 'default';
      return `${nameArray[0]}[category_criteria][${conditionValue}]${nameArray[1]}`;
    }
    
    return inputNameProps;
  }, [inputNameProps]);

  const buildDateTimeInputNames = useCallback((type, inputName, condition, inputNameArray) => {
    if (type === FIELD_TYPES.DATE_TIME) {
      const endName = inputName.split(inputNameArray[0]);
      console.log("endname", endName);
      setDateInputNames({
        start: `${inputNameArray[0]}[start]${endName[1]}[${condition}]`,
        end: `${inputNameArray[0]}[end]${endName[1]}[${condition}]`
      });
    }
  }, []);

  const updateDateTimeFormatOption = useCallback((formatOptions) => {
    const formatOption = findInArray(formatOptions, 'format');
    setDateFormat(formatOption ? formatOption.format : '');
  }, [findInArray]);

  const updateLocalizedDateTimeData = useCallback((options) => {
    const option = findInArray(options, 'localizedDateTimeData');
    if (option) {
      setLocalizedDateTimeData(option.localizedDateTimeData);
    }
  }, [findInArray]);

  // Fonction principale pour récupérer les données du serveur
  const fetchDataFromServer = useCallback(async (selectedCategoryArg) => {
    try {
      const selectedCategoryVar = selectedCategoryArg || selectedCategoryProps;
      const url = `/react/${catalog}/${locale}/categories/${selectedCategoryProps.choiceSetId}/${selectedCategoryProps.value}`;
      
      const response = await axios.get(url, HTTP_CONFIG);
      const { data } = response;

      // Mise à jour des données
      setInputData(data.inputData || []);
      
      if (data.selectCondition?.[0]) {
        const newInputNameArray = inputName.split(`[${data.selectCondition[0].key}]`);
        console.log(newInputNameArray);
        
        updateSelectCondition(data.selectCondition);
        setInputNameArray(newInputNameArray);
        buildDateTimeInputNames(data.inputType, inputName, data.selectCondition[0].key, newInputNameArray);
        updateDateTimeFormatOption(data.inputOptions);
        updateLocalizedDateTimeData(data.inputOptions);
        setInputType(data.inputType);
      }
      
      setIsLoading(false);
    } catch (error) {
      console.error('Erreur lors de la récupération des données:', error);
      setIsLoading(false);
    }
  }, [
    catalog, 
    locale, 
    selectedCategoryProps, 
    inputName, 
    updateSelectCondition, 
    buildDateTimeInputNames, 
    updateDateTimeFormatOption, 
    updateLocalizedDateTimeData
  ]);

  // Configuration de l'intercepteur Axios pour les tentatives de répétition
  useEffect(() => {
    const responseInterceptor = axios.interceptors.response.use(
      undefined, 
      (error) => {
        const config = error.config;
        if (!config || !config.retry) return Promise.reject(error);
        
        config.__retryCount = config.__retryCount || 0;
        if (config.__retryCount >= config.retry) {
          return Promise.reject(error);
        }
        
        config.__retryCount += 1;
        
        return new Promise((resolve) => {
          setTimeout(() => resolve(axios(config)), config.retryDelay || 1);
        });
      }
    );

    return () => {
      axios.interceptors.response.eject(responseInterceptor);
    };
  }, []);

  // Gestion des effets pour le cycle de vie du composant
  useEffect(() => {
    fetchDataFromServer();
    buildDateTimeInputNames(inputType, inputNameProps, selectedConditionProps, inputNameArray);
  }, []);

  useEffect(() => {
    if (selectedCategoryProps !== selectedCategory) {
      fetchDataFromServer(selectedCategoryProps);
      setSelectedCategory(selectedCategoryProps);
    }
  }, [selectedCategoryProps, selectedCategory, fetchDataFromServer]);

  useEffect(() => {
    const shouldUpdateInputName = inputNameProps !== inputName && selectedConditionProps === selectedCondition;
    const shouldUpdateCondition = inputNameProps === inputName && selectedConditionProps !== selectedCondition;
    const shouldUpdateBoth = inputNameProps !== inputName || selectedConditionProps !== selectedCondition;

    if (shouldUpdateInputName) {
      buildDateTimeInputNames(inputType, inputNameProps, selectedCondition, inputNameArray);
      setInputName(inputNameProps);
    } else if (shouldUpdateCondition) {
      buildDateTimeInputNames(inputType, inputName, selectedConditionProps, inputNameArray);
      setSelectedCondition(selectedConditionProps);
    } else if (shouldUpdateBoth) {
      buildDateTimeInputNames(inputType, inputNameProps, selectedConditionProps, inputNameArray);
      setInputName(inputNameProps);
      setSelectedCondition(selectedConditionProps);
    }
  }, [inputNameProps, selectedConditionProps, selectedCondition, inputName, inputType, inputNameArray, buildDateTimeInputNames]);

  // Transformation des données pour les choix multiples
  const choiceSetOptions = useMemo(() => {
    if (!inputData) return [];
    return inputData.map(option => ({
      value: option.key,
      label: option.label
    }));
  }, [inputData]);

  // Composants de rendu pour différents types d'inputs
  const renderDateTimeInput = () => (
    <DateTimeSearch
      selectCondition={[]}
      disableInputByCondition={selectedConditionProps}
      startDateInputName={dateInputNames.start}
      endDateInputName={dateInputNames.end}
      localizedDateTimeData={localizedDateTimeData}
      catalog={catalog}
      itemType={itemType}
      inputStart="input1"
      inputEnd="input2"
      isRange={true}
      format={dateFormat}
      locale={locale}
      parentSelectedCondition={selectedCondition}
      defaultStart={defaultValue?.start?.[selectedCondition]}
      defaultEnd={defaultValue?.end?.[selectedCondition]}
    />
  );

  const renderTextInput = (type = "text", step = null) => (
    <input
      name={buildInputNameWithCondition(selectedCondition)}
      type={type}
      className="form-control"
      step={step}
      defaultValue={defaultValue?.[selectedCondition]}
    />
  );

  const renderBooleanSelect = () => (
    <select
      name={buildInputNameWithCondition(selectedCondition)}
      className="form-select"
      defaultValue={defaultValue?.[selectedCondition]}
    >
      {inputData?.map((item) => (
        <option key={item.key} value={item.key}>
          {item.value}
        </option>
      ))}
    </select>
  );

  const renderChoiceSetSelect = () => {
    const defaultOption = choiceSetOptions.find(
      option => option.value == defaultValue?.default
    );

    return (
      <ReactSelect
        name={buildInputNameWithCondition('default')}
        isSearchable={true}
        isClearable={true}
        options={choiceSetOptions}
        className="basic-select"
        classNamePrefix="select"
        placeholder={searchPlaceholder}
        defaultValue={defaultOption}
      />
    );
  };

  // Fonction principale de rendu des inputs
  const renderInput = () => {
    if (isLoading) return null;

    const inputTypeRenderers = {
      [FIELD_TYPES.DATE_TIME]: renderDateTimeInput,
      [FIELD_TYPES.EMAIL]: () => renderTextInput("text"),
      [FIELD_TYPES.INT]: () => renderTextInput("number"),
      [FIELD_TYPES.DECIMAL]: () => renderTextInput("number", "any"),
      [FIELD_TYPES.URL]: () => renderTextInput("url"),
      [FIELD_TYPES.BOOLEAN]: renderBooleanSelect,
      [FIELD_TYPES.CHOICE_SET]: renderChoiceSetSelect,
    };

    const renderer = inputTypeRenderers[inputType] || (() => renderTextInput("text"));
    return renderer();
  };

  console.log("inputName", inputName);

  // Composant principal
  return (
    <div className="single-reference-container">
      {isLoading && <div className="loader"></div>}
      {renderInput()}
    </div>
  );
};

export default LinkedCategoryInput;
