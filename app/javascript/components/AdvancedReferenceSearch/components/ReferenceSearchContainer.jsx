import React, {useState, useEffect, useRef} from "react";
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

  const [componentsList, setComponentsList] = useState([]);

  let getNextId;
  if (!props.getNextId) {
    const nextIdRef = useRef(0);
    getNextId = () => nextIdRef.current++;
  } else {
    getNextId = props.getNextId;
  }

  useEffect(() => {
    if (defaultValues && Object.values(defaultValues).length > 0) {
      Object.values(defaultValues).forEach((defaultValue) => {
        addComponent(defaultValue);
      });
    } else {
      addComponent();
    }
  }, []);

  const addComponent = (defaultValues = {}) => {
    const newItem = {
      itemId: getNextId(),
      defaultValues,
    };
    setComponentsList((prev) => [...prev, newItem]);
  }

  const deleteComponent = (itemId) => {
    setComponentsList((prev) => prev.filter((item) => item.itemId !== itemId));
  }

  return (
    <React.Fragment>
      {componentsList.map((item, index) => {
        const isLastItem = index === componentsList.length - 1;
        const canRemove = componentsList.length > 1;

        return (
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
              addComponent={() => addComponent()}
              deleteComponent={() => deleteComponent(item.itemId)}
              canAddComponent={isLastItem}
              canRemoveComponent={canRemove}
            />
          </div>
        );
      })}
    </React.Fragment>
  );
}

export default ReferenceSearchContainer;
