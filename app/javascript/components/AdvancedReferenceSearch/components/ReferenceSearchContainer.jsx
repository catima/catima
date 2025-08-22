import React, {useState, useEffect} from "react";
import ReferenceSearch from './ReferenceSearch';

const ReferenceSearchContainer = (props) => {
  const {
    itemType,
    fieldUuid,
    defaultValues,
    catalog,
    selectCondition,
    fieldConditionData,
    locale,
  } = props;

  const [componentsList, setComponentsList] = useState([])

  useEffect(() => {
    if (defaultValues && Object.values(defaultValues).length > 0) {
      Object.values(defaultValues).forEach((defaultValue, index) => {
        addComponent(index, defaultValue);
      });
    } else {
      addComponent(0);
    }
  }, [])

  const addComponent = (itemId, defaultValues = {}) => {
    const newItem = {
      itemId,
      defaultValues,
      addComponent: () => addComponent(itemId + 1),
      deleteComponent: () => deleteComponent(itemId),
    };
    setComponentsList((prev) => [...prev, newItem]);
  }

  const deleteComponent = (itemId) => {
    setComponentsList((prev) => prev.filter((item) => item.itemId !== itemId));
  }

  return (
    <React.Fragment>
      {componentsList.map((item, index) =>
        <div key={item.itemId} className="component-search-row row">
          <ReferenceSearch
            fieldUuid={fieldUuid}
            itemId={item.itemId}
            defaultValues={item.defaultValues}
            catalog={catalog}
            itemType={itemType}
            locale={locale}
            selectCondition={selectCondition}
            fieldConditionData={fieldConditionData}
            addComponent={item.addComponent}
            deleteComponent={item.deleteComponent}
            canAddComponent={index === componentsList.length - 1}
            canRemoveComponent={componentsList.length > 1}
          />
        </div>
      )}
    </React.Fragment>
  );
}

export default ReferenceSearchContainer;
