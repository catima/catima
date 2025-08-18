import React, {useState, useEffect} from "react";
import ReferenceSearch from './ReferenceSearch';

const ReferenceSearchContainer = (props) => {
  const {
    itemType,
    fieldUuid,
    catalog,
    selectCondition,
    fieldConditionData,
    locale,
    searchPlaceholder,
    choosePlaceholder,
    filterPlaceholder,
    noOptionsMessage,
  } = props

  const [componentsList, setComponentsList] = useState([])

  useEffect(() => {
    addComponent(0);
  }, [])

  function addComponent(itemId) {
    const newItem = {
      fieldUuid,
      itemId,
      catalog: catalog,
      itemType: itemType,
      locale: locale,
      searchPlaceholder: searchPlaceholder,
      choosePlaceholder: choosePlaceholder,
      filterPlaceholder: filterPlaceholder,
      selectCondition: selectCondition,
      fieldConditionData: fieldConditionData,
      noOptionsMessage: () => noOptionsMessage,
      addComponent: () => addComponent(itemId + 1),
      deleteComponent: () => deleteComponent(itemId),
    };
    setComponentsList((prev) => [...prev, newItem]);
  }

  function deleteComponent(itemId) {
    setComponentsList((prev) => prev.filter((item) => item.itemId !== itemId));
  }

  return (
    <React.Fragment>
      {componentsList.map((item, index) =>
        <div key={item.itemId} className="component-search-row row">
          <ReferenceSearch
            {...item}
            canAddComponent={index === componentsList.length - 1}
            canRemoveComponent={componentsList.length > 1}
          />
        </div>
      )}
    </React.Fragment>
  );
}

export default ReferenceSearchContainer;
