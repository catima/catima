import React, {useState, useEffect} from 'react';
import ReactSelect from 'react-select';
import LinkedCategoryInput from './LinkedCategoryInput';

const ChoiceSetSearch = (props) => {
  const {
    inputName: inputNameProps,
    srcId,
    srcRef,
    req,
    childChoicesActivatedYesLabel,
    childChoicesActivatedNoLabel,
    locale,
    items,
    addComponent,
    itemId,
    deleteComponent,
    selectConditionName,
    fieldConditionName,
    fieldConditionData,
    searchPlaceholder,
    categoryInputName,
    filterPlaceholder,
    childChoicesActivatedInputName,
    childChoicesActivatedPlaceholder,
    catalog,
    itemType,
    linkedCategoryInputName,
    componentList,
    selectCondition: selectConditionProps
  } = props

  const [selectedCondition, setSelectedCondition] = useState('')
  const [selectCondition, setSelectCondition] = useState([])
  const [selectedFieldCondition, setSelectedFieldCondition] = useState('')
  const [selectedCategory, setSelectedCategory] = useState({})
  const [selectedItem, setSelectedItem] = useState([])
  const [selectedChildChoicesActivated, setSelectedChildChoicesActivated] = useState(false)
  const [disabled, setDisabled] = useState(false)
  const [hiddenInputValue, setHiddenInputValue] = useState([])
  const [inputName, setInputName] = useState(inputNameProps.split("[exact]"))
  const [choiceSetId, setChoiceSetId] = useState(`${srcId}`)
  const [choiceSetRef, setChoiceSetRef] = useState(`${srcRef}`)

  useEffect(() => {
    if (typeof selectConditionProps !== 'undefined' && selectConditionProps.length !== 0) {
      setSelectedCondition(selectConditionProps[0].key)
    }
  }, [selectConditionProps])

  useEffect(() => {
    _save()
  }, [selectedItem])

  function _save() {
    if (selectedItem !== null) {
      setHiddenInputValue(selectedItem);
      document.getElementsByName(_buildInputNameCondition(selectedCondition))[0].value = hiddenInputValue;
    }
  }

  function _buildInputNameCondition(condition) {
    if (inputName.length === 2) {
      if (condition !== '') return inputName[0] + '[' + condition + ']' + inputName[1];
      else return inputName[0] + '[default]' + inputName[1];
    } else {
      return inputNameProps;
    }
  }

  function _selectItem(item, event) {
    if (typeof event === 'undefined' || event.action !== "pop-value" || !req) {
      if (typeof item !== 'undefined') {
        if (item.data.length === 0) {
          setSelectedCategory({});
          setSelectedCondition('');
          setSelectCondition([]);
        }
        setSelectedItem(item)
      } else {
        setSelectedItem([])
      }
    }
  }

  function _selectCondition(event) {
    if (typeof event === 'undefined' || event.action !== "pop-value" || !req) {
      if (typeof event !== 'undefined') {
        setSelectedCondition(event.target.value);
      } else {
        setSelectedCondition('');
      }
    }
  }

  function _selectChildChoicesActivated(event) {
    if (typeof event === 'undefined' || event.action !== "pop-value" || !req) {
      if (typeof event !== 'undefined') {
        setSelectedChildChoicesActivated(event.value);
      } else {
        setSelectedChildChoicesActivated(false);
      }
    }
  }

  function _selectCategory(item, event) {
    if (item !== null) {
      if (typeof event === 'undefined' || event.action !== "pop-value" || !req) {
        if (typeof event !== 'undefined') {
          setSelectedCategory(item);
        } else {
          setSelectedCategory({});
          setSelectedCondition('');
          setSelectCondition([]);
        }
      }
    } else {
      setSelectedCategory({});
      setSelectedCondition('');
      setSelectCondition([]);
    }
  }

  function _selectFieldCondition(event) {
    if (typeof event === 'undefined' || event.action !== "pop-value" || !req) {
      if (typeof event !== 'undefined') {
        setSelectedFieldCondition(event.target.value);
      } else {
        setSelectedFieldCondition('');
      }
    }
  }

  function _getCategoryOptions() {
    let optionsList = [];
    optionsList = selectedItem.data.map(item =>
      _getJSONCategory(item)
    );

    return optionsList;
  }

  function _getChildChoicesActivatedOptions() {
    return [
      {value: true, label: childChoicesActivatedYesLabel},
      {value: false, label: childChoicesActivatedNoLabel}
    ]
  }

  function _getJSONCategory(item) {
    return {
      value: item.uuid,
      label: item.name_translations['name_' + locale],
      key: item.id,
      choiceSetId: item.field_set_id
    };
  }

  function _getItemOptions() {
    let optionsList = [];
    optionsList = items.map(item =>
      _getJSONItem(item)
    );

    return optionsList;
  }

  function _getJSONItem(item) {
    if (typeof item.category_data === 'undefined') {
      item.category_data = [];
    }
    return {value: item.key, label: item.label, data: item.category_data, has_childrens: item.has_childrens};
  }

  function _addComponent() {
    addComponent(itemId);
  }

  function _deleteComponent() {
    deleteComponent(itemId);
  }

  function _updateSelectCondition(newVal) {
    if (selectedCondition === '' && newVal.length !== selectCondition.length) {
      setSelectedCondition(newVal[0].key);
    }
    setSelectCondition(newVal);
  }

  function _getChoiceSetClassname() {
    if (selectedItem.length === 0 || selectedItem.data.length === 0 && !selectedItem.has_childrens) {
      return 'col-lg-6';
    } else {
      return 'col-lg-3';
    }
  }

  function renderSelectConditionElement() {
    return (
      <select className="form-control filter-condition" name={selectConditionName}
              value={selectedCondition} onChange={_selectCondition}
              disabled={selectedItem.length === 0 || Object.keys(selectedCategory).length === 0}>
        {selectCondition.map((item) => {
          return <option key={item.key} value={item.key}>{item.value}</option>
        })}
      </select>
    );
  }

  function renderFieldConditionElement() {
    return (
      <select className="form-control filter-condition" name={fieldConditionName}
              value={selectedFieldCondition} onChange={_selectFieldCondition}>
        {fieldConditionData.map((item) => {
          return <option key={item.key} value={item.key}>{item.value}</option>
        })}
      </select>
    );
  }

  function renderChoiceSetElement() {
    return (
      <div>
        <ReactSelect id={choiceSetId} name={_buildInputNameCondition(selectedCondition)}
                     options={_getItemOptions()} className="basic-multi-select" onChange={_selectItem}
                     classNamePrefix="select" placeholder={searchPlaceholder}/>
      </div>
    );
  }

  function renderChoiceSetItemCategory() {
    return (
      <ReactSelect id={choiceSetId + '_condition'} name={categoryInputName}
                   options={_getCategoryOptions()} className="basic-multi-select" onChange={_selectCategory}
                   classNamePrefix="select" placeholder={filterPlaceholder} isClearable={true}/>
    );
  }

  function renderChildChoicesActivated() {
    return (
      <ReactSelect id={choiceSetId + '_condition'} name={childChoicesActivatedInputName}
                   options={_getChildChoicesActivatedOptions()} onChange={_selectChildChoicesActivated}
                   classNamePrefix="select" placeholder={childChoicesActivatedPlaceholder}/>
    );
  }

  function renderLinkedCategoryElement() {
    return (
      <div>
        <LinkedCategoryInput
          catalog={catalog}
          locale={locale}
          itemType={itemType}
          inputName={linkedCategoryInputName}
          selectedCategory={selectedCategory}
          selectedCondition={selectedCondition}
          updateSelectCondition={_updateSelectCondition}
          searchPlaceholder={searchPlaceholder}
        />
      </div>
    );
  }

  return (
    <div className="col-lg-12 choiceset-search-container">
      <div className="row">
        <div className="col-lg-2">
          {renderFieldConditionElement()}
        </div>
        <div className={_getChoiceSetClassname()}>
          {renderChoiceSetElement()}
        </div>
        {(selectedItem.length !== 0 && selectedItem.has_childrens == true) &&
        <div className="col-lg-3">
          {renderChildChoicesActivated()}
        </div>
        }
        {(selectedItem.length !== 0 && selectedItem.data.length !== 0) &&
        <div className="col-lg-3">
          {renderChoiceSetItemCategory()}
        </div>
        }
        {(itemId === componentList[0].itemId && componentList.length === 1) &&
        <div className="col-lg-1 icon-container">
          <a type="button" onClick={_addComponent}><i className="fa fa-plus"></i></a>
        </div>
        }
        {(((itemId !== componentList[0].itemId) && (itemId !== componentList[componentList.length - 1].itemId)) || (itemId === componentList[0].itemId && componentList.length > 1)) &&
        <div className="col-lg-1 icon-container">
          <a type="button" onClick={_deleteComponent}><i className="fa fa-trash"></i></a>
        </div>
        }
        {((itemId === componentList[componentList.length - 1].itemId) && (itemId !== componentList[0].itemId)) &&
        <div className="col-lg-1">
          <div className="row">
            <div className="col-lg-12"><a type="button" onClick={_addComponent}><i className="fa fa-plus"></i></a>
            </div>
            <div className="col-lg-12"><a type="button" onClick={_deleteComponent}><i className="fa fa-trash"></i></a>
            </div>
          </div>
        </div>
        }
        {!(((selectedItem.length !== 0 && selectedItem.has_childrens == true)) && ((selectedItem.length !== 0 && selectedItem.data.length !== 0))) &&
        <div className="col-lg-3">
          {renderSelectConditionElement()}
        </div>
        }
      </div>
      <div className="row">
        {(((selectedItem.length !== 0 && selectedItem.has_childrens == true)) && ((selectedItem.length !== 0 && selectedItem.data.length !== 0))) &&
        <div className="col-lg-3" style={{marginTop: '10px'}}>
          {renderSelectConditionElement()}
        </div>
        }
        {(Object.keys(selectedCategory).length !== 0 && selectedItem.data.length !== 0) &&
        <div className="col-lg-offset-2 col-lg-6">{renderLinkedCategoryElement()}</div>
        }
      </div>
    </div>
  );
}

export default ChoiceSetSearch;
