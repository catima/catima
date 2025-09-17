import React from 'react';

/**
 * Component for add and delete buttons in advanced search interfaces.
 */
const ActionButtons = ({
  addComponent,
  deleteComponent,
  canAddComponent = false,
  canRemoveComponent = false,
}) => {
  if (!canAddComponent && !canRemoveComponent) {
    return null;
  }

  return (
    <div className="col-lg-1 d-flex flex-column justify-content-center align-items-center">
      {canAddComponent && (
        <a type="button" onClick={addComponent}>
            <i className="fa fa-plus"></i>
        </a>
      )}
      {canRemoveComponent && (
        <a type="button" onClick={deleteComponent}>
            <i className="fa fa-trash"></i>
        </a>
      )}
    </div>
  );
};

export default ActionButtons;
