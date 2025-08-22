import React, { useState, useEffect, useMemo } from 'react';
import ChoiceSetSearch from './ChoiceSetSearch';

const ChoiceSetSearchContainer = (props) => {
  const {
    fieldUuid,
    catalog,
    choiceSet,
    locale,
    fieldConditionData,
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
          <ChoiceSetSearch
            fieldUuid={fieldUuid}
            itemId={item.itemId}
            choiceSet={choiceSet}
            catalog={catalog}
            fieldConditionData={fieldConditionData}
            defaultValues={item.defaultValues}
            locale={locale}
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

export default ChoiceSetSearchContainer;
