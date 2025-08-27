import React, { useState } from 'react';
import ReactSelect from 'react-select';
import Translations from '../../../Translations/components/Translations';
import ChildChoicesElement from './ChildChoicesElement';
import ActionButtons from './ActionButtons';

const DisabledConditionSelectElement = () => (
  <select className="form-select filter-condition" disabled={true}></select>
);

const FieldConditionSelectElement = ({ fieldConditionData, defaultValues, fieldUuid, itemId }) => (
  <select
    className="form-select filter-condition"
    name={`advanced_search[criteria][${fieldUuid}][${itemId}][field_condition]`}
    defaultValue={defaultValues?.field_condition || ''}
  >
    {fieldConditionData.map((item) => {
      return <option key={item.key} value={item.key}>{item.value}</option>
    })}
  </select>
);

const ChoiceSetSelectElement = ({ choiceSet, setSelectedItem, selectedItem, fieldUuid, itemId }) => (
  <div>
    <ReactSelect
      name={`advanced_search[criteria][${fieldUuid}][${itemId}][default]`}
      options={choiceSet.map(item => ({
        value: item.key,
        label: item.label,
        has_childrens: item.has_childrens,
      }))}
      className="basic-multi-select"
      onChange={item => setSelectedItem(item)}
      classNamePrefix="select"
      placeholder={Translations.messages['advanced_searches.fields.choice_set_search_field.select_placeholder']}
      isClearable={true}
      value={selectedItem}
    />
  </div>
);

const ChildChoicesContainerElement = ({ fieldUuid, itemId, defaultValues }) => (
  <ChildChoicesElement
    fieldUuid={fieldUuid}
    itemId={itemId}
    defaultValues={defaultValues}
  />
);

const ChoiceSet = (props) => {
  const {
    fieldUuid,
    itemId,
    choiceSet,
    fieldConditionData,
    defaultValues,
    addComponent,
    deleteComponent,
    canAddComponent,
    canRemoveComponent,
    excludeCondition,
  } = props;

  const [selectedItem, setSelectedItem] = useState([])

  return (
    <div className="col-lg-12 choiceset-search-container choiceSetInput">
      <div className="row">
        <div className="col-lg-2">
          <FieldConditionSelectElement
            fieldConditionData={fieldConditionData}
            defaultValues={defaultValues}
            fieldUuid={fieldUuid}
            itemId={itemId}
          />
        </div>
        <div className={selectedItem?.has_childrens ? 'col-lg-3' : 'col-lg-6'}>
          <ChoiceSetSelectElement
            choiceSet={choiceSet}
            setSelectedItem={setSelectedItem}
            selectedItem={selectedItem}
            fieldUuid={fieldUuid}
            itemId={itemId}
          />
        </div>
        {(selectedItem?.has_childrens) &&
          <div className="col-lg-3">
            <ChildChoicesContainerElement
              fieldUuid={fieldUuid}
              itemId={itemId}
              defaultValues={defaultValues}
            />
          </div>
        }
        <ActionButtons
          addComponent={addComponent}
          deleteComponent={deleteComponent}
          canAddComponent={canAddComponent}
          canRemoveComponent={canRemoveComponent}
        />
        {!selectedItem?.has_childrens && (
          <div className="col-lg-3">
            <DisabledConditionSelectElement />
          </div>
        )}
      </div>
      <div className="row">
        {selectedItem?.has_childrens && (
          <div className="col-lg-3" style={{ marginTop: '10px' }}>
            <DisabledConditionSelectElement />
          </div>
        )}
      </div>
      <input
        type="hidden"
        name={`advanced_search[criteria][${fieldUuid}][${itemId}][exclude_condition]`}
        value={excludeCondition}
      />
    </div>
  );
}

export default ChoiceSet;
