import React, { useState, useEffect, useMemo } from 'react';
import ChoiceSetSearch from './ChoiceSetSearch';

const ChoiceSetSearchContainer = (props) => {
  const {
    inputName: inputNameProps,
    srcId: srcIdProps,
    srcRef: srcRefProps,
    selectConditionName: selectConditionNameProps,
    fieldConditionName: fieldConditionNameProps,
    categoryInputName: categoryInputNameProps,
    childChoicesActivatedInputName: childChoicesActivatedInputNameProps,
    linkedCategoryInputName: linkedCategoryInputNameProps,
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
    selectCondition,
    multiple,
    fieldConditionData,
    defaultValues,
  } = props;

  const inputName = useMemo(() => inputNameProps.split("[0]"), [inputNameProps]);
  const srcId = useMemo(() => srcIdProps.split("_0_"), [srcIdProps]);
  const srcRef = useMemo(() => srcRefProps.split("_0_"), [srcRefProps]);
  const selectConditionName = useMemo(() => selectConditionNameProps.split("[0]"), [selectConditionNameProps]);
  const fieldConditionName = useMemo(() => fieldConditionNameProps.split("[0]"), [fieldConditionNameProps]);
  const categoryInputName = useMemo(() => categoryInputNameProps.split("[0]"), [categoryInputNameProps]);
  const childChoicesActivatedInputName = useMemo(() => childChoicesActivatedInputNameProps.split("[0]"), [childChoicesActivatedInputNameProps]);
  const linkedCategoryInputName = useMemo(() => linkedCategoryInputNameProps.split("[0]"), [linkedCategoryInputNameProps]);

  const [componentsList, setComponentsList] = useState([]);

  useEffect(() => {
    if (defaultValues && Object.values(defaultValues).length > 0) {
      Object.values(defaultValues).forEach((defaultValue, index) => {
        _addComponent(index, defaultValue);
      });
    } else {
      _addComponent(0);
    }
  }, []);

  const _addComponent = (itemId, defaultValues = {}) => {
    const id = itemId + 1;
    const newItem = {
      itemId: id,
      itemDefaultKey: defaultValues[defaultValues.condition || "default"],
      catalog,
      itemType,
      label,
      choiceSet,
      categoryInputName: _buildName(categoryInputName, categoryInputNameProps, id),
      childChoicesActivatedInputName: _buildName(childChoicesActivatedInputName, childChoicesActivatedInputNameProps, id),
      childChoicesActivatedPlaceholder,
      childChoicesActivatedYesLabel,
      childChoicesActivatedNoLabel,
      linkedCategoryInputName: _buildName(linkedCategoryInputName, linkedCategoryInputNameProps, id),
      locale,
      searchPlaceholder,
      filterPlaceholder,
      srcId: _buildName(srcId, srcIdProps, id, "_"),
      srcRef: _buildName(srcRef, srcRefProps, id, "_"),
      inputName: _buildName(inputName, inputNameProps, id),
      selectConditionName: _buildName(selectConditionName, selectConditionNameProps, id),
      selectCondition,
      multiple,
      fieldConditionName: _buildName(fieldConditionName, fieldConditionNameProps, id),
      fieldConditionData,
      fieldConditionDefault: defaultValues.field_condition,
      childChoicesActivatedDefault: defaultValues["child_choices_activated"] && defaultValues["child_choices_activated"] === "true",
      categoryOptionDefault: defaultValues["category_field"],
      conditionDefault: defaultValues["condition"],
      categoryDefaultValue: defaultValues["category_criteria"],
      addComponent: _addComponent,
      deleteComponent: _deleteComponent,
    };
    setComponentsList((prev) => [...prev, newItem]);
  };

  const _deleteComponent = (itemId) => {
    setComponentsList((prev) => prev.filter((item) => item.itemId !== itemId));
  };

  const _buildName = (split, raw, id, joiner = '[') => {
    if (split.length === 2) {
      return split[0] + joiner + id + (joiner === '[' ? ']' : joiner) + split[1];
    }
    return raw;
  };

  return (
    <div id={srcIdProps + '_container'}>
      {componentsList.map((item) =>
        <div key={item.itemId} className="component-search-row row">
          <ChoiceSetSearch {...item} componentList={componentsList} />
        </div>
      )}
    </div>
  );
};

export default ChoiceSetSearchContainer;
