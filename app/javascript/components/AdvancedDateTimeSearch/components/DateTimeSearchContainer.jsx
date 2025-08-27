import React, { useState, useEffect } from 'react';
import DateTimeSearch from './DateTimeSearch';

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
