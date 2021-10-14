import React, {useState, useEffect} from 'react';
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
    items,
    childChoicesActivatedPlaceholder,
    childChoicesActivatedYesLabel,
    childChoicesActivatedNoLabel,
    locale,
    searchPlaceholder,
    filterPlaceholder,
    selectCondition,
    multiple,
    fieldConditionData
  } = props

  const [componentsList, setComponentsList] = useState([])
  const [inputName, setInputName] = useState(inputNameProps.split("[0]"))
  const [srcId, setSrcId] = useState(srcIdProps.split("_0_"))
  const [srcRef, setSrcRef] = useState(srcRefProps.split("_0_"))
  const [selectConditionName, setSelectConditionName] = useState(selectConditionNameProps.split("[0]"))
  const [fieldConditionName, setFieldConditionName] = useState(fieldConditionNameProps.split("[0]"))
  const [categoryInputName, setCategoryInputName] = useState(categoryInputNameProps.split("[0]"))
  const [childChoicesActivatedInputName, setChildChoicesActivatedInputName] = useState(childChoicesActivatedInputNameProps.split("[0]"))
  const [linkedCategoryInputName, setLinkedCategoryInputName] = useState(linkedCategoryInputNameProps.split("[0]"))

  useEffect(() => {
    let computedComponentList = componentsList;
    let id = 0;
    let item = {
      itemId: id,
      catalog: catalog,
      itemType: itemType,
      label: label,
      items: items,
      categoryInputName: _buildCategoryInputName(id),
      childChoicesActivatedInputName: _buildChildChoicesActivatedInputName(id),
      childChoicesActivatedPlaceholder: childChoicesActivatedPlaceholder,
      childChoicesActivatedYesLabel: childChoicesActivatedYesLabel,
      childChoicesActivatedNoLabel: childChoicesActivatedNoLabel,
      linkedCategoryInputName: _buildLinkedCategoryInputName(id),
      locale: locale,
      searchPlaceholder: searchPlaceholder,
      filterPlaceholder: filterPlaceholder,
      srcId: _buildSrcId(id),
      srcRef: _buildSrcRef(id),
      inputName: _buildInputName(id),
      selectConditionName: _buildSelectConditionName(id),
      selectCondition: selectCondition,
      multiple: multiple,
      fieldConditionName: _buildFieldConditionName(id),
      fieldConditionData: fieldConditionData,
      addComponent: _addComponent,
      deleteComponent: _deleteComponent
    };
    computedComponentList.push(item);
    setComponentsList([...computedComponentList]);
  }, [])

  function _addComponent(itemId) {
    let computedComponentList = componentsList;
    let id = itemId + 1;
    let item = {
      itemId: id,
      catalog: catalog,
      itemType: itemType,
      label: label,
      items: items,
      categoryInputName: _buildCategoryInputName(id),
      childChoicesActivatedInputName: _buildChildChoicesActivatedInputName(id),
      childChoicesActivatedPlaceholder: childChoicesActivatedPlaceholder,
      childChoicesActivatedYesLabel: childChoicesActivatedYesLabel,
      childChoicesActivatedNoLabel: childChoicesActivatedNoLabel,
      linkedCategoryInputName: _buildLinkedCategoryInputName(id),
      locale: locale,
      searchPlaceholder: searchPlaceholder,
      filterPlaceholder: filterPlaceholder,
      srcId: _buildSrcId(id),
      srcRef: _buildSrcRef(id),
      inputName: _buildInputName(id),
      selectConditionName: _buildSelectConditionName(id),
      selectCondition: selectCondition,
      multiple: multiple,
      fieldConditionName: _buildFieldConditionName(id),
      fieldConditionData: fieldConditionData,
      addComponent: _addComponent,
      deleteComponent: _deleteComponent
    };
    computedComponentList.push(item);
    setComponentsList([...computedComponentList]);
  }

  function _deleteComponent(itemId) {
    let computedComponentList = componentsList;
    computedComponentList.forEach((ref, index) => {
      if (Object.keys(ref).length !== 0 && ref.itemId === itemId) {
        computedComponentList.splice(index, 1);
      }
    });
    setComponentsList([...computedComponentList]);
  }

  function _buildInputName(id) {
    if (inputName.length === 2) {
      return inputName[0] + '[' + id + ']' + inputName[1];
    } else {
      return inputNameProps;
    }
  }

  function _buildSrcRef(id) {
    if (srcRef.length === 2) {
      return srcRef[0] + '_' + id + '_' + srcRef[1];
    } else {
      return srcRefProps;
    }
  }

  function _buildSrcId(id) {
    if (srcRef.length === 2) {
      return srcId[0] + '_' + id + '_' + srcId[1];
    } else {
      return srcIdProps;
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

  function _buildCategoryInputName(id) {
    if (categoryInputName.length === 2) {
      return categoryInputName[0] + '[' + id + ']' + categoryInputName[1];
    } else {
      return categoryInputNameProps;
    }
  }

  function _buildChildChoicesActivatedInputName(id) {
    if (childChoicesActivatedInputName.length === 2) {
      return childChoicesActivatedInputName[0] + '[' + id + ']' + childChoicesActivatedInputName[1];
    } else {
      return childChoicesActivatedInputNameProps;
    }
  }

  function _buildLinkedCategoryInputName(id) {
    if (linkedCategoryInputName.length === 2) {
      return linkedCategoryInputName[0] + '[' + id + ']' + linkedCategoryInputName[1];
    } else {
      return linkedCategoryInputNameProps;
    }
  }

  function renderComponent(item, index, list) {
    if (Object.keys(item).length > 0) {
      return (<div key={item.itemId} className="component-search-row row"><ChoiceSetSearch
        itemId={item.itemId}
        componentList={list}
        catalog={item.catalog}
        itemType={item.itemType}
        label={item.label}
        items={item.items}
        categoryInputName={item.categoryInputName}
        childChoicesActivatedInputName={item.childChoicesActivatedInputName}
        childChoicesActivatedPlaceholder={item.childChoicesActivatedPlaceholder}
        childChoicesActivatedYesLabel={item.childChoicesActivatedYesLabel}
        childChoicesActivatedNoLabel={item.childChoicesActivatedNoLabel}
        linkedCategoryInputName={item.linkedCategoryInputName}
        locale={item.locale}
        inputName={item.inputName}
        searchPlaceholder={item.searchPlaceholder}
        filterPlaceholder={item.filterPlaceholder}
        srcId={item.srcId}
        srcRef={item.srcRef}
        selectConditionName={item.selectConditionName}
        selectCondition={item.selectCondition}
        fieldConditionName={item.fieldConditionName}
        fieldConditionData={item.fieldConditionData}
        multiple={item.multiple}
        addComponent={item.addComponent}
        deleteComponent={item.deleteComponent}
      /></div>);
    }
  }

  function renderComponentList() {
    return componentsList.map((item, index, list) => renderComponent(item, index, list));
  }

  return (
    <div id={srcIdProps + '_container'}>
      {renderComponentList()}
    </div>
  );
}

export default ChoiceSetSearchContainer;
