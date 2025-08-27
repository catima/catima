import React, { useMemo } from 'react';
import ReactSelect from 'react-select';
import 'moment';
import DateTimeSearch from '../AdvancedDateTimeSearch/components/DateTimeSearch';
import Translations from '../Translations/components/Translations';

// Constants for field types.
export const FIELD_TYPES = {
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
 * ItemTypeReference - Unified component for related item type
 */
const ItemTypeReference = (props) => {
  const {
    fieldUuid,
    itemId,
    selectedCondition,
    locale,
    defaultValues,
    fetchedData,
    isFromCategory = false
  } = props;

  const data = fetchedData || {
    inputData: null,
    inputType: FIELD_TYPES.TEXT,
    dateFormat: '',
    isLoading: false
  };

  const { inputData, inputType, dateFormat, isLoading } = data;

  const buildInputNameWithCondition = useMemo(() => {
    const currentCondition = selectedCondition || 'default';
    const categoryCriteria = isFromCategory ? '[category_criteria]' : '';

    return `advanced_search[criteria][${fieldUuid}][${itemId}]${categoryCriteria}[${currentCondition}]`;
  }, [fieldUuid, selectedCondition, itemId, isFromCategory]);

  const choiceSetOptions = useMemo(() => {
    if (!inputData) return [];
    return inputData.map(option => ({
      value: option.key,
      label: option.label
    }));
  }, [inputData]);

  const currentDefaultValue = useMemo(() => {
    if (isFromCategory) {
        return defaultValues?.category_criteria?.[defaultValues?.condition || "default"];
    }
    return defaultValues?.[defaultValues?.condition || "default"];
  }, [isFromCategory, defaultValues, defaultValues]);

  // Rendu des différents types d'input
  const renderDateTimeInput = () => (
    <DateTimeSearch
      fieldUuid={fieldUuid}
      itemId={itemId}
      parentSelectedCondition={selectedCondition}
      format={dateFormat}
      locale={locale}
      defaultValues={defaultValues}
      isFromCategory={isFromCategory}
    />
  );

  const renderTextInput = (type = "text", step = null) => (
    <input
      name={buildInputNameWithCondition}
      type={type}
      className="form-control"
      step={step}
      defaultValue={currentDefaultValue}
    />
  );

  const renderBooleanSelect = () => (
    <select
      name={buildInputNameWithCondition}
      className="form-select"
      defaultValue={currentDefaultValue}
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
      option => option.value == (isFromCategory ?
        defaultValues?.category_criteria?.default :
        currentDefaultValue
      )
    );

    const inputName = isFromCategory ?
      `advanced_search[criteria][${fieldUuid}][${itemId}][category_criteria][default]` :
      buildInputNameWithCondition;

    return (
      <ReactSelect
        name={inputName}
        isSearchable={true}
        isClearable={true}
        options={choiceSetOptions}
        className="basic-select"
        classNamePrefix="select"
        placeholder={Translations.messages['advanced_searches.fields.choice_set_search_field.select_placeholder']}
        noOptionsMessage={() => Translations.messages['catalog_admin.items.reference_editor.no_options']}
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

export default ItemTypeReference;
