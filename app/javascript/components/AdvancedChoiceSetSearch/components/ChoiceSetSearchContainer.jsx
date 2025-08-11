import React, { useState, useEffect, useMemo } from 'react';
import ChoiceSetSearch from './ChoiceSetSearch';

const ChoiceSetSearchContainer = (props) => {
  const {
    fieldUuid,
    catalog,
    choiceSet,
    childChoicesActivatedPlaceholder,
    childChoicesActivatedYesLabel,
    childChoicesActivatedNoLabel,
    locale,
    searchPlaceholder,
    filterPlaceholder,
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
      fieldUuid,
      itemId,
      choiceSet,
      itemDefaultKey: defaultValues[defaultValues.condition || "default"],
      catalog,
      searchPlaceholder,
      filterPlaceholder,
      fieldConditionData,
      defaultValues,
      locale,
      childChoicesActivatedPlaceholder,
      childChoicesActivatedYesLabel,
      childChoicesActivatedNoLabel,
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
            {...item}
            canAddComponent={index === componentsList.length - 1}
            canRemoveComponent={componentsList.length > 1}
          />
        </div>
      )}
    </div>
  );
};

export default ChoiceSetSearchContainer;
