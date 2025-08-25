import React, { useState } from 'react';
import DateTimeSearch from './DateTimeSearch';
import ChoiceSetSearchContainer from './ChoiceSetSearchContainer';
import Translations from '../../Translations/components/Translations';

const AdvancedComplexDatationSearch = (props) => {
  const {
    fieldUuid,
    locale,
    srcId,
    srcRef,
    startDateInputName,
    endDateInputName,
    disableInputByCondition,
    selectCondition,
    selectConditionName,
    selectExcludeConditions,
    selectExcludeConditionName,
    inputStart,
    format,
    fieldConditionName,
    fieldConditionData,
    inputEnd,
    allowDateTimeBC,
    inputName,
    choiceSelectConditionName,
    choiceFieldConditionName,
    categoryInputName,
    childChoicesActivatedInputName,
    linkedCategoryInputName,
    catalog,
    itemType,
    choiceSet,
    multiple,
    choiceFieldConditionData
  } = props;

  const [selectedExcludeCondition, setSelectedExcludeCondition] = useState('');

  return (
    <div>
      <DateTimeSearch
        fieldUuid={fieldUuid}
        startDateInputName={startDateInputName}
        endDateInputName={endDateInputName}
        disableInputByCondition={disableInputByCondition}
        srcId={srcId}
        srcRef={srcRef}
        selectCondition={selectCondition}
        selectConditionName={selectConditionName}
        inputStart={inputStart}
        locale={locale}
        format={format}
        fieldConditionName={fieldConditionName}
        fieldConditionData={fieldConditionData}
        inputEnd={inputEnd}
        allowDateTimeBC={allowDateTimeBC}
        excludeCondition={selectedExcludeCondition}
      />
      <ChoiceSetSearchContainer
        fieldUuid={fieldUuid}
        inputName={inputName}
        srcId={srcId}
        srcRef={srcRef}
        fieldConditionName={choiceFieldConditionName}
        categoryInputName={categoryInputName}
        childChoicesActivatedInputName={childChoicesActivatedInputName}
        linkedCategoryInputName={linkedCategoryInputName}
        catalog={catalog}
        itemType={itemType}
        choiceSet={choiceSet}
        locale={locale}
        multiple={multiple}
        fieldConditionData={choiceFieldConditionData}
        excludeCondition={selectedExcludeCondition}
      />
      <div className="row">
        <div className="col-lg-2">
          <div>
            {Translations.messages['advanced_searches.fields.complex_datation_search_field.exclude']}
          </div>
        </div>
        <div className="col-lg-6">
          <div>
            <select
              className="form-select filter-condition"
              name={selectExcludeConditionName}
              value={selectedExcludeCondition}
              onChange={e => setSelectedExcludeCondition(e.target.value || '')}
            >
              {selectExcludeConditions.map((item) => {
                return (
                  <option key={item.key} value={item.key}>
                    {item.value}
                  </option>
                );
              })}
            </select>
          </div>
        </div>
      </div>
    </div>
  );
};

export default AdvancedComplexDatationSearch
