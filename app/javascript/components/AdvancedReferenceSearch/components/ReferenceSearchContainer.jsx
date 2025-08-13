import React, {useState, useEffect} from "react";
import ReferenceSearch from './ReferenceSearch';

const ReferenceSearchContainer = (props) => {
  const {
    fieldUuid,
    catalog,
    itemType,
    locale,
    searchPlaceholder,
    choosePlaceholder,
    filterPlaceholder,
    selectCondition,
    fieldConditionData,
    noOptionsMessage
  } = props

  const [componentsList, setComponentsList] = useState([])

  useEffect(() => {
    let computedComponentsList = componentsList;
    let id = 0;
    let item = {
      fieldUuid,
      itemId: id,
      catalog: catalog,
      itemType: itemType,
      locale: locale,
      searchPlaceholder: searchPlaceholder,
      choosePlaceholder: choosePlaceholder,
      filterPlaceholder: filterPlaceholder,
      selectCondition: selectCondition,
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
      fieldUuid,
      itemId: id,
      catalog: catalog,
      itemType: itemType,
      locale: locale,
      searchPlaceholder: searchPlaceholder,
      choosePlaceholder: choosePlaceholder,
      filterPlaceholder: filterPlaceholder,
      selectCondition: selectCondition,
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

  function renderComponent(item, index, list) {
    if (Object.keys(item).length > 0) {
      return (<div key={item.itemId} className="component-search-row row"><ReferenceSearch
        fieldUuid={fieldUuid}
        itemId={item.itemId}
        componentList={list}
        catalog={item.catalog}
        itemType={item.itemType}
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
