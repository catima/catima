import React, { useState } from 'react';
import ChoiceSetSearchContainer from './ChoiceSetSearchContainer';
import Translations from '../../Translations/components/Translations';
import DateTimeSearchContainer from '../../AdvancedDateTimeSearch/components/DateTimeSearchContainer';

const AdvancedComplexDatationSearch = (props) => {
  const {
    fieldUuid,
    locale,
    selectCondition,
    selectExcludeConditions,
    format,
    fieldConditionData,
    allowDateTimeBC,
    choiceSet,
    choiceFieldConditionData,
    defaultValues,
  } = props;

  const [selectedExcludeCondition, setSelectedExcludeCondition] = useState('');

  return (
    <div>
      <DateTimeSearchContainer
        fieldUuid={fieldUuid}
        selectCondition={selectCondition}
        fieldConditionData={fieldConditionData}
        format={format}
        locale={locale}
        allowDateTimeBC={allowDateTimeBC}
        excludeCondition={selectedExcludeCondition}
        defaultValues={defaultValues}
      />
      <ChoiceSetSearchContainer
        fieldUuid={fieldUuid}
        choiceSet={choiceSet}
        fieldConditionData={choiceFieldConditionData}
        excludeCondition={selectedExcludeCondition}
        defaultValues={defaultValues}
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
              name={`advanced_search[criteria][${fieldUuid}][exclude_condition]`}
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
