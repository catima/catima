import React, { useMemo } from 'react';
import ReactSelect from 'react-select';
import 'moment';
import DateTime from '../DateTime';
import Translations from '../../../Translations/components/Translations';

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

const DateTimeInputElement = ({ fieldUuid, itemId, selectedCondition, dateFormat, locale, defaultValues, isFromCategory }) => (
  <DateTime
    fieldUuid={fieldUuid}
    itemId={itemId}
    parentSelectedCondition={selectedCondition}
    format={dateFormat}
    locale={locale}
    defaultValues={defaultValues}
    isFromCategory={isFromCategory}
  />
);

const TextInputElement = ({ buildInputNameWithCondition, currentDefaultValue, type = "text", step = null }) => (
  <input
    name={buildInputNameWithCondition}
    type={type}
    className="form-control"
    step={step}
    defaultValue={currentDefaultValue}
  />
);

const BooleanSelectElement = ({ buildInputNameWithCondition, currentDefaultValue, inputData }) => (
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

const ChoiceSetSelectElement = ({ choiceSetOptions, isFromCategory, defaultValues, currentDefaultValue, fieldUuid, itemId, buildInputNameWithCondition }) => {
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

const LoaderElement = () => (
  <div className="loader"></div>
);

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

  // Fonction principale de rendu des inputs
  const renderInput = () => {
    if (isLoading) return null;

    const inputTypeRenderers = {
      [FIELD_TYPES.DATE_TIME]: () => (
        <DateTimeInputElement
          fieldUuid={fieldUuid}
          itemId={itemId}
          selectedCondition={selectedCondition}
          dateFormat={dateFormat}
          locale={locale}
          defaultValues={defaultValues}
          isFromCategory={isFromCategory}
        />
      ),
      [FIELD_TYPES.EMAIL]: () => (
        <TextInputElement
          buildInputNameWithCondition={buildInputNameWithCondition}
          currentDefaultValue={currentDefaultValue}
          type="text"
        />
      ),
      [FIELD_TYPES.INT]: () => (
        <TextInputElement
          buildInputNameWithCondition={buildInputNameWithCondition}
          currentDefaultValue={currentDefaultValue}
          type="number"
        />
      ),
      [FIELD_TYPES.DECIMAL]: () => (
        <TextInputElement
          buildInputNameWithCondition={buildInputNameWithCondition}
          currentDefaultValue={currentDefaultValue}
          type="number"
          step="any"
        />
      ),
      [FIELD_TYPES.URL]: () => (
        <TextInputElement
          buildInputNameWithCondition={buildInputNameWithCondition}
          currentDefaultValue={currentDefaultValue}
          type="url"
        />
      ),
      [FIELD_TYPES.BOOLEAN]: () => (
        <BooleanSelectElement
          buildInputNameWithCondition={buildInputNameWithCondition}
          currentDefaultValue={currentDefaultValue}
          inputData={inputData}
        />
      ),
      [FIELD_TYPES.CHOICE_SET]: () => (
        <ChoiceSetSelectElement
          choiceSetOptions={choiceSetOptions}
          isFromCategory={isFromCategory}
          defaultValues={defaultValues}
          currentDefaultValue={currentDefaultValue}
          fieldUuid={fieldUuid}
          itemId={itemId}
          buildInputNameWithCondition={buildInputNameWithCondition}
        />
      ),
    };

    const renderer = inputTypeRenderers[inputType] || (() => (
      <TextInputElement
        buildInputNameWithCondition={buildInputNameWithCondition}
        currentDefaultValue={currentDefaultValue}
        type="text"
      />
    ));

    return renderer();
  };

  return (
    <div className="single-reference-container">
      {isLoading && <LoaderElement />}
      {renderInput()}
    </div>
  );
};

export default ItemTypeReference;
