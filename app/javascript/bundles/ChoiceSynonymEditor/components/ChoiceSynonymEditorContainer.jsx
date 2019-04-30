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
  }

  componentDidMount(){
      this.setState({ choices: this.props.choices });
      this.setState({ synonyms: this.props.synonyms });
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
          <ChoiceSynonymEditor
            key={index}
            synonym={item}
            position={index}
            choices={list}
            deleteComponent={this.deleteSynonym}
            selectPlaceholder={this.props.select_placeholder}
            selectDefaultValue={item.choice_option}/>
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
