import React, { useState, useMemo } from 'react';
import ReactSelect from 'react-select';
import Translations from '../../Translations/components/Translations';

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
    const childChoices = [
      { value: true, label: Translations.messages['advanced_searches.fields.choice_set_search_field.child_choices_activated_yes'] },
      { value: false, label: Translations.messages['advanced_searches.fields.choice_set_search_field.child_choices_activated_no'] },
    ];
    const isChildChoicesActivated = defaultValues["child_choices_activated"] && defaultValues["child_choices_activated"] === "true";

    const defaultValue = childChoices.find(
      (item) => item.value === isChildChoicesActivated,
    );

    return (
      <ReactSelect name={`advanced_search[criteria][${fieldUuid}][${itemId}][child_choices_activated]`}
        options={childChoices}
        classNamePrefix="select"
        placeholder={Translations.messages['advanced_searches.fields.choice_set_search_field.child_choices_activated_placeholder']}
        defaultValue={defaultValue}
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
        <div className="col-lg-1">
          <div className="row">
            {canAddComponent &&
              <div className="col-lg-12">
                <a type="button" onClick={addComponent}>
                  <i className="fa fa-plus"></i>
                </a>
              </div>
            }
            {canRemoveComponent &&
              <div className="col-lg-12">
                <a type="button" onClick={deleteComponent}>
                  <i className="fa fa-trash"></i>
                </a>
              </div>
            }
          </div>
        </div>
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
