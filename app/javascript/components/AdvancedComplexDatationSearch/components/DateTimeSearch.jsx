import React, { useState, useEffect, useRef, useMemo, useCallback } from 'react';
import DateTimeInput from './DateTimeInput';
import $ from 'jquery';
import { Namespace } from '@eonasdan/tempus-dominus';

/**
 * DateTimeSearch Component - Handles date/time range selection with conditions.
 * Supports single dates, date ranges, and various filtering conditions.
 */
const DateTimeSearch = (props) => {
  const {
    fieldUuid,
    itemId = null,
    selectCondition = [],
    fieldConditionData,
    parentSelectedCondition,
    format,
    defaultValues,
    locale,
    isCategory = false,
    allowDateTimeBC = false,
    excludeCondition,
    addComponent = null,
    deleteComponent = null,
    canAddComponent = false,
    canRemoveComponent = false,
  } = props;

  // Extract default values from props
  const selectConditionDefault = defaultValues?.condition;
  const fieldConditionDefault = defaultValues?.field_condition;

  const defaultDates = isCategory ? defaultValues?.['category_criteria'] : defaultValues;
  const defaultStart = defaultDates?.['start']?.[defaultValues?.condition || 'exact'];
  const defaultEnd = defaultDates?.['end']?.[defaultValues?.condition || 'exact'];

  const [selectedCondition, setSelectedCondition] = useState('');
  const [selectedFieldCondition, setSelectedFieldCondition] = useState(fieldConditionDefault || '');
  const [disabled, setDisabled] = useState(false);

  const _itemId = itemId !== null ? `-${itemId}` : '';
  const dateTimeCollapseId = `advanced_search_criteria_${fieldUuid}_id-collapse${_itemId}`;

  const getDateInputName = useCallback((type) => {
      const currentCondition = selectedCondition || 'exact';
      const _itemId = itemId !== null ? `[${itemId}]` : '';
      const _categorySuffix = isCategory ? '[category_criteria]' : '';
      return `advanced_search[criteria][${fieldUuid}]${_itemId}${_categorySuffix}[${type}][${currentCondition}]`;
  }, [fieldUuid, selectedCondition, itemId, isCategory]);

  const startDateInputName = useMemo(() => getDateInputName('start'), [getDateInputName]);
  const endDateInputName = useMemo(() => getDateInputName('end'), [getDateInputName]);

  // Refs for datepicker components
  const datepickerRefStart = useRef();
  const datepickerRefEnd = useRef();

  // Helper functions
  const updateDatepickerEndRestriction = useCallback((event) => {
    if (datepickerRefEnd.current) {
      datepickerRefEnd.current.updateOptions({
        restrictions: { minDate: event.date }
      });
    }
  }, []);

  const updateDatepickerStartRestriction = useCallback((event) => {
    if (datepickerRefStart.current) {
      datepickerRefStart.current.updateOptions({
        restrictions: { maxDate: event.date }
      });
    }
  }, []);

  const handleSelectCondition = useCallback((newCondition) => {
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
  }, [dateTimeCollapseId]);

  // Effects
  useEffect(() => {
    if (selectCondition?.length > 0) {
      handleSelectCondition(selectConditionDefault || selectCondition[0].key);
    }
  }, [selectCondition, selectConditionDefault, handleSelectCondition]);

  useEffect(() => {
    if (parentSelectedCondition) {
      handleSelectCondition(parentSelectedCondition);
    }
  }, [parentSelectedCondition, handleSelectCondition]);

  // Render functions
  const renderDateTimeInput = useCallback((type) => {
    const isStart = type === 'start';
    const _itemId = itemId !== null ? `-${itemId}` : '';

    return (
      <div className="col-lg-12">
        <DateTimeInput
          inputId={`advanced_search_criteria_${fieldUuid}_id-datetime${_itemId}`}
          inputSuffixId={`${type}_date`}
          inputName={isStart ? startDateInputName : endDateInputName}
          defaultValue={isStart ? defaultStart : defaultEnd}
          minDate={isStart ? undefined : defaultStart}
          maxDate={isStart ? defaultEnd : undefined}
          disabled={disabled}
          allowBC={allowDateTimeBC}
          format={format}
          locale={locale}
          ref={isStart ? datepickerRefStart : datepickerRefEnd}
        />
      </div>
    );
  }, [
    startDateInputName, endDateInputName, datepickerRefStart, datepickerRefEnd,
    disabled, locale, format, defaultStart, defaultEnd
  ]);

  const renderFieldConditionElement = useCallback(() => {
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
  }, [fieldConditionData, selectedFieldCondition]);

  const renderSelectConditionElement = useCallback(() => {
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
  }, [selectCondition, selectedCondition, handleSelectCondition]);

  // Main render
  return (
    <div className="datetime-search-container row">
      {renderFieldConditionElement()}

      <div className={selectCondition.length > 0 ? 'col-lg-6' : 'col-lg-11'}>
        {renderDateTimeInput('start')}

        <div className="collapse" id={dateTimeCollapseId}>
          {renderDateTimeInput('end')}
        </div>
      </div>

      <div className="col-lg-1">
        <div className="row">
          {canAddComponent && (
            <div className="col-lg-12">
              <a type="button" onClick={addComponent}>
                <i className="fa fa-plus"></i>
              </a>
            </div>
          )}
          {canRemoveComponent && (
            <div className="col-lg-12">
              <a type="button" onClick={deleteComponent}>
                <i className="fa fa-trash"></i>
              </a>
            </div>
          )}
        </div>
      </div>

      {renderSelectConditionElement()}

      <input
        type="hidden"
        name={`advanced_search[criteria][${fieldUuid}][${itemId}][exclude_condition]`}
        value={excludeCondition}
      />
    </div>
  );
};

// TODO FACTORIZE WITH OTHER CONTAINER.
const DateTimeSearchContainer = (props) => {
  const {
    fieldUuid,
    selectCondition,
    fieldConditionData,
    format,
    locale,
    allowDateTimeBC,
    excludeCondition,
    defaultValues,
  } = props;

  const [componentsList, setComponentsList] = useState([]);

  useEffect(() => {
    console.log(componentsList);
  }, [componentsList]);

  useEffect(() => {
    if (defaultValues && Object.values(defaultValues).length > 0) {
      Object.values(defaultValues).forEach((defaultValue, index) => {
        addComponent(index, defaultValue);
      });
    } else {
      addComponent(0);
    }
  }, []);

  const addComponent = (itemId, defaultValues = {}) => {
    const newItem = {
      itemId,
      defaultValues,
      addComponent: () => addComponent(itemId + 1),
      deleteComponent: () => deleteComponent(itemId),
    };
    setComponentsList((prev) => [...prev, newItem]);
  };

  const deleteComponent = (itemId) => {
    setComponentsList((prev) => prev.filter((item) => item.itemId !== itemId));
  };

  return (
    <div>
      {componentsList.map((item, index) =>
        <div key={item.itemId} className="component-search-row row">
          <DateTimeSearch
            fieldUuid={fieldUuid}
            itemId={item.itemId}
            selectCondition={selectCondition}
            fieldConditionData={fieldConditionData}
            defaultValues={item.defaultValues}
            locale={locale}
            format={format}
            allowDateTimeBC={allowDateTimeBC}
            excludeCondition={excludeCondition}
            addComponent={item.addComponent}
            deleteComponent={item.deleteComponent}
            canAddComponent={index === componentsList.length - 1}
            canRemoveComponent={componentsList.length > 1}
          />
        </div>
      )}
    </div>
  );
};

export default DateTimeSearchContainer;
