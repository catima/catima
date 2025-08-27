import React, { useState, useEffect, useRef } from 'react';

// Import all possible child components that can be used (needed when used in ERB views)
import ChoiceSetSearchAdvanced from '../AdvancedChoiceSetSearch/components/ChoiceSetSearch';
import DateTimeSearch from '../AdvancedDateTimeSearch/components/DateTimeSearch';
import ReferenceSearch from '../AdvancedReferenceSearch/components/ReferenceSearch';
import ChoiceSetSearchComplex from '../AdvancedComplexDatationSearch/components/ChoiceSetSearch';

// Component resolver for string paths from ERB views
const componentMap = {
  'AdvancedChoiceSetSearch/components/ChoiceSetSearch': ChoiceSetSearchAdvanced,
  'AdvancedDateTimeSearch/components/DateTimeSearch': DateTimeSearch,
  'AdvancedReferenceSearch/components/ReferenceSearch': ReferenceSearch,
  'AdvancedComplexDatationSearch/components/ChoiceSetSearch': ChoiceSetSearchComplex,
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

const AdvancedContainerSearch = (props) => {
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
          <div key={item.itemId} className="component-search-row row">
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

export default AdvancedContainerSearch;
