import React, { Component } from 'react';
import ReactDOM from 'react-dom';
import { TreeSelect } from 'antd';

const TreeNode = TreeSelect.TreeNode;

class ChoiceSynonymEditor extends Component {
  constructor(props){
    super(props);

    this.state = {
      choices: [],
      synonym: {},
      selectedItem: null
    };

    this.selectItem = this._selectItem.bind(this);
    this.deleteComponent = this._deleteComponent.bind(this);
  }

  componentDidMount(){
      this.setState({ choices: this.props.choices });
      this.setState({ synonym: this.props.synonym });
      this._selectItem(this.props.selectDefaultValue);
  }

  _selectItem(item){
    console.log(item);
      if(typeof item === 'undefined') {
          item = null;
      }
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

  _buildInputName(lang) {
      var selectedItemKey = "";
      if(this.state.selectedItem !== null && this.state.selectedItem) selectedItemKey = this.state.selectedItem.value;
      var inputName = "choice_synonyms[" + selectedItemKey + "][" + this.props.position + "][" + lang + "]"
      return inputName;
  }

  _updateSynonym(event, key) {
      if(event.target) {
          var currentSynonym = this.state.synonym;
          currentSynonym.synonym[key] = event.target.value;

          this.setState({synonym: currentSynonym});
      }

  }

  _deleteComponent() {
      this.props.deleteComponent(this.props.position);
  }

  renderChoiceSetSelectElement(){
    return (
        <div id={"synonym_select_" + this.props.position + "_container"} className="select-container">
            <TreeSelect
              value={this.state.selectedItem}
              placeholder={this.props.selectPlaceholder}
              showSearch
              allowClear
              labelInValue
              treeDefaultExpandAll
              treeNodeFilterProp="title"
              multiple={false}
              onChange={this.selectItem}>
                { this.state.choices.map((item) => {
                  return this._getTreeChildrens(item);
                })}
            </TreeSelect>
        </div>
    );
  }

  renderSynonymComponent(key) {
      return(
      <div className="input-group">
        <span className="input-group-addon">{key}</span>
        <input className="form-control" name={this._buildInputName(key)} disabled={this.state.selectedItem === null} data-locale={key} type="text" value={this.state.synonym.synonym[key]} onChange={(e) => this._updateSynonym(e, key)}/>
      </div>
      );
  }

  render() {
    return (
      <div className="synonym-container">
        <div className="row">
            <div className="col-md-12">{ this.renderChoiceSetSelectElement() }</div>
        </div>
        <div className="row">
            <div className="col-md-11">
                <div className="row">
                    { this.state.synonym.synonym && Object.keys(this.state.synonym.synonym).map((key) => {
                        return (
                            <div key={key} className="col-md-6">
                                { this.renderSynonymComponent(key, this.state.synonym.choice_id) }
                            </div>
                        );
                      })
                    }
                </div>
            </div>
            <div className="col-md-1 icon-container">
                <a type="button" onClick={this.deleteComponent} className="btn"><i className="fa fa-trash"></i></a>
            </div>
        </div>
      </div>
    );
  }

}

export default ChoiceSynonymEditor;
