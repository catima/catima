import React, { Component } from 'react';
import ReactDOM from 'react-dom';
import { TreeSelect } from 'antd';

const TreeNode = TreeSelect.TreeNode;

class ChoiceSetEditor extends Component {
  constructor(props){
    super(props);

    this.state = {
      selectedCategory: {},
      selectedItems: [],
      disabled: false,
      hiddenInputValue: [],
      defaultValues: [],
      inputName: this.props.inputName
    };

    this.selectItem = this._selectItem.bind(this);
  }

  componentDidMount(){
      this.setState({ selectedItems: this.props.inputDefaults });
      this._selectItem(this.props.inputDefaults);
  }

  _selectItem(items){
      if(typeof items !== 'undefined') {
          var itemData = this._getItemData(this.props.items, items);
          if(typeof itemData !== 'undefined') {
              items.data = itemData;
          } else {
              items.data = [];
          }
      } else {
          items = [];
      }

      console.log(items)

          if(this.props.multiple) {
              this.setState({ hiddenInputValue: [
                JSON.stringify(
                  items.map((selectedItem) => {
                    return selectedItem.value.toString();
                  })
                )
              ]
              });
          } else {
              if(items.value) {
                  this.setState({ hiddenInputValue: [
                      items.value.toString()
                  ]});
              }
          }

      this.setState({ selectedItems: items });
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

  _getTreeChildrens(item) {
    if(typeof item.children !== 'undefined' && item.children.length>0) {
        return (
            <TreeNode value={item.key} title={item.value} key={item.key}>
                { item.children.map((childItem) => {
                  return this._getTreeChildrens(childItem);
                })}
            </TreeNode>
        );
    } else {
        return <TreeNode value={item.key} title={item.value} key={item.key} />;
    }
  }

  renderChoiceSetElement(){
    return (
        <div id={this.props.srcId + "_container"}>
            <input id={this.choiceSetId} type="hidden" readOnly value={this.state.hiddenInputValue} name={this.props.inputName}/>
            <TreeSelect
              value={this.state.selectedItems}
              placeholder={this.props.searchPlaceholder}
              showSearch
              allowClear
              labelInValue
              treeDefaultExpandAll
              treeNodeFilterProp="title"
              multiple={this.props.multiple}
              defaultValue={this.state.defaultValues}
              onChange={this.selectItem}>
                { this.props.items.map((item) => {
                  return this._getTreeChildrens(item);
                })}
            </TreeSelect>
        </div>
    );
  }

  render() {
    return (
      <div className="choiceset-editor-container">
            { this.renderChoiceSetElement() }
      </div>
    );
  }

}

export default ChoiceSetEditor;
