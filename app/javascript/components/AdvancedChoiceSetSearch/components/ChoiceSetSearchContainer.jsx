import React, { useState, useEffect, useMemo } from 'react';
import ChoiceSetSearch from './ChoiceSetSearch';

const ChoiceSetSearchContainer = (props) => {
  const {
    fieldUuid,
    inputName: inputNameProps,
    selectConditionName: selectConditionNameProps,
    fieldConditionName: fieldConditionNameProps,
    categoryInputName: categoryInputNameProps,
    childChoicesActivatedInputName: childChoicesActivatedInputNameProps,
    catalog,
    itemType,
    label,
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

  const inputName = useMemo(() => inputNameProps.split("[0]"), [inputNameProps]);
  const selectConditionName = useMemo(() => selectConditionNameProps.split("[0]"), [selectConditionNameProps]);
  const fieldConditionName = useMemo(() => fieldConditionNameProps.split("[0]"), [fieldConditionNameProps]);
  const categoryInputName = useMemo(() => categoryInputNameProps.split("[0]"), [categoryInputNameProps]);
  const childChoicesActivatedInputName = useMemo(() => childChoicesActivatedInputNameProps.split("[0]"), [childChoicesActivatedInputNameProps]);

  const [componentsList, setComponentsList] = useState([]);

  useEffect(() => {
    if (defaultValues && Object.values(defaultValues).length > 0) {
      Object.values(defaultValues).forEach((defaultValue, index) => {
        addComponent(index, defaultValue); // TODO TESTER l'ID 8itemId, index)
      });
    } else {
      addComponent(0);
    }
  }, []);

  const addComponent = (itemId, defaultValues = {}) => {
    const newItem = {
      itemId,
      fieldUuid,
      itemDefaultKey: defaultValues[defaultValues.condition || "default"],
      catalog,
      itemType,
      label,
      choiceSet,
      categoryInputName: _buildName(categoryInputName, categoryInputNameProps, itemId),
      childChoicesActivatedInputName: _buildName(childChoicesActivatedInputName, childChoicesActivatedInputNameProps, itemId),
      childChoicesActivatedPlaceholder,
      childChoicesActivatedYesLabel,
      childChoicesActivatedNoLabel,
      locale,
      searchPlaceholder,
      filterPlaceholder,
      inputName: _buildName(inputName, inputNameProps, itemId),
      selectConditionName: _buildName(selectConditionName, selectConditionNameProps, itemId),
      fieldConditionName: _buildName(fieldConditionName, fieldConditionNameProps, itemId),
      fieldConditionData,
      defaultValues: defaultValues,
      addComponent: () => addComponent(itemId + 1),
      deleteComponent: () => deleteComponent(itemId),
    };
    setComponentsList((prev) => [...prev, newItem]);
  };

  const deleteComponent = (itemId) => {
    setComponentsList((prev) => prev.filter((item) => item.itemId !== itemId));
  };

  const _buildName = (split, raw, id, joiner = '[') => {
    if (split.length === 2) {
      return split[0] + joiner + id + (joiner === '[' ? ']' : joiner) + split[1];
    }
    return raw;
  };

  return (
    <div>
      {componentsList.map((item) =>
        <div key={item.itemId} className="component-search-row row">
          <ChoiceSetSearch {...item} componentList={componentsList} />
        </div>
      )}
    </div>
  );
};

export default ChoiceSetSearchContainer;
