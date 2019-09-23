import React, { Component } from 'react';
import ChoiceSynonymEditor from './ChoiceSynonymEditor';

class ChoiceSynonymEditorContainer extends Component {
  constructor(props){
    super(props);

    this.state = {
      choices: [],
      synonyms: []
    };

    this.addSynonym = this._addSynonym.bind(this);
    this.deleteSynonym = this._deleteSynonym.bind(this);
    this.initSynonyms = this._initSynonyms.bind(this);
  }

  componentDidMount(){
    this.initSynonyms();

    this.setState({ choices: this.props.choices });
  }

  _initSynonyms() {
    let languagesCount = this.props.available_languages.length;
    let synonyms = this.props.synonyms;

    synonyms.forEach((choice_synonyms) => {
      if (Object.keys(choice_synonyms.synonym).length !== languagesCount) {
        this.props.available_languages.forEach(language => {
          if (!choice_synonyms.synonym[language]) {
            choice_synonyms.synonym[language] = '';
          }
        });
      }
    });

    this.setState({ synonyms: synonyms });
  }

  _addSynonym(){
      var synonymsList = this.state.synonyms;

      var emptySynonym = {};
      this.props.available_languages.forEach((lang) => {
          emptySynonym[lang] = '';
      });

      synonymsList.push({choice_id: null, synonym: emptySynonym});
      this.setState({synonyms: synonymsList})
  }

  _deleteSynonym(index) {
    var synonymsList = this.state.synonyms;
    synonymsList.splice(index, 1);
    this.setState({synonyms: synonymsList});
  }

  renderSynonymComponent(item, index, list){
      return (
        <div
          key={"choice_synonym_editor_" + index}>
          <ChoiceSynonymEditor
            synonym={item}
            position={index}
            choices={list}
            deleteComponent={this.deleteSynonym}
            selectPlaceholder={this.props.select_placeholder}
            selectDefaultValue={item.choice_option}/>
            <hr/>
        </div>
      );
  }

  renderSynonymComponentList() {
    const list = this.state.synonyms;
    if(list.length !== 0) {
        return this.state.synonyms.map((item, index) => this.renderSynonymComponent(item, index, this.state.choices));
    }
  }

  render() {
    return (
      <div className="choiceset-synonym-container">
        {this.renderSynonymComponentList()}
        <div className="row">
          <div className="col-md-12">
            <a id="addRootSynonym" type="button" onClick={this.addSynonym} className="btn">
              <i className="fa fa-plus-square"></i> {this.props.add_synonym_label}
            </a>
          </div>
        </div>
      </div>
    );
  }

}

export default ChoiceSynonymEditorContainer;
