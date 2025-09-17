import React, { useState, useRef } from "react";
import axios from 'axios';
import SelectedReference from './partials/SelectedReference';
import ItemTypeReference from './partials/ItemTypeReference';
import AsyncPaginate from 'react-select-async-paginate';
import Translations from '../../Translations/components/Translations';
import ActionButtons from './partials/ActionButtons';

// Default configuration for HTTP requests.
const HTTP_CONFIG = {
  retry: 3,
  retryDelay: 1000,
};

const SearchElement = ({ selectedField, fieldUuid, itemId, selectedCondition, locale, fieldData, defaultValues, itemsUrl, catalog, itemType }) => {
  if (selectedField) {
    return (
      <ItemTypeReference
        fieldUuid={fieldUuid}
        itemId={itemId}
        selectedCondition={selectedCondition}
        locale={locale}
        fetchedData={fieldData}
        defaultValues={defaultValues}
      />
    );
  } else {
    return (
      <SelectedReference
        fieldUuid={fieldUuid}
        defaultValues={defaultValues}
        selectedCondition={selectedCondition}
        itemId={itemId}
        itemsUrl={`/react/${catalog}/${locale}/${itemType}?simple_fields=true`}
      />
    );
  }
};

const FieldSelectElement = ({ defaultValues, loadFields, selectedField, handleSelectFieldChange, fieldUuid, itemId }) => (
  <AsyncPaginate
    defaultOptions={!!defaultValues["sort_field_uuid"]}
    className="single-reference-filter"
    delimiter=","
    loadOptions={loadFields}
    debounceTimeout={800}
    isSearchable={false}
    isClearable={true}
    loadingMessage={() => Translations.messages['loading']}
    name={`advanced_search[criteria][${fieldUuid}][${itemId}][sort_field_uuid]`}
    value={selectedField}
    onChange={handleSelectFieldChange}
    placeholder={Translations.messages['advanced_searches.fields.reference_search_field.field_placeholder']}
    noOptionsMessage={() => Translations.messages['catalog_admin.items.reference_editor.no_options']}
  />
);

const FieldConditionSelectElement = ({ fieldConditionData, selectedFieldCondition, setSelectedFieldCondition, fieldUuid, itemId }) => (
  <select
    className="form-select filter-condition"
    name={`advanced_search[criteria][${fieldUuid}][${itemId}][field_condition]`}
    value={selectedFieldCondition}
    onChange={e => setSelectedFieldCondition(e.target.value || '')}
  >
    {fieldConditionData.map((item) => {
      return <option key={item.key} value={item.key}>{item.value}</option>;
    })}
  </select>
);

const ConditionSelectElement = ({ selectCondition, selectedCondition, setSelectedCondition, fieldUuid, itemId, selectedField }) => (
  <select
    className="form-select filter-condition"
    name={`advanced_search[criteria][${fieldUuid}][${itemId}][condition]`}
    value={selectedCondition}
    onChange={e => setSelectedCondition(e.target.value || '')}
    disabled={!selectedField}
  >
    {selectCondition.map((item) => {
      return <option key={item.key} value={item.key}>{item.value}</option>;
    })}
  </select>
);

const Reference = (props) => {
  const {
    fieldUuid,
    itemId,
    defaultValues,
    catalog,
    itemType,
    locale,
    selectCondition: selectConditionProps,
    fieldConditionData,
    addComponent,
    deleteComponent,
    canAddComponent,
    canRemoveComponent,
  } = props;

  const [selectedField, setSelectedField] = useState(null);
  const [selectCondition, setSelectCondition] = useState(selectConditionProps);
  const [selectedCondition, setSelectedCondition] = useState('');
  const [selectedFieldCondition, setSelectedFieldCondition] = useState('');
  const [fieldData, setFieldData] = useState({
    inputData: null,
    inputType: 'Field::Text',
    dateFormat: '',
    isLoading: false
  });

  const isFirstLoadOptionsRef = useRef(true);

  const fetchFieldData = async (field, defaultCondition = '') => {
    if (!field || !field.value) {
      return;
    }

    setFieldData(prev => ({ ...prev, isLoading: true }));

    try {
      const url = `/react/${catalog}/${locale}/${itemType}/${field.value}`;
      const response = await axios.get(url, HTTP_CONFIG);
      const { data } = response;

      const formatOption = data.inputOptions?.find(option => option && 'format' in option);

      setFieldData({
        inputData: data.inputData || [],
        inputType: data.inputType || 'Field::Text',
        dateFormat: formatOption ? formatOption.format : '',
        isLoading: false
      });

      if (data.selectCondition?.length > 0) {
        const existsInNewVal = data.selectCondition.find(item => item.key === defaultCondition);
        setSelectedCondition(existsInNewVal ? defaultCondition : data.selectCondition[0].key);
        setSelectCondition(data.selectCondition);
      }

    } catch (error) {
      console.error('Erreur lors de la récupération des données:', error);
      setFieldData(prev => ({ ...prev, isLoading: false }));
    }
  };

  const handleSelectFieldChange = (selectedField, defaultCondition = '') => {
    if (!selectedField) {
      setSelectedField(null);
      setSelectedCondition('');
      setSelectCondition([]);
      setFieldData({
        inputData: null,
        inputType: 'Field::Text',
        dateFormat: '',
        isLoading: false
      });
    } else {
      setSelectedField(selectedField);
      fetchFieldData(selectedField, defaultCondition);
    }
  };

  const loadFields = async () => {
    // This endpoint return all fields and *paginated* items related to the itemType
    // We only need the fields, we set a pagination of 1 to avoid fetching all items
    const res = await axios.get(`/react/${catalog}/${locale}/${itemType}?simple_fields=true&page=1`);
    const options = res.data.fields.filter(
      field => field.displayable_to_user
    ).map(field => ({
      value: field.uuid,
      label: field.name
    }));

    // The first time we load the options, we want to select the default item
    // if specified.
    if (isFirstLoadOptionsRef.current) {
      isFirstLoadOptionsRef.current = false;

      const _selectedField = options.find(item => item.value == defaultValues?.sort_field_uuid);
      if (_selectedField) {
        handleSelectFieldChange(_selectedField, defaultValues?.condition || '');
        setSelectedFieldCondition(defaultValues?.field_condition || '');
      }
    }

    return {
      options,
      hasMore: false, // All fields are always returned by endpoint
    };
  };

  return (
    <React.Fragment>
      <div className="col-lg-2">
        <FieldConditionSelectElement
          fieldConditionData={fieldConditionData}
          selectedFieldCondition={selectedFieldCondition}
          setSelectedFieldCondition={setSelectedFieldCondition}
          fieldUuid={fieldUuid}
          itemId={itemId}
        />
      </div>
      <div className="col-lg-6">
        <div className="reference-search-container row">
          <div className="col-lg-7">
            <SearchElement
              selectedField={selectedField}
              fieldUuid={fieldUuid}
              itemId={itemId}
              selectedCondition={selectedCondition}
              locale={locale}
              fieldData={fieldData}
              defaultValues={defaultValues}
              itemsUrl={`/react/${catalog}/${locale}/${itemType}?simple_fields=true`}
              catalog={catalog}
              itemType={itemType}
            />
          </div>
          <div className="col-lg-5">
            <FieldSelectElement
              defaultValues={defaultValues}
              loadFields={loadFields}
              selectedField={selectedField}
              handleSelectFieldChange={handleSelectFieldChange}
              fieldUuid={fieldUuid}
              itemId={itemId}
            />
          </div>
        </div>
      </div>
      <ActionButtons
        addComponent={addComponent}
        deleteComponent={deleteComponent}
        canAddComponent={canAddComponent}
        canRemoveComponent={canRemoveComponent}
      />
      <div className="col-lg-3 condition-input-container">
        <ConditionSelectElement
          selectCondition={selectCondition}
          selectedCondition={selectedCondition}
          setSelectedCondition={setSelectedCondition}
          fieldUuid={fieldUuid}
          itemId={itemId}
          selectedField={selectedField}
        />
      </div>
    </React.Fragment>
  );
};

export default Reference;
