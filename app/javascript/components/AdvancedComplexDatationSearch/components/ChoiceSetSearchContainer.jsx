import React, { useState, useEffect } from 'react';
import ChoiceSetSearch from './ChoiceSetSearch';

const ChoiceSetSearchContainer = (props) => {
  const {
    fieldUuid,
    choiceSet,
    childChoicesActivatedPlaceholder,
    childChoicesActivatedYesLabel,
    childChoicesActivatedNoLabel,
    searchPlaceholder,
    fieldConditionData,
    defaultValues,
    excludeCondition,
  } = props;

  const [componentsList, setComponentsList] = useState([]);

  useEffect(() => {
    // TODO REMOVE 999 AND SYNC THE VALUE WITH PARENT. TEST THAT ITS RETROCOMPATIBLE.
    if (defaultValues && Object.values(defaultValues).length > 0) {
      Object.values(defaultValues).forEach((defaultValue, index) => {
        addComponent(index + 999, defaultValue);
      });
    } else {
      addComponent(999);
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
    <div className={'mt-1'}>
      {componentsList.map((item, index) =>
        <div key={item.itemId} className="component-search-row row">
          <ChoiceSetSearch
            fieldUuid={fieldUuid}
            itemId={item.itemId}
            choiceSet={choiceSet}
            searchPlaceholder={searchPlaceholder}
            fieldConditionData={fieldConditionData}
            defaultValues={item.defaultValues}
            childChoicesActivatedPlaceholder={childChoicesActivatedPlaceholder}
            childChoicesActivatedYesLabel={childChoicesActivatedYesLabel}
            childChoicesActivatedNoLabel={childChoicesActivatedNoLabel}
            addComponent={item.addComponent}
            deleteComponent={item.deleteComponent}
            excludeCondition={excludeCondition}
            canAddComponent={index === componentsList.length - 1}
            canRemoveComponent={componentsList.length > 1}
          />
        </div>
      )}
    </div>
  );
};

export default ChoiceSetSearchContainer;
