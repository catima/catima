import React, { useState, useRef } from 'react';
import Container from './Container';
import ChoiceSet from './partials/ComplexDatationChoiceSet';
import Translations from '../../Translations/components/Translations';
import DateTime from './DateTime';

const ExcludeConditionSelectElement = ({ fieldUuid, selectedExcludeCondition, setSelectedExcludeCondition, selectExcludeConditions }) => (
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
);

const ComplexDatation = (props) => {
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

  // Centralized ID management
  const nextIdRef = useRef(0);

  const getNextId = () => {
    return nextIdRef.current++;
  };

  return (
    <div>
      <Container
        fieldUuid={fieldUuid}
        defaultValues={defaultValues}
        childComponent={DateTime}
        childProps={{
          selectCondition,
          fieldConditionData,
          locale,
          format,
          allowDateTimeBC,
          excludeCondition: selectedExcludeCondition,
        }}
        getNextId={getNextId}
      />
      <Container
        fieldUuid={fieldUuid}
        defaultValues={defaultValues}
        childComponent={ChoiceSet}
        childProps={{
          choiceSet,
          fieldConditionData: choiceFieldConditionData,
          excludeCondition: selectedExcludeCondition,
        }}
        getNextId={getNextId}
      />
      <ExcludeConditionSelectElement
        fieldUuid={fieldUuid}
        selectedExcludeCondition={selectedExcludeCondition}
        setSelectedExcludeCondition={setSelectedExcludeCondition}
        selectExcludeConditions={selectExcludeConditions}
      />
    </div>
  );
};

export default ComplexDatation;
