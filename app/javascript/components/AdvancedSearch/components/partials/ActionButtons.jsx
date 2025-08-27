import React from 'react';

/**
 * Component for add and delete buttons in advanced search interfaces.
 */
const ActionButtons = ({
  addComponent,
  deleteComponent,
  canAddComponent = false,
  canRemoveComponent = false,
  className = 'col-lg-1'
}) => {
  if (!canAddComponent && !canRemoveComponent) {
    return null;
  }

  return (
    <div className={className}>
      <div className="row">
        {canAddComponent && (
          <div className="col-lg-12">
            <a type="button" onClick={addComponent}>
              <i className="fa fa-plus"></i>
            </a>
          </div>
        )}
        {canRemoveComponent && (
          <div className="col-lg-12">
            <a type="button" onClick={deleteComponent}>
              <i className="fa fa-trash"></i>
            </a>
          </div>
        )}
      </div>
    </div>
  );
};

export default ActionButtons;
