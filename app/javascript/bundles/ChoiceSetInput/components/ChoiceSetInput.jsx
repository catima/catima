import React, { Component } from 'react';
import ReactDOM from 'react-dom';
import Nestable from 'react-nestable';
import striptags from 'striptags';

// Used to create choices within a choiceset
class ChoiceSetInput extends Component {
  constructor(props){
    super(props);

    this.state = {
      componentsList: []
    };

    this.nextUniqueId = 0;
    this.renderItem = this.renderItem.bind(this);
    this.addComponent = this._addComponent.bind(this);
    this.updateComponentTree = this._updateComponentTree.bind(this);
    this.updateShortNameTranslations = this._updateShortNameTranslations.bind(this);
    this.updateLongNameTranslations = this._updateLongNameTranslations.bind(this);
    this.updateSelectedCategory = this._updateSelectedCategory.bind(this);
  }

  componentDidMount(){
      this._initComponentList();
  }

  _initComponentList() {
      var componentsList = [];

      if(this.props.data.choices.length === 0) {
          //We are creating a new choice set
          this.nextUniqueId = 0;

          var component = {
              id: this.nextUniqueId,
              uuid: '',
              hidden_input_name: this._buildHiddenInputName({}, this.state.componentsList.length, false),
              long_input_name: this._buildLongInputName({}, this.state.componentsList.length, false),
              long_input_id: this._buildLongSrcId({}, this.state.componentsList.length, false),
              long_name_translations: {},
              short_input_name: this._buildShortInputName({}, this.state.componentsList.length, false),
              short_input_id: this._buildShortSrcId({}, this.state.componentsList.length, false),
              short_name_translations: {},
              category_input_name: this._buildCategoryInputName({}, this.state.componentsList.length, false),
              category_input_id: this._buildCategorySrcId({}, this.state.componentsList.length, false),
              category_id: '',
              category_options: [],
              children: []
          };

          this.props.available_locales.forEach((lang) => {
             component.long_name_translations['long_name_' + lang] = '';
             component.short_name_translations['short_name_' + lang] = '';
          });

          componentsList.push(component);

          this.nextUniqueId = component.id + 1;
      } else {
          //We are editing an existing choice set
          var counter = 0;
          for(var i=0; i<this.props.data.choices.length; i++) {
              var currentData = this.props.data.choices[i];

              var newComponent = currentData;

              newComponent.id = counter;
              newComponent.hidden_input_name = this._buildHiddenInputName({}, counter, false);
              newComponent.long_input_name = this._buildLongInputName({}, counter, false);
              newComponent.long_input_id = this._buildLongSrcId({}, counter, false);
              newComponent.short_input_name = this._buildShortInputName({}, counter, false);
              newComponent.short_input_id = this._buildShortSrcId({}, counter, false);
              newComponent.category_input_name = this._buildCategoryInputName({}, counter, false);
              newComponent.category_input_id = this._buildCategorySrcId({}, counter, false);

              if(typeof this.props.category_options !== 'undefined') newComponent.category_options = this.props.category_options;
              else newComponent.category_options = [];


              if(newComponent.category_id === null || typeof newComponent.category_id === 'undefined') {
                  newComponent.category_id = '';
              }

              counter++;

              if(typeof currentData.children !== 'undefined' && currentData.children.length > 0) {
                  var returnEl = this._initChildren(newComponent, newComponent.children, counter);
                  newComponent.children = returnEl.list;
                  counter = returnEl.counter;
              }

              componentsList.push(newComponent);
          }

          this.nextUniqueId = counter;
      }

      this.setState({componentsList: componentsList});
  }

  _initChildren(parentComponent, childrenData, counter) {
      var childrenList = [];
      for(var i=0; i<childrenData.length; i++) {

          var currentData = childrenData[i];
          var newComponent = currentData;

          newComponent.id = counter;
          newComponent.hidden_input_name = this._buildHiddenInputName(parentComponent, counter, true);
          newComponent.long_input_name = this._buildLongInputName(parentComponent, counter, true);
          newComponent.long_input_id = this._buildLongSrcId(parentComponent, counter, true);
          newComponent.short_input_name = this._buildShortInputName(parentComponent, counter, true);
          newComponent.short_input_id = this._buildShortSrcId(parentComponent, counter, true);
          newComponent.category_input_name = this._buildCategoryInputName(parentComponent, counter, true);
          newComponent.category_input_id = this._buildCategorySrcId(parentComponent, counter, true);
          if(typeof this.props.category_options !== 'undefined') newComponent.category_options = this.props.category_options;
          else newComponent.category_options = [];

          if(newComponent.category_id === null || typeof newComponent.category_id === 'undefined') {
              newComponent.category_id = '';
          }

          counter++;

          if(typeof currentData.children !== 'undefined' && currentData.children.length > 0) {
              var returnEl = this._initChildren(newComponent, currentData.children, counter);
              newComponent.children = returnEl.list;
              counter = returnEl.counter;
          }

          childrenList.push(newComponent);
      }

      return {list: childrenList, counter: counter};
  }

  _updateLongNameTranslations(event) {
      var searchName = event.target.name.split('[long_name');
      var locale = searchName[1].split(']')[0];
      var result = this._findByName(this.state.componentsList, searchName[0], 'long_input_name');
      if(result !== null) {
          var replaceList = this._replaceTranslationValueInTree(this.state.componentsList, result, 'long_name_translations', 'long_name' + locale, event.target.value);
          this.setState({componentsList: replaceList});
      }
  }

  _updateShortNameTranslations(event) {
      var searchName = event.target.name.split('[short_name');
      var locale = searchName[1].split(']')[0];
      var result = this._findByName(this.state.componentsList, searchName[0], 'short_input_name');
      if(result !== null) {
          var replaceList = this._replaceTranslationValueInTree(this.state.componentsList, result, 'short_name_translations', 'short_name' + locale, event.target.value);
          this.setState({componentsList: replaceList});
      }
  }

  _updateSelectedCategory({ target }) {
      var searchName = target.name.split('[category_id]');
      var result = this._findByName(this.state.componentsList, target.name, 'category_input_name');
      if(result !== null) {
          var replaceList = this._replaceCategoryValueInTree(this.state.componentsList, result, 'category_id', target.value);
          this.setState({componentsList: replaceList});
      }
  }

  _addComponent() {
      var component = {
          id: this.nextUniqueId,
          uuid: '',
          hidden_input_name: this._buildHiddenInputName({}, this.state.componentsList.length, false),
          long_input_name: this._buildLongInputName({}, this.state.componentsList.length, false),
          long_input_id: this._buildLongSrcId({}, this.state.componentsList.length, false),
          long_name_translations: {},
          short_input_name: this._buildShortInputName({}, this.state.componentsList.length, false),
          short_input_id: this._buildShortSrcId({}, this.state.componentsList.length, false),
          short_name_translations: {},
          category_input_name: this._buildCategoryInputName({}, this.state.componentsList.length, false),
          category_input_id: this._buildCategorySrcId({}, this.state.componentsList.length, false),
          category_id: '',
          category_options: this.props.category_options,
          children: []
      };

      this.props.available_locales.forEach((lang) => {
         component.long_name_translations['long_name_' + lang] = '';
         component.short_name_translations['short_name_' + lang] = '';
      });

      var componentsList = this.state.componentsList;
      componentsList.push(component);

      this.nextUniqueId = component.id + 1;
      this.setState({componentsList: componentsList});
  }

  _addChildComponent(parentComponent) {
      var childComponent = {
          id: this.nextUniqueId,
          uuid: '',
          hidden_input_name: this._buildHiddenInputName(parentComponent, parentComponent.children.length, true),
          long_input_name: this._buildLongInputName(parentComponent, parentComponent.children.length, true),
          long_input_id: this._buildLongSrcId(parentComponent, parentComponent.children.length, true),
          long_name_translations: {},
          short_input_name: this._buildShortInputName(parentComponent, parentComponent.children.length, true),
          short_input_id: this._buildShortSrcId(parentComponent, parentComponent.children.length, true),
          short_name_translations: {},
          category_input_name: this._buildCategoryInputName(parentComponent, parentComponent.children.length, true),
          category_input_id: this._buildCategorySrcId(parentComponent, parentComponent.children.length, true),
          category_id: '',
          category_options: this.props.category_options,
          children: []
      };

      this.props.available_locales.forEach((lang) => {
         childComponent.long_name_translations['long_name_' + lang] = '';
         childComponent.short_name_translations['short_name_' + lang] = '';
      });

      var componentsList = this.state.componentsList;
      var resultList = this._insertItemInTree(componentsList, parentComponent, childComponent);
      if(resultList !== null) {
          this.nextUniqueId = childComponent.id + 1;
          this.setState({componentsList: resultList});
      }
  }

  _insertItemInTree(list, searchItem, itemToInsert) {
      for(var i = 0; i < list.length; i++) {
          var result = this._findById(list[i], searchItem.id);
          if(result){
              //Found the parent item
              if(typeof result.children !== 'undefined') {
                  result.children.push(itemToInsert);
              }
              return list;
          } else {
              //Search in the childrens
              var childrenResult = this._findById(list[i].children, searchItem.id);
              if(childrenResult){
                  //Found the parent item
                  if(typeof childrenResult.children !== 'undefined') {
                      childrenResult.children.push(itemToInsert);
                  }
                  return list;
              }
          }
      }

      return null;
  }

  _replaceTranslationValueInTree(list, searchItem, translationKey, itemKey, replaceValue) {
      for(var i = 0; i < list.length; i++) {
          var result = this._findById(list[i], searchItem.id);
          if(result){
              //Found the parent item
              result[translationKey][itemKey] = replaceValue;
              return list;
          } else {
              //Search in the childrens
              var childrenResult = this._findById(list[i].children, searchItem.id);
              if(childrenResult){
                  //Found the parent item
                  childrenResult[translationKey][itemKey] = replaceValue;
                  return list;
              }
          }
      }

      return null;
  }

  _replaceCategoryValueInTree(list, searchItem, itemKey, replaceValue) {
      for(var i = 0; i < list.length; i++) {
          var result = this._findById(list[i], searchItem.id);
          if(result){
              //Found the parent item
              result[itemKey] = replaceValue;
              return list;
          } else {
              //Search in the childrens
              var childrenResult = this._findById(list[i].children, searchItem.id);
              if(childrenResult){
                  //Found the parent item
                  childrenResult[itemKey] = replaceValue;
                  return list;
              }
          }
      }

      return null;
  }

  _deleteComponent(parentComponent) {
     var componentsList = this.state.componentsList;

    var resultList = this._deleteItemFromTree(componentsList, parentComponent);
    if(resultList !== null) {
        this.setState({componentsList: resultList});
    }

      this.setState({componentsList: componentsList});
  }

  _deleteItemFromTree(list, searchItem) {
      for(var i = 0; i < list.length; i++) {
          var result = this._findById(list[i], searchItem.id);
          if(result) { //The item was found
              var index = list.indexOf(result);
              if(index > -1) {
                  list.splice(index, 1);
                  return list;
              } else {
                  //Search in childrens
                  return this._deleteItemFromTree(list[i].children, searchItem);
              }
          } else {
              //Search in the childrens
              var childrenResult = this._findById(list[i].children, searchItem.id);
              if(childrenResult) { //The item was found
                  var index = list[i].children.indexOf(childrenResult);
                  if(index > -1) {
                      list[i].children.splice(index, 1);
                      return list;
                  }
              }
          }
      }

      return null;
  }

  _findById(o, id) {
        //Early return
        if( o.id === id ){
          return o;
        }
        var result, p;
        for (p in o) {
            if( o.hasOwnProperty(p) && typeof o[p] === 'object' && p !== 'category_options') {
                if(o[p] !== null) {
                    result = this._findById(o[p], id);
                    if(result){
                        //Found !
                        return result;
                    }
                }

            }
        }
        return result;
    }

    _findByName(o, name, nameString) {
          //Early return
          if( o[nameString] === name){
            return o;
          }
          var result, p;
          for (p in o) {
              if( o.hasOwnProperty(p) && typeof o[p] === 'object' && p !== 'category_options') {
                  if(o[p] !== null) {
                      result = this._findByName(o[p], name, nameString);
                      if(result){
                          //Found !
                          return result;
                      }
                  }

              }
          }
          return result;
      }

    _buildHiddenInputName(parentComponent, position, children) {
        var hiddenInputName = '';

        if(typeof parentComponent !== 'undefined' && children && (Object.keys(parentComponent).length !== 0)) {
            //Building a child-level name
            var nameArray = parentComponent.hidden_input_name.split('[uuid]');
            if(nameArray.length === 2) {
              hiddenInputName = nameArray[0] + '[' + position + '][uuid]';
            } else {
              hiddenInputName = parentComponent.hidden_input_name + '['+ position +'][uuid]';
            }
        } else {
            //Building a top-level name
            hiddenInputName = '[' + position + '][uuid]';
        }

        return hiddenInputName;
    }


  _buildShortInputName(parentComponent, position, children) {
      var shortInputName = '';

      if(typeof parentComponent !== 'undefined' && children && (Object.keys(parentComponent).length !== 0)) {
          //Building a child-level name
          var nameArray = parentComponent.short_input_name.split('[short_name');
          if(nameArray.length === 2) {
            shortInputName = nameArray[0] + '[' + position + ']';
          } else {
            shortInputName = parentComponent.short_input_name + '['+ position +']';
          }
      } else {
          //Building a top-level name
          var nameArray = this.props.shortInputName.split('[0]');
          if(nameArray.length === 2) {
            shortInputName = nameArray[0] + '[' + position + ']';
          } else {
            shortInputName = this.props.shortInputName;
          }
      }

      return shortInputName;
  }

  _buildHiddenInputName(parentComponent, position, children) {
      var hiddenInputName = '';

      if(typeof parentComponent !== 'undefined' && children && (Object.keys(parentComponent).length !== 0)) {
          //Building a child-level name
          var nameArray = parentComponent.hidden_input_name.split('[uuid]');
          if(nameArray.length === 2) {
            hiddenInputName = nameArray[0] + '[' + position + '][uuid]';
          } else {
            hiddenInputName = parentComponent.short_input_name + '['+ position +'][uuid]';
          }
      } else {
          //Building a top-level name
          var nameArray = this.props.shortInputName.split('[0]');
          if(nameArray.length === 2) {
            hiddenInputName = nameArray[0] + '[' + position + '][uuid]';
          } else {
            hiddenInputName = this.props.shortInputName + '[uuid]';
          }
      }

      return hiddenInputName;
  }

  _buildShortSrcId(parentComponent, position, children) {
      var srcShortId = '';

      if(typeof parentComponent !== 'undefined' && children && (Object.keys(parentComponent).length !== 0)) {
          //Building a child-level name
          var nameArray = parentComponent.short_input_id.split('_short_name');
          if(nameArray.length === 2) {
            srcShortId = nameArray[0] + '_' + position;
          } else {
            srcShortId = parentComponent.short_input_id + '_'+ position;
          }
      } else {
          //Building a top-level name
          var nameArray = this.props.srcShortId.split('_0_');
          if(nameArray.length === 2) {
            srcShortId = nameArray[0] + '_' + position;
          } else {
            srcShortId = this.props.srcShortId;
          }
      }

      return srcShortId;
  }

  _buildLongInputName(parentComponent, position, children) {
      var longInputName = '';

      if(typeof parentComponent !== 'undefined' && children && (Object.keys(parentComponent).length !== 0)) {
          //Building a child-level name
          var nameArray = parentComponent.long_input_name.split('[long_name');
          if(nameArray.length === 2) {
            longInputName = nameArray[0] + '[' + position + ']';
          } else {
            longInputName = parentComponent.long_input_name + '['+ position +']';
          }
      } else {
          //Building a top-level name
          var nameArray = this.props.longInputName.split('[0]');
          if(nameArray.length === 2) {
            longInputName = nameArray[0] + '[' + position + ']';
          } else {
            longInputName = this.props.longInputName;
          }
      }

      return longInputName;
  }

  _buildLongSrcId(parentComponent, position, children) {
      var srcLongId = '';

      if(typeof parentComponent !== 'undefined' && children && (Object.keys(parentComponent).length !== 0)) {
          //Building a child-level name
          var nameArray = parentComponent.long_input_id.split('_long_name');
          if(nameArray.length === 2) {
            srcLongId = nameArray[0] + '_' + position;
          } else {
            srcLongId = parentComponent.long_input_id + '_'+ position;
          }
      } else {
          //Building a top-level name
          var nameArray = this.props.srcLongId.split('_0_');
          if(nameArray.length === 2) {
            srcLongId = nameArray[0] + '_' + position;
          } else {
            srcLongId = this.props.srcLongId;
          }
      }

      return srcLongId;
  }

  _buildCategoryInputName(parentComponent, position, children) {
      var categoryInputName = '';

      if(typeof parentComponent !== 'undefined' && children && (Object.keys(parentComponent).length !== 0)) {
          //Building a child-level name
          var nameArray = parentComponent.category_input_name.split('[category_id]');
          if(nameArray.length === 2) {
            categoryInputName = nameArray[0] + '[' + position + '][category_id]';
          } else {
            categoryInputName = parentComponent.category_input_name + '['+ position +']';
          }
      } else {
          //Building a top-level name
          var nameArray = this.props.categoryInputName.split('[0]');
          if(nameArray.length === 2) {
            categoryInputName = nameArray[0] + '[' + position + ']' + nameArray[1];
          } else {
            categoryInputName = this.props.categoryInputName;
          }
      }

      return categoryInputName;
  }

  _buildCategorySrcId(parentComponent, position, children) {
      var srcCategoryId = '';

      if(typeof parentComponent !== 'undefined' && children && (Object.keys(parentComponent).length !== 0)) {
          //Building a child-level name
          var nameArray = parentComponent.category_input_id.split('_category_id');
          if(nameArray.length === 2) {
            srcCategoryId = nameArray[0] + '_' + position + '_category_id';
          } else {
            srcCategoryId = parentComponent.category_input_id + '_' + position + '_category_id';
          }
      } else {
          //Building a top-level name
          var nameArray = this.props.srcCategoryId.split('_0_');
          if(nameArray.length === 2) {
            srcCategoryId = nameArray[0] + '_' + position + '_category_id';
          } else {
            srcCategoryId = this.props.srcCategoryId;
          }
      }

      return srcCategoryId;
  }

  _getItemPositionInTree(list, searchItem) {
      var position = [];

      for(var i = 0; i < list.length; i++) {
          var result = this._findById(list[i], searchItem.id);
          if(result) { //The item was found
              var index = list.indexOf(result);
              if(index > -1) {
                  position.push(index);
                  return position;
              } else {
                  //Search in childrens
                  return this._deleteItemFromTree(list[i].children, searchItem);
              }
          } else {
              //Search in the childrens
              var childrenResult = this._findById(list[i].children, searchItem.id);
              if(childrenResult) { //The item was found
                  var index = list[i].children.indexOf(childrenResult);
                  if(index > -1) {
                      position.push(index);
                      return position;
                  }
              }
          }
      }

      return null;
  }

  _renameTreeComponents(list, parentComponent) {
      for(var i = 0; i < list.length; i++) {

          var component = list[i];

          if(typeof component.children === "undefined") component.children = [];

          if(parentComponent && Object.keys(parentComponent).length > 0) {
              //This component is a child component
                  var newComponent = {
                      id: component.id,
                      uuid: component.uuid,
                      hidden_input_name: this._buildHiddenInputName(parentComponent, i, true),
                      long_input_name: this._buildLongInputName(parentComponent, i, true),
                      long_input_id: this._buildLongSrcId(parentComponent, i, true),
                      long_name_translations: component.long_name_translations,
                      short_input_name: this._buildShortInputName(parentComponent, i, true),
                      short_input_id: this._buildShortSrcId(parentComponent, i, true),
                      short_name_translations: component.short_name_translations,
                      category_input_name: this._buildCategoryInputName(parentComponent, i, true),
                      category_input_id: this._buildCategorySrcId(parentComponent, i, true),
                      category_id: component.category_id,
                      category_options: component.category_options,
                      children: component.children
                  };
          } else {
              //This component is a root-level component
                  var newComponent = {
                      id: component.id,
                      uuid: component.uuid,
                      hidden_input_name: this._buildHiddenInputName({}, i, false),
                      long_input_name: this._buildLongInputName({}, i, false),
                      long_input_id: this._buildLongSrcId({}, i, false),
                      long_name_translations: component.long_name_translations,
                      short_input_name: this._buildShortInputName({}, i, false),
                      short_input_id: this._buildShortSrcId(parentComponent, i, true),
                      short_name_translations: component.short_name_translations,
                      category_input_name: this._buildCategoryInputName({}, i, false),
                      category_input_id: this._buildCategorySrcId({}, i, false),
                      category_id: component.category_id,
                      category_options: component.category_options,
                      children: component.children
                  };
          }

          if(newComponent.children.length > 0) {
            var newChildrenList = this._renameTreeComponents(newComponent.children, newComponent);
            newComponent.children = newChildrenList;
          }

          list[i] = newComponent;
      }

      return list;
  }

  _updateComponentTree(list, component) {

     this.setState({componentsList: this._renameTreeComponents(list)});
  }

  renderItem({item}) {
    return (
      <div className="row nested-fields">
        <div className="col-md-3">
            { Object.keys(item.short_name_translations).map((key) => {
                return (
                    <div key={item.short_input_id + '_' + key} className="input-group form-group">
                        <span className="input-group-addon">{key.split('short_name_')[1]}</span>
                        <input id={item.short_input_id + '_' + key} name={item.short_input_name + '[' + key + ']'} value={item.short_name_translations[key]} onChange={this._updateShortNameTranslations.bind(this)} className="form-control" type="text" required/>
                    </div>)
            })}
        </div>
        <input name={item.hidden_input_name} value={item.uuid} type="hidden"/>
        <div className="col-md-3">
            { Object.keys(item.long_name_translations).map((key) => {
                return (
                    <div key={item.long_input_id + '_' + key} className="input-group form-group">
                        <span className="input-group-addon">{key.split('long_name_')[1]}</span>
                        <input id={item.long_input_id + '_' + key} name={item.long_input_name + '[' + key + ']'} value={item.long_name_translations[key]} onChange={this._updateLongNameTranslations.bind(this)} className="form-control" type="text"/>
                    </div>)
            })}
        </div>
        <div className="col-md-3">
            <select id={item.category_input_id} className="form-control" name={item.category_input_name} value={item.category_id} onChange={this.updateSelectedCategory} disabled={item.category_options.length === 0}>
              <option key="" value=""></option>
              { item.category_options.map((item) => {
                return <option key={item.id} value={item.id}>{item.name}</option>
              })}
            </select>
        </div>
        <div className="col-md-2 pull-right">
            <a type="button" title={this.props.addChildrenChoiceLabel} onClick={() => this._addChildComponent(item)} className="btn"><i className="fa fa-plus-square"></i></a>
            <a type="button" title={this.props.removeChoiceLabel} onClick={() => this._deleteComponent(item)} className="btn"><i className="fa fa-trash"></i></a>
        </div>
      </div>
    );
  }

  renderCollapseIcon({ isCollapsed }) {
    return true;
  }

  render() {
    return (
      <div className="choiceset-input-container">
        <div className="row"><div className="col-md-12"><label>{ this.props.choiceNameLabel }</label></div></div>
        <div className="row">
          <div className="col-md-3"><label>{ this.props.shortNameLabel }</label></div>
          <div className="col-md-3"><label>{ this.props.longNameLabel }</label></div>
          <div className="col-md-3"><label>{ this.props.categoryNameLabel }</label></div>
          <div className="col-md-3"></div>
        </div>
        <Nestable
          items={[...this.state.componentsList]}
          renderItem={this.renderItem}
          renderCollapseIcon={this.renderCollapseIcon}
          onChange={this.updateComponentTree}
        />
        <div className="row">
          <div className="col-md-12">
            <a id="addRootChoice" type="button" onClick={this.addComponent} className="btn">
              <i className="fa fa-plus-square"></i> {this.props.addChoiceLabel}
            </a>
          </div>
        </div>
      </div>
    );
  }

}

export default ChoiceSetInput;
