import React, { Component } from 'react';
import ReferenceSearch from './ReferenceSearch';

class ReferenceSearchContainer extends Component {
  constructor(props){
    super(props);

    this.state = {
      componentsList: [],
      inputName: this.props.inputName.split("[0]"),
      referenceFilterName: this.props.referenceFilterName.split("[0]"),
      srcRef: this.props.srcRef.split("_0_"),
      selectConditionName: this.props.selectConditionName.split("[0]"),
      fieldConditionName: this.props.fieldConditionName.split("[0]")
    };

    this.addComponent = this._addComponent.bind(this);
    this.deleteComponent = this._deleteComponent.bind(this);
  }

  componentDidMount(){
    const componentsList = this.state.componentsList;
    var id = 0;
    var item = {
      itemId: id,
      catalog: this.props.catalog,
      parentItemType: this.props.parentItemType,
      itemType: this.props.itemType,
      field: this.props.field,
      locale: this.props.locale,
      inputName: this._buildInputName(id),
      referenceFilterName: this._buildReferenceFilterName(id),
      multiple: this.props.multiple,
      srcRef: this._buildSrcRef(id),
      itemTypeSearch: this.props.itemTypeSearch,
      selectConditionName: this._buildSelectConditionName(id),
      selectCondition: this.props.selectCondition,
      fieldConditionName: this._buildFieldConditionName(id),
      fieldConditionData: this.props.fieldConditionData,
      addComponent: this.addComponent,
      deleteComponent: this.deleteComponent,
    };

    componentsList.push(item);

    this.setState({componentsList: componentsList});
  }

  _addComponent(itemId) {
    const componentsList = this.state.componentsList;

    var id = itemId + 1;
    var item = {
      itemId: id,
      catalog: this.props.catalog,
      parentItemType: this.props.parentItemType,
      itemType: this.props.itemType,
      field: this.props.field,
      locale: this.props.locale,
      inputName: this._buildInputName(id),
      referenceFilterName: this._buildReferenceFilterName(id),
      multiple: this.props.multiple,
      srcRef: this._buildSrcRef(id),
      itemTypeSearch: this.props.itemTypeSearch,
      selectConditionName: this._buildSelectConditionName(id),
      selectCondition: this.props.selectCondition,
      fieldConditionName: this._buildFieldConditionName(id),
      fieldConditionData: this.props.fieldConditionData,
      addComponent: this.addComponent,
      deleteComponent: this.deleteComponent,
    };

    componentsList.push(item);

    this.setState({componentsList: componentsList});
  }

  _deleteComponent(itemId) {
    var componentsList = this.state.componentsList;

    componentsList.forEach((ref, index) => {
      if(Object.keys(ref).length !== 0 && ref.itemId === itemId) {
        componentsList.splice(index, 1);
      }
    });

    this.setState({componentsList: componentsList});
  }

  _buildInputName(id) {
      if(this.state.inputName.length === 2) {
        return this.state.inputName[0] + '[' + id + ']' + this.state.inputName[1];
      } else {
        return this.props.inputName;
      }
  }

  _buildReferenceFilterName(id) {
      if(this.state.referenceFilterName.length === 2) {
        return this.state.referenceFilterName[0] + '[' + id + ']' + this.state.referenceFilterName[1];
      } else {
        return this.props.referenceFilterName;
      }
  }

  _buildSrcRef(id) {
      if(this.state.srcRef.length === 2) {
        return this.state.srcRef[0] + '_' + id + '_' + this.state.srcRef[1];
      } else {
        return this.props.srcRef;
      }
  }

  _buildSelectConditionName(id) {
      if(this.state.selectConditionName.length === 2) {
        return this.state.selectConditionName[0] + '[' + id + ']' + this.state.selectConditionName[1];
      } else {
        return this.props.selectConditionName;
      }
  }

  _buildFieldConditionName(id) {
      if(this.state.fieldConditionName.length === 2) {
        return this.state.fieldConditionName[0] + '[' + id + ']' + this.state.fieldConditionName[1];
      } else {
        return this.props.fieldConditionName;
      }
  }

  renderComponent(item, index, list) {
    if(Object.keys(item).length > 0) {
      return (<div key={item.itemId} className="component-search-row row"><ReferenceSearch
      itemId={item.itemId}
      componentList={list}
      catalog={item.catalog}
      parentItemType={item.parentItemType}
      itemType={item.itemType}
      field={item.field}
      locale={item.locale}
      inputName={item.inputName}
      referenceFilterName={item.referenceFilterName}
      multiple={this.props.multiple}
      srcRef={item.srcRef}
      itemTypeSearch={item.itemTypeSearch}
      selectConditionName={item.selectConditionName}
      selectCondition={item.selectCondition}
      displayFieldCondition={this.props.displayFieldCondition}
      fieldConditionName={item.fieldConditionName}
      fieldConditionData={item.fieldConditionData}
      addComponent={item.addComponent}
      deleteComponent={item.deleteComponent}
      noOptionsMessage={this.props.noOptionsMessage}
      /></div>);
    }
  }

  renderComponentList() {
    const list = this.state.componentsList;
    return this.state.componentsList.map((item, index, list) => this.renderComponent(item, index, list));
  }

  render() {
    return (
      <div>
      {this.renderComponentList()}
      </div>
    );
  }
}

export default ReferenceSearchContainer;
