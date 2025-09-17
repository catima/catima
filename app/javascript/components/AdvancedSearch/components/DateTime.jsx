import React, { useState, useEffect, useRef, useMemo } from 'react';
import DateTimeInput from './partials/DateTimeInput';
import $ from 'jquery';
import { Namespace } from '@eonasdan/tempus-dominus';
import ActionButtons from './partials/ActionButtons';

const DateTimeInputElement = ({ type, itemId, fieldUuid, startDateInputName, endDateInputName, datepickerRefStart, datepickerRefEnd, disabled, locale, format, defaultStart, defaultEnd, allowDateTimeBC }) => {
  const isStart = type === 'start';
  const _itemId = itemId !== null ? `-${itemId}` : '';

  return (
    <DateTimeInput
      inputId={`advanced_search_criteria_${fieldUuid}_id-datetime${_itemId}`}
      inputSuffixId={`${type}_date`}
      inputName={isStart ? startDateInputName : endDateInputName}
      defaultValues={isStart ? defaultStart : defaultEnd}
      minDate={isStart ? undefined : defaultStart}
      maxDate={isStart ? defaultEnd : undefined}
      disabled={disabled}
      allowBC={allowDateTimeBC}
      format={format}
      locale={locale}
      ref={isStart ? datepickerRefStart : datepickerRefEnd}
    />
  );
};

const FieldConditionSelectElement = ({ fieldConditionData, selectedFieldCondition, setSelectedFieldCondition, fieldUuid, itemId }) => {
  if (!fieldConditionData) return null;

  const _itemId = itemId !== null ? `[${itemId}]` : '';

  return (
    <div className="col-lg-2">
      <select
        className="form-select filter-condition"
        name={`advanced_search[criteria][${fieldUuid}]${_itemId}[field_condition]`}
        value={selectedFieldCondition}
        onChange={(e) => setSelectedFieldCondition(e.target.value)}
      >
        {fieldConditionData.map((item) => (
          <option key={item.key} value={item.key}>
            {item.value}
          </option>
        ))}
      </select>
    </div>
  );
};

const ConditionSelectElement = ({ selectCondition, selectedCondition, handleSelectCondition, fieldUuid, itemId }) => {
  if (!selectCondition?.length) return null;

  const _itemId = itemId !== null ? `[${itemId}]` : '';

  return (
    <div className="col-lg-3">
      <select
        className="form-select filter-condition"
        name={`advanced_search[criteria][${fieldUuid}]${_itemId}[condition]`}
        value={selectedCondition}
        onChange={(e) => handleSelectCondition(e.target.value)}
      >
        {selectCondition.map((item) => (
          <option key={item.key} value={item.key}>
            {item.value}
          </option>
        ))}
      </select>
    </div>
  );
};

/**
 * DateTime Component - Handles date/time range selection with conditions.
 * Supports single dates, date ranges, and various filtering conditions.
 */
const DateTime = (props) => {
  const {
    fieldUuid,
    itemId = null,
    selectCondition = [],
    fieldConditionData,
    parentSelectedCondition,
    format,
    defaultValues,
    locale,
    isFromCategory = false,
    allowDateTimeBC = false,
    excludeCondition = null,
    addComponent = null,
    deleteComponent = null,
    canAddComponent = false,
    canRemoveComponent = false,
  } = props;

  // Extract default values from props
  const selectConditionDefault = defaultValues?.condition;
  const fieldConditionDefault = defaultValues?.field_condition;

  const defaultDates = isFromCategory ? defaultValues?.['category_criteria'] : defaultValues;
  const defaultStart = defaultDates?.['start']?.[defaultValues?.condition || 'exact'];
  const defaultEnd = defaultDates?.['end']?.[defaultValues?.condition || 'exact'];

  const [selectedCondition, setSelectedCondition] = useState('');
  const [selectedFieldCondition, setSelectedFieldCondition] = useState(fieldConditionDefault || '');
  const [disabled, setDisabled] = useState(false);

  const _itemId = itemId !== null ? `-${itemId}` : '';
  const dateTimeCollapseId = `advanced_search_criteria_${fieldUuid}_id-collapse${_itemId}`;

  const getDateInputName = (type) => {
    const currentCondition = selectedCondition || 'exact';
    const _itemId = itemId !== null ? `[${itemId}]` : '';
    const _categorySuffix = isFromCategory ? '[category_criteria]' : '';
    return `advanced_search[criteria][${fieldUuid}]${_itemId}${_categorySuffix}[${type}][${currentCondition}]`;
  };

  const startDateInputName = useMemo(() => getDateInputName('start'), [getDateInputName]);
  const endDateInputName = useMemo(() => getDateInputName('end'), [getDateInputName]);

  // Refs for datepicker components
  const datepickerRefStart = useRef();
  const datepickerRefEnd = useRef();

  // Helper functions
  const updateDatepickerEndRestriction = (event) => {
    if (datepickerRefEnd.current) {
      datepickerRefEnd.current.updateOptions({
        restrictions: { minDate: event.date }
      });
    }
  };

  const updateDatepickerStartRestriction = (event) => {
    if (datepickerRefStart.current) {
      datepickerRefStart.current.updateOptions({
        restrictions: { maxDate: event.date }
      });
    }
  };

  const handleSelectCondition = (newCondition) => {
    setSelectedCondition(newCondition || '');
    const condition = newCondition || 'exact';

    // Check if the condition requires a date range.
    if (condition === 'between' || condition === 'outside') {
      setDisabled(true);

      $(`#${dateTimeCollapseId}`).slideDown();

      datepickerRefStart?.current?.subscribe(
        Namespace.events.change,
        updateDatepickerEndRestriction,
      );
      datepickerRefEnd?.current?.subscribe(
        Namespace.events.change,
        updateDatepickerStartRestriction,
      );
    } else {
      setDisabled(false);

      $(`#${dateTimeCollapseId}`).slideUp();

      datepickerRefEnd?.current?.clear();
    }
  };

  useEffect(() => {
    if (selectCondition?.length > 0) {
      handleSelectCondition(selectConditionDefault || selectCondition[0].key);
    }
  }, [selectCondition, selectConditionDefault]);

  useEffect(() => {
    if (parentSelectedCondition) {
      handleSelectCondition(parentSelectedCondition);
    }
  }, [parentSelectedCondition]);

  // Main render
  const hasSelectCondition = selectCondition.length > 0;
  const hasActionButtons = canAddComponent || canRemoveComponent;

  const columnClass = hasSelectCondition
    ? (hasActionButtons ? 'col-lg-6' : 'col-lg-7')
    : (hasActionButtons ? 'col-lg-11' : 'col-lg-12');

  return (
    <React.Fragment>
      <FieldConditionSelectElement
        fieldConditionData={fieldConditionData}
        selectedFieldCondition={selectedFieldCondition}
        setSelectedFieldCondition={setSelectedFieldCondition}
        fieldUuid={fieldUuid}
        itemId={itemId}
      />

      <div className={columnClass}>
        <DateTimeInputElement
          type="start"
          itemId={itemId}
          fieldUuid={fieldUuid}
          startDateInputName={startDateInputName}
          endDateInputName={endDateInputName}
          datepickerRefStart={datepickerRefStart}
          datepickerRefEnd={datepickerRefEnd}
          disabled={disabled}
          locale={locale}
          format={format}
          defaultStart={defaultStart}
          defaultEnd={defaultEnd}
          allowDateTimeBC={allowDateTimeBC}
        />

        <div className="collapse" id={dateTimeCollapseId}>
          <DateTimeInputElement
            type="end"
            itemId={itemId}
            fieldUuid={fieldUuid}
            startDateInputName={startDateInputName}
            endDateInputName={endDateInputName}
            datepickerRefStart={datepickerRefStart}
            datepickerRefEnd={datepickerRefEnd}
            disabled={disabled}
            locale={locale}
            format={format}
            defaultStart={defaultStart}
            defaultEnd={defaultEnd}
            allowDateTimeBC={allowDateTimeBC}
          />
        </div>
      </div>

      <ActionButtons
        addComponent={addComponent}
        deleteComponent={deleteComponent}
        canAddComponent={canAddComponent}
        canRemoveComponent={canRemoveComponent}
      />

      <ConditionSelectElement
        selectCondition={selectCondition}
        selectedCondition={selectedCondition}
        handleSelectCondition={handleSelectCondition}
        fieldUuid={fieldUuid}
        itemId={itemId}
      />

      {excludeCondition && (
        <input
          type="hidden"
          name={`advanced_search[criteria][${fieldUuid}][${itemId}][exclude_condition]`}
          value={excludeCondition}
        />
      )}
    </React.Fragment>
  );
};

export default DateTime;
