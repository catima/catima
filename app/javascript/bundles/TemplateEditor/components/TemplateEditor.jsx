import PropTypes from 'prop-types';
import React from 'react';
import {
  Editor,
  EditorState,
  RichUtils,
} from 'draft-js';
import {
  convertFromHTML,
  convertToHTML,
} from 'draft-convert';



class TemplateEditor extends React.Component {
  static propTypes = {
    contentRef: PropTypes.string.isRequired,
    locale: PropTypes.string.isRequired,
  };

  constructor(props){
    super(props);
    const self = this;
    this.state = {
      editorState: EditorState.createWithContent(
        convertFromHTML(this.loadContent(this.props.contentRef))
      ),
    };
    this.focus = () => this.refs.editor.focus();
    this.onChange = function(editorState){
      self.updateContent(self.props.contentRef, convertToHTML(editorState.getCurrentContent()));
      self.setState({editorState});
    }
    this.handleKeyCommand = this.handleKeyCommand.bind(this);
  }

  handleKeyCommand(command, editorState) {
    const newState = RichUtils.handleKeyCommand(editorState, command);
    if (newState) {
      this.onChange(newState);
      return 'handled';
    }
    return 'not-handled';
  }

  loadContent(ref){
    let v = JSON.parse(document.getElementById(ref).value || {});
    return v[this.props.locale] || '';
  }

  updateContent(ref, html){
    let v = JSON.parse(document.getElementById(ref).value || {});
    v[this.props.locale] = html;
    document.getElementById(ref).value = JSON.stringify(v);
  }

  render(){
    return (
      <Editor
        editorState={this.state.editorState}
        onChange={this.onChange}
        handleKeyCommand={this.handleKeyCommand}
      />
    );
  }
}

export default TemplateEditor;
