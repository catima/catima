import React, { useMemo } from 'react';
import ReactSelect from 'react-select';
import 'moment';

import DateTimeSearch from '../../AdvancedDateTimeSearch/components/DateTimeSearch';
import Translations from '../../Translations/components/Translations';

// Constants for field types.
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

/**
 * LinkedCategoryInput Component - Handles dynamic inputs based on selected categories.
 * Displays different input types depending on the selected field type.
 */
const LinkedCategoryInput = (props) => {
  const {
    fieldUuid,
    itemId,
    locale,
    selectedCondition,
    defaultValue,
    linkedCategoryData,
  } = props;

  const { inputData, inputType, dateFormat, isLoading } = linkedCategoryData || {
    inputData: null,
    inputType: FIELD_TYPES.TEXT,
    dateFormat: '',
    isLoading: false
  };

  const buildInputNameWithCondition = useMemo(() => {
      const currentCondition = selectedCondition || 'default';
      return `advanced_search[criteria][${fieldUuid}][${itemId}][category_criteria][${currentCondition}]`;
  }, [fieldUuid, selectedCondition, itemId]);

  const choiceSetOptions = useMemo(() => {
    if (!inputData) return [];
    return inputData.map(option => ({
      value: option.key,
      label: option.label
    }));
  }, [inputData]);

  const renderDateTimeInput = () => (
    <DateTimeSearch
      fieldUuid={fieldUuid}
      itemId={itemId}
      parentSelectedCondition={selectedCondition}
      format={dateFormat}
      defaultValues={defaultValue}
      locale={locale}
      isCategory={true}
    />
  );
  const renderTextInput = (type = "text", step = null) => (
    <input
      name={buildInputNameWithCondition}
      type={type}
      className="form-control"
      step={step}
      defaultValue={defaultValue?.category_criteria?.[selectedCondition]}
    />
  );

  const renderBooleanSelect = () => (
    <select
      name={buildInputNameWithCondition}
      className="form-select"
      defaultValue={defaultValue?.category_criteria?.[selectedCondition]}
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
      option => option.value == defaultValue?.category_criteria?.default
    );

    return (
      <ReactSelect
        name={`advanced_search[criteria][${fieldUuid}][${itemId}][category_criteria][default]`}
        isSearchable={true}
        isClearable={true}
        options={choiceSetOptions}
        className="basic-select"
        classNamePrefix="select"
        placeholder={Translations.messages['advanced_searches.fields.choice_set_search_field.select_placeholder']}
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

  return (
    <div className="single-reference-container">
      {isLoading && <div className="loader"></div>}
      {renderInput()}
    </div>
  );
};

export default LinkedCategoryInput;
