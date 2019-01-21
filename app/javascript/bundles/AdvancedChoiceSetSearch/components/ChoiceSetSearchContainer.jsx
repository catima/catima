import React, { Component } from 'react';
import ChoiceSetSearch from './ChoiceSetSearch';

class ChoiceSetSearchContainer extends Component {
  constructor(props){
    super(props);

    this.state = {
      componentsList: [],
      inputName: this.props.inputName.split("[0]"),
      srcId: this.props.srcId.split("_0_"),
      srcRef: this.props.srcRef.split("_0_"),
      selectConditionName: this.props.selectConditionName.split("[0]"),
      fieldConditionName: this.props.fieldConditionName.split("[0]"),
      categoryInputName: this.props.categoryInputName.split("[0]"),
      linkedCategoryInputName: this.props.linkedCategoryInputName.split("[0]")
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
      itemType: this.props.itemType,
      label: this.props.label,
      items: this.props.items,
      categoryInputName: this._buildCategoryInputName(id),
      linkedCategoryInputName: this._buildLinkedCategoryInputName(id),
      locale: this.props.locale,
      searchPlaceholder: this.props.searchPlaceholder,
      filterPlaceholder: this.props.filterPlaceholder,
      srcId: this._buildSrcId(id),
      srcRef: this._buildSrcRef(id),
      inputName: this._buildInputName(id),
      selectConditionName: this._buildSelectConditionName(id),
      selectCondition: this.props.selectCondition,
      multiple: this.props.multiple,
      fieldConditionName: this._buildFieldConditionName(id),
      fieldConditionData: this.props.fieldConditionData,
      addComponent: this.addComponent,
      deleteComponent: this.deleteComponent
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
      itemType: this.props.itemType,
      label: this.props.label,
      items: this.props.items,
      categoryInputName: this._buildCategoryInputName(id),
      linkedCategoryInputName: this._buildLinkedCategoryInputName(id),
      locale: this.props.locale,
      searchPlaceholder: this.props.searchPlaceholder,
      filterPlaceholder: this.props.filterPlaceholder,
      srcId: this._buildSrcId(id),
      srcRef: this._buildSrcRef(id),
      inputName: this._buildInputName(id),
      selectConditionName: this._buildSelectConditionName(id),
      selectCondition: this.props.selectCondition,
      multiple: this.props.multiple,
      fieldConditionName: this._buildFieldConditionName(id),
      fieldConditionData: this.props.fieldConditionData,
      addComponent: this.addComponent,
      deleteComponent: this.deleteComponent
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

  _buildSrcRef(id) {
      if(this.state.srcRef.length === 2) {
        return this.state.srcRef[0] + '_' + id + '_' + this.state.srcRef[1];
      } else {
        return this.props.srcRef;
      }
  }

  _buildSrcId(id) {
      if(this.state.srcRef.length === 2) {
        return this.state.srcId[0] + '_' + id + '_' + this.state.srcId[1];
      } else {
        return this.props.srcId;
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

  _buildCategoryInputName(id) {
      if(this.state.categoryInputName.length === 2) {
        return this.state.categoryInputName[0] + '[' + id + ']' + this.state.categoryInputName[1];
      } else {
        return this.props.categoryInputName;
      }
  }

  _buildLinkedCategoryInputName(id) {
      if(this.state.linkedCategoryInputName.length === 2) {
        return this.state.linkedCategoryInputName[0] + '[' + id + ']' + this.state.linkedCategoryInputName[1];
      } else {
        return this.props.linkedCategoryInputName;
      }
  }

  renderComponent(item, index, list) {
    if(Object.keys(item).length > 0) {
      return (<div key={item.itemId} className="component-search-row row"><ChoiceSetSearch
      itemId={item.itemId}
      componentList={list}
      catalog={item.catalog}
      itemType={item.itemType}
      label={item.label}
      items={item.items}
      categoryInputName={item.categoryInputName}
      linkedCategoryInputName={item.linkedCategoryInputName}
      locale={item.locale}
      inputName={item.inputName}
      searchPlaceholder={item.searchPlaceholder}
      filterPlaceholder={item.filterPlaceholder}
      srcId={item.srcId}
      srcRef={item.srcRef}
      selectConditionName={item.selectConditionName}
      selectCondition={item.selectCondition}
      fieldConditionName={item.fieldConditionName}
      fieldConditionData={item.fieldConditionData}
      displayFieldCondition={this.props.displayFieldCondition}
      multiple={item.multiple}
      addComponent={item.addComponent}
      deleteComponent={item.deleteComponent}
      /></div>);
    }
  }

  renderComponentList() {
    const list = this.state.componentsList;
    return this.state.componentsList.map((item, index, list) => this.renderComponent(item, index, list));
  }

  render() {
    return (
      <div id={this.props.srcId + '_container'}>
      {this.renderComponentList()}
      </div>
    );
  }
}

export default ChoiceSetSearchContainer;
