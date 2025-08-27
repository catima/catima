import React, { useState, useMemo } from 'react';
import ReactSelect from 'react-select';
import Translations from '../../Translations/components/Translations';
import ChildChoicesElement from '../../AdvancedSearchShared/ChildChoicesElement';
import ComponentActionButtons from '../../AdvancedSearchShared/ComponentActionButtons';

const ChoiceSetSearch = (props) => {
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

  function renderConditionElement() {
    // This select has no use and is only here to be visually aligned with other selects.
    return (
      <select className="form-select filter-condition" disabled={true}></select>
    );
  }

  function renderFieldConditionElement() {
    return (
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
  }

  function renderChoiceSetElement() {
    return (
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
  }

  function renderChildChoicesElement() {
    return (
      <ChildChoicesElement
        fieldUuid={fieldUuid}
        itemId={itemId}
        defaultValues={defaultValues}
      />
    );
  }

  return (
    <div className="col-lg-12 choiceset-search-container choiceSetInput">
      <div className="row">
        <div className="col-lg-2">
          {renderFieldConditionElement()}
        </div>
        <div className={selectedItem?.has_childrens ? 'col-lg-3' : 'col-lg-6'}>
          {renderChoiceSetElement()}
        </div>
        {(selectedItem?.has_childrens) &&
          <div className="col-lg-3">
            {renderChildChoicesElement()}
          </div>
        }
        <ComponentActionButtons
          addComponent={addComponent}
          deleteComponent={deleteComponent}
          canAddComponent={canAddComponent}
          canRemoveComponent={canRemoveComponent}
        />
        {!selectedItem?.has_childrens && (
          <div className="col-lg-3">
            {renderConditionElement()}
          </div>
        )}
      </div>
      <div className="row">
        {selectedItem?.has_childrens && (
          <div className="col-lg-3" style={{ marginTop: '10px' }}>
            {renderConditionElement()}
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

export default ChoiceSetSearch;
