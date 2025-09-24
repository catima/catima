import React, { useEffect, useState, useRef } from 'react';
import ChoiceSet from './ChoiceSet';
import DateTime from './DateTime';
import Reference from './Reference';
import ChoiceSetSearchComplex from './partials/ComplexDatationChoiceSet';

// Component resolver for string paths from ERB views
const componentMap = {
  'AdvancedSearch/components/ChoiceSet': ChoiceSet,
  'AdvancedSearch/components/DateTime': DateTime,
  'AdvancedSearch/components/Reference': Reference,
  'AdvancedSearch/components/ComplexDatationChoiceSet': ChoiceSetSearchComplex,
};

const resolveComponent = (childComponent) => {
  if (typeof childComponent === 'function') {
    // Direct React component passed
    return childComponent;
  }

  if (typeof childComponent === 'string') {
    // String path from ERB view
    const Component = componentMap[childComponent];
    if (!Component) {
      throw new Error(`Component not found for path: ${childComponent}`);
    }
    return Component;
  }

  return childComponent;
};

const Container = (props) => {
  const {
    fieldUuid,
    defaultValues,
    childComponent,
    childProps,
    getNextId: externalGetNextId,
  } = props;

  const [componentsList, setComponentsList] = useState([]);
  const ChildComponent = resolveComponent(childComponent);

  let getNextId;
  if (!externalGetNextId) {
    const nextIdRef = useRef(0);
    getNextId = () => nextIdRef.current++;
  } else {
    getNextId = externalGetNextId;
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
  };

  const deleteComponent = (itemId) => {
    setComponentsList((prev) => prev.filter((item) => item.itemId !== itemId));
  };

  return (
    <div>
      {componentsList.map((item, index) => {
        const isLastItem = index === componentsList.length - 1;
        const canRemove = componentsList.length > 1;

        return (
          <div key={item.itemId} className="row mb-2" data-field-uuid={fieldUuid}>
            <ChildComponent
              fieldUuid={fieldUuid}
              itemId={item.itemId}
              defaultValues={item.defaultValues}
              addComponent={() => addComponent()}
              deleteComponent={() => deleteComponent(item.itemId)}
              canAddComponent={isLastItem}
              canRemoveComponent={canRemove}
              {...childProps}
            />
          </div>
        );
      })}
    </div>
  );
};

export default Container;
