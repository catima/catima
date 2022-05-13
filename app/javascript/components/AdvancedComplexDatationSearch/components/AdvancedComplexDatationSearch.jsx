import React from 'react';
import DateTimeSearch from './DateTimeSearch';
import ChoiceSetSearchContainer from './ChoiceSetSearchContainer'

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
    inputStart,
    localizedDateTimeData,
    format,
    fieldConditionName,
    fieldConditionData,
    inputEnd,
    allowBC,
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
        allowBC={allowBC}
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
      />
    </div>
  )
}

export default AdvancedComplexDatationSearch
