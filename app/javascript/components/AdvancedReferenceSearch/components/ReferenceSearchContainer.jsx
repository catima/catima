import React, {useState, useEffect} from "react";
import ReferenceSearch from './ReferenceSearch';

const ReferenceSearchContainer = (props) => {
  const {
    inputName: inputNameProps,
    referenceFilterName: referenceFilterNameProps,
    selectConditionName: selectConditionNameProps,
    fieldConditionName: fieldConditionNameProps,
    catalog,
    parentItemType,
    itemType,
    field,
    locale,
    searchPlaceholder,
    choosePlaceholder,
    filterPlaceholder,
    selectCondition,
    fieldConditionData,
    noOptionsMessage
  } = props

  const [componentsList, setComponentsList] = useState([])
  const [inputName, setInputName] = useState(inputNameProps.split("[0]"))
  const [referenceFilterName, setReferenceFilterName] = useState(referenceFilterNameProps.split("[0]"))
  const [selectConditionName, setSelectConditionName] = useState(selectConditionNameProps.split("[0]"))
  const [fieldConditionName, setFieldConditionName] = useState(fieldConditionNameProps.split("[0]"))

  useEffect(() => {
    let computedComponentsList = componentsList;
    let id = 0;
    let item = {
      itemId: id,
      catalog: catalog,
      parentItemType: parentItemType,
      itemType: itemType,
      field: field,
      locale: locale,
      inputName: _buildInputName(id),
      referenceFilterName: _buildReferenceFilterName(id),
      searchPlaceholder: searchPlaceholder,
      choosePlaceholder: choosePlaceholder,
      filterPlaceholder: filterPlaceholder,
      selectConditionName: _buildSelectConditionName(id),
      selectCondition: selectCondition,
      fieldConditionName: _buildFieldConditionName(id),
      fieldConditionData: fieldConditionData,
      addComponent: _addComponent,
      deleteComponent: _deleteComponent,
    };
    computedComponentsList.push(item);
    setComponentsList([...computedComponentsList]);
  }, [])

  function _addComponent(itemId) {
    let computedComponentsList = componentsList;
    let id = itemId + 1;
    let item = {
      itemId: id,
      catalog: catalog,
      parentItemType: parentItemType,
      itemType: itemType,
      field: field,
      locale: locale,
      inputName: _buildInputName(id),
      referenceFilterName: _buildReferenceFilterName(id),
      searchPlaceholder: searchPlaceholder,
      choosePlaceholder: choosePlaceholder,
      filterPlaceholder: filterPlaceholder,
      selectConditionName: _buildSelectConditionName(id),
      selectCondition: selectCondition,
      fieldConditionName: _buildFieldConditionName(id),
      fieldConditionData: fieldConditionData,
      addComponent: _addComponent,
      deleteComponent: _deleteComponent,
    };
    computedComponentsList.push(item);
    setComponentsList([...computedComponentsList]);
  }

  function _deleteComponent(itemId) {
    let computedComponentsList = componentsList;
    computedComponentsList.forEach((ref, index) => {
      if (Object.keys(ref).length !== 0 && ref.itemId === itemId) {
        computedComponentsList.splice(index, 1);
      }
    });
    setComponentsList([...computedComponentsList]);
  }

  function _buildInputName(id) {
    if (inputName.length === 2) {
      return inputName[0] + '[' + id + ']' + inputName[1];
    } else {
      return inputNameProps;
    }
  }

  function _buildReferenceFilterName(id) {
    if (referenceFilterName.length === 2) {
      return referenceFilterName[0] + '[' + id + ']' + referenceFilterName[1];
    } else {
      return referenceFilterNameProps;
    }
  }

  function _buildSelectConditionName(id) {
    if (selectConditionName.length === 2) {
      return selectConditionName[0] + '[' + id + ']' + selectConditionName[1];
    } else {
      return selectConditionNameProps;
    }
  }

  function _buildFieldConditionName(id) {
    if (fieldConditionName.length === 2) {
      return fieldConditionName[0] + '[' + id + ']' + fieldConditionName[1];
    } else {
      return fieldConditionNameProps;
    }
  }

  function renderComponent(item, index, list) {
    if (Object.keys(item).length > 0) {
      return (<div key={item.itemId} className="component-search-row row"><ReferenceSearch
        itemId={item.itemId}
        componentList={list}
        catalog={item.catalog}
        parentItemType={item.parentItemType}
        itemType={item.itemType}
        field={item.field}
        locale={item.locale}
        inputName={item.inputName}
        referenceFilterName={item.referenceFilterName}
        searchPlaceholder={item.searchPlaceholder}
        choosePlaceholder={item.choosePlaceholder}
        filterPlaceholder={item.filterPlaceholder}
        selectConditionName={item.selectConditionName}
        selectCondition={item.selectCondition}
        fieldConditionName={item.fieldConditionName}
        fieldConditionData={item.fieldConditionData}
        addComponent={item.addComponent}
        deleteComponent={item.deleteComponent}
        noOptionsMessage={noOptionsMessage}
      /></div>);
    }
  }

  function renderComponentList() {
    return componentsList.map((item, index, list) => renderComponent(item, index, list));
  }

  return (
    <React.Fragment>
      {renderComponentList()}
    </React.Fragment>
  );
}

export default ReferenceSearchContainer;
