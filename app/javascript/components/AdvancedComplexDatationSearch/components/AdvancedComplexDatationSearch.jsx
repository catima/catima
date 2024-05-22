import React, {useState} from 'react';
import DateTimeSearch from './DateTimeSearch';
import ChoiceSetSearchContainer from './ChoiceSetSearchContainer'
import Translations from '../../Translations/components/Translations';

const AdvancedComplexDatationSearch = (props) => {
  const {
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
    localizedDateTimeData,
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
    label,
    items,
    childChoicesActivatedPlaceholder,
    childChoicesActivatedYesLabel,
    childChoicesActivatedNoLabel,
    searchPlaceholder,
    filterPlaceholder,
    choiceSelectCondition,
    multiple,
    choiceFieldConditionData
  } = props

  const [selectedExcludeCondition, setSelectedExcludeCondition]= useState('')

  function _selectExcludeCondition(event) {
    if (typeof event === 'undefined' || event.action !== "pop-value" || !req) {
      if (typeof event !== 'undefined') {
        setSelectedExcludeCondition(event.target.value);
      } else {
        setSelectedExcludeCondition('');
      }
    }
  }
  function renderSelectExcludeConditionElement() {
    return (
        <select className="form-select filter-condition" name={selectExcludeConditionName}
                value={selectedExcludeCondition} onChange={_selectExcludeCondition}>
          {selectExcludeConditions.map((item) => {
            return <option key={item.key} value={item.key}>{item.value}</option>
          })}
        </select>
    );
  }

  return (
    <div>
      <DateTimeSearch
        startDateInputName={startDateInputName}
        endDateInputName={endDateInputName}
        disableInputByCondition={disableInputByCondition}
        srcId={srcId}
        srcRef={srcRef}
        selectCondition={selectCondition}
        selectConditionName={selectConditionName}
        inputStart={inputStart}
        localizedDateTimeData={localizedDateTimeData}
        locale={locale}
        format={format}
        fieldConditionName={fieldConditionName}
        fieldConditionData={fieldConditionData}
        inputEnd={inputEnd}
        allowDateTimeBC={allowDateTimeBC}
        excludeCondition={selectedExcludeCondition}
      />
      <ChoiceSetSearchContainer
        inputName={inputName}
        srcId={srcId}
        srcRef={srcRef}
        selectConditionName={choiceSelectConditionName}
        fieldConditionName={choiceFieldConditionName}
        categoryInputName={categoryInputName}
        childChoicesActivatedInputName={childChoicesActivatedInputName}
        linkedCategoryInputName={linkedCategoryInputName}
        catalog={catalog}
        itemType={itemType}
        label={label}
        items={items}
        childChoicesActivatedPlaceholder={childChoicesActivatedPlaceholder}
        childChoicesActivatedYesLabel={childChoicesActivatedYesLabel}
        childChoicesActivatedNoLabel={childChoicesActivatedNoLabel}
        locale={locale}
        searchPlaceholder={searchPlaceholder}
        filterPlaceholder={filterPlaceholder}
        selectCondition={choiceSelectCondition}
        multiple={multiple}
        fieldConditionData={choiceFieldConditionData}
        excludeCondition={selectedExcludeCondition}
      />
      <div className="row">
        <div className="col-lg-2">
          <div>{Translations.messages['advanced_searches.fields.complex_datation_search_field.exclude']}</div>
        </div>
        <div className="col-lg-6">
          <div>
            {renderSelectExcludeConditionElement()}
          </div>
        </div>
      </div>
    </div>
  )
}

export default AdvancedComplexDatationSearch
