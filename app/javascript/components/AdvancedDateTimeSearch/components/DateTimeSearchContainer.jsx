import React, { useState, useEffect, useRef } from 'react';
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

  let getNextId;
  if (!props.getNextId) {
    const nextIdRef = useRef(0);
    getNextId = () => nextIdRef.current++;
  } else {
    getNextId = props.getNextId;
  }

  useEffect(() => {
    if (defaultValues && Object.values(defaultValues).length > 0) {
      Object.values(defaultValues).forEach((defaultValue) => {
        addComponent(defaultValue);
      });
    } else {
      addComponent();
    }
  }, []);

  const addComponent = (defaultValues = {}) => {
    const newItem = {
      itemId: getNextId(),
      defaultValues,
    };
    setComponentsList((prev) => [...prev, newItem]);
  };

  const deleteComponent = (itemId) => {
    setComponentsList((prev) => prev.filter((item) => item.itemId !== itemId));
  };

  return (
    <div>
      {componentsList.map((item, index) => {
        const isLastItem = index === componentsList.length - 1;
        const canRemove = componentsList.length > 1;

        return (
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
              addComponent={() => addComponent()}
              deleteComponent={() => deleteComponent(item.itemId)}
              canAddComponent={isLastItem}
              canRemoveComponent={canRemove}
            />
          </div>
        );
      })}
    </div>
  );
};

export default DateTimeSearchContainer;
