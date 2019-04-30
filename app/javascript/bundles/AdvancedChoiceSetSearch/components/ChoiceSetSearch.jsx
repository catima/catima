import React, { Component } from 'react';
import ReactDOM from 'react-dom';
import ReactSelect from 'react-select';
import striptags from 'striptags';
import { TreeSelect } from 'antd';
import LinkedCategoryInput from './LinkedCategoryInput';

const TreeNode = TreeSelect.TreeNode;

class ChoiceSetSearch extends Component {
    constructor(props){
        super(props);

        this.state = {
            selectedCondition: '',
            selectCondition: [],
            selectedFieldCondition: '',
            selectedCategory: {},
            selectedItem: [],
            disabled: false,
            hiddenInputValue: '',
            inputName: this.props.inputName.split("[default]")
        };

        this.choiceSetId = `${this.props.srcId}`;
        this.choiceSetRef = `${this.props.srcRef}`;
        this.selectItem = this._selectItem.bind(this);
        this.selectCondition = this._selectCondition.bind(this);
        this.selectFieldCondition = this._selectFieldCondition.bind(this);
        this.selectCategory = this._selectCategory.bind(this);
        this.addComponent = this._addComponent.bind(this);
        this.deleteComponent = this._deleteComponent.bind(this);
        this.updateSelectCondition = this._updateSelectCondition.bind(this);
    }

    componentDidMount(){
        if(typeof this.props.selectCondition !== 'undefined' && this.props.selectCondition.length !== 0) {
            this.setState({selectedCondition: 'default'});
        }
    }

    _save(){
        if(this.state.selectedItem !== null) {
            this.setState({ hiddenInputValue: this.state.selectedItem.value });
            document.getElementsByName(this._buildInputNameCondition(this.state.selectedCondition))[0].value = this.state.hiddenInputValue;
        }
    }

    _buildInputNameCondition(condition) {
        if(this.state.inputName.length === 2) {
            if(condition !== '') return this.state.inputName[0] + '[' + condition + ']' + this.state.inputName[1];
            else return this.state.inputName[0] + '[default]' + this.state.inputName[1];
        } else {
            return this.props.inputName;
        }
    }

    _selectItem(item){
        if(typeof item !== 'undefined') {
            var itemData = this._getItemData(this.props.items, item);
            if(typeof itemData !== 'undefined') {
                item.data = itemData;

                if(this.state.selectedCondition === 'default') {
                    //The user has clicked on a item that has a category, we should initialize the condition
                    this.setState({selectedCondition: this.props.selectCondition[0].key});
                }
            } else {
                item.data = [];
            }
        } else {
            item = [];
        }

        this.setState({ hiddenInputValue: item.value });
        this.setState({ selectedItem: item });
    }

    _getItemData(list, searchItem) {
        for(var i = 0; i < list.length; i++) {
            var result = this._findByProps(list[i], searchItem.label, searchItem.value);
            if(result){
                //Found the parent item
                return result.category_data;
            } else {
                //Search in the childrens
                var childrenResult = this._findByProps(list[i].children, searchItem.label, searchItem.value);
                if(childrenResult){
                    //Found the parent item
                    return childrenResult.category_data;
                }
            }
        }

        return null;
    }

    _findByProps(o, label, value) {
        //Early return
        if(typeof o !== 'undefined' && o !== null) {
            if( o.value === label && o.key === value){
                return o;
            }
            var result, p;
            for (p in o) {
                if( o.hasOwnProperty(p) && typeof o[p] === 'object' ) {
                    result = this._findByProps(o[p], label, value);
                    if(result){
                        //Found !
                        return result;
                    }
                }
            }
        }
        return null;
    }


    _selectCondition(event){
        if(typeof event === 'undefined' || event.action !== "pop-value" || !this.props.req) {
            if(typeof event !== 'undefined') {
                this.setState({ selectedCondition: event.target.value });
            } else {
                this.setState({ selectedCondition: '' });
            }
        }
    }

    _selectCategory(item, event){
        if(item !== null) {
            if(typeof event === 'undefined' || event.action !== "pop-value" || !this.props.req) {
                if(typeof event !== 'undefined') {
                    this.setState({ selectedCategory: item });
                } else {
                    this.setState({ selectedCategory: {} });
                    this.setState({ selectedCondition: '' });
                    this.setState({ selectCondition: [] });
                }
            }
        } else {
            this.setState({ selectedCategory: {} });
            this.setState({ selectedCondition: '' });
            this.setState({ selectCondition: [] });
        }
    }

    _selectFieldCondition(event){
        if(typeof event === 'undefined' || event.action !== "pop-value" || !this.props.req) {
            if(typeof event !== 'undefined') {
                this.setState({ selectedFieldCondition: event.target.value });
            } else {
                this.setState({ selectedFieldCondition: '' });
            }
        }
    }

    _getCategoryOptions(){
        var optionsList = [];
        optionsList = this.state.selectedItem.data.map(item =>
            this._getJSONCategory(item)
        );

        return optionsList;
    }

    _getJSONCategory(item) {
        return {value: item.slug, label: item.name_translations['name_' + this.props.locale], key: item.id, choiceSetId: item.field_set_id};
    }

    _addComponent() {
        this.props.addComponent(this.props.itemId);
    }

    _deleteComponent() {
        this.props.deleteComponent(this.props.itemId);
    }

    _updateSelectCondition(newVal) {
        if(this.state.selectedCondition === '' && newVal.length !== this.state.selectCondition.length) {
            this.setState({selectedCondition: newVal[0].key});
        }
        this.setState({ selectCondition: newVal });
    }

    _getChoiceSetClassname() {
        if(this.state.selectedItem.length === 0 || (typeof this.state.selectedItem.data !== 'undefined' && this.state.selectedItem.data.length === 0)) {
            return 'col-md-6';
        } else {
            return 'col-md-3';
        }
    }

    _getTreeChildrens(item, index, parentKey) {
        if(typeof item.children !== 'undefined' && item.children.length>0) {
            //The item is a node and has children
            var key = parentKey + '_' + 'child' + index;
            return (
                <TreeNode value={item.key} title={item.value} key={key}>
                { item.children.map((childItem, index) => {
                    return this._getTreeChildrens(childItem, index, key);
                })}
                </TreeNode>
            );
        } else {
            //The item is not node and has no children
            var key = parentKey + '_' + 'root' + index;
            return <TreeNode value={item.key} title={item.value} key={key} />;
        }
    }

    renderSelectConditionElement(){
        return (
            <select className="form-control filter-condition" name={this.props.selectConditionName} value={this.state.selectedCondition} onChange={this.selectCondition} disabled={this.state.selectedItem.length===0 || Object.keys(this.state.selectedCategory).length === 0}>
            { this.state.selectCondition.map((item) => {
                return <option key={item.key} value={item.key}>{item.value}</option>
            })}
            </select>
        );
    }

    renderFieldConditionElement(){
        return (
            <select className="form-control filter-condition" name={this.props.fieldConditionName} value={this.state.selectedFieldCondition} onChange={this.selectFieldCondition}>
            { this.props.fieldConditionData.map((item) => {
                return <option key={item.key} value={item.key}>{item.value}</option>
            })}
            </select>
        );
    }

    renderChoiceSetElement(){
        return (
            <div>
              <input id={this.choiceSetId} type="hidden" readOnly value={this.state.hiddenInputValue} name={this._buildInputNameCondition(this.state.selectedCondition)}/>
              <TreeSelect
              value={this.state.selectedItem}
              placeholder={this.props.searchPlaceholder}
              showSearch
              allowClear
              labelInValue
              treeDefaultExpandAll
              treeNodeFilterProp="title"
              onChange={this.selectItem}>
              { this.props.items.map((item, index) => {
                  return this._getTreeChildrens(item, index, 'root' + index);
              })}
              </TreeSelect>
            </div>
        );
    }

    renderChoiceSetItemCategory(){
        return (
            <ReactSelect id={this.choiceSetId + '_condition'} name={this.props.categoryInputName} options={this._getCategoryOptions()} className="basic-multi-select" onChange={this.selectCategory} classNamePrefix="select" placeholder={this.props.filterPlaceholder} isClearable={true}/>
        );
    }

    renderLinkedCategoryElement(){
        return (
            <div>
            <LinkedCategoryInput
            catalog={this.props.catalog}
            locale={this.props.locale}
            itemType={this.props.itemType}
            inputName={this.props.linkedCategoryInputName}
            selectedCategory={this.state.selectedCategory}
            selectedCondition={this.state.selectedCondition}
            updateSelectCondition={this.updateSelectCondition}
            />
            </div>
        );
    }

    render() {
        return (
            <div className="col-md-12 choiceset-search-container">
            <div className="row component-search-row">
            <div className="col-md-2">
            { this.props.displayFieldCondition && this.renderFieldConditionElement() }
            </div>
            <div>
            <div className={this._getChoiceSetClassname()}>
            { this.renderChoiceSetElement() }
            </div>
            { (this.state.selectedItem.length !== 0 && this.state.selectedItem.data.length !== 0) &&
                <div className="col-md-3">
                { this.renderChoiceSetItemCategory() }
                </div>
            }
            </div>
            { (this.props.itemId === this.props.componentList[0].itemId && this.props.componentList.length === 1) &&
                <div className="col-md-1 icon-container">
                <a type="button" onClick={this.addComponent}><i className="fa fa-plus"></i></a>
                </div>
            }
            { (((this.props.itemId !== this.props.componentList[0].itemId) && (this.props.itemId !== this.props.componentList[this.props.componentList.length - 1].itemId)) || (this.props.itemId === this.props.componentList[0].itemId && this.props.componentList.length > 1)) &&
                <div className="col-md-1 icon-container">
                <a type="button" onClick={this.deleteComponent}><i className="fa fa-trash"></i></a>
                </div>
            }
            { ((this.props.itemId === this.props.componentList[this.props.componentList.length - 1].itemId) && (this.props.itemId !== this.props.componentList[0].itemId)) &&
                <div className="col-md-1">
                <div className="row">
                <div className="col-md-12"><a type="button" onClick={this.addComponent}><i className="fa fa-plus"></i></a></div>
                <div className="col-md-12"><a type="button" onClick={this.deleteComponent}><i className="fa fa-trash"></i></a></div>
                </div>
                </div>
            }
            <div className="col-md-3">
            { this.renderSelectConditionElement() }
            </div>
            </div>
            { (Object.keys(this.state.selectedCategory).length !== 0 && this.state.selectedItem.data.length !== 0) &&
                <div className="row component-search-row">
                <div className="col-md-offset-2 col-md-6">{ this.renderLinkedCategoryElement() }</div>
                </div>
            }
            </div>
        );
    }

}

export default ChoiceSetSearch;
