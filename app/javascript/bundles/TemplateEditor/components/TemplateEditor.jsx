import PropTypes from 'prop-types';
import React from 'react';
import {
  CompositeDecorator,
  ContentState,
  Editor,
  EditorState,
  RichUtils,
  convertFromHTML,
  convertToRaw
} from 'draft-js';

class TemplateEditor extends React.Component {
  static propTypes = {
    content: PropTypes.string.isRequired,
    locale: PropTypes.string.isRequired,
  };

  constructor(props){
    super(props);

    const self = this;

    const decorator = new CompositeDecorator([]);

    const blocksFromHTML = convertFromHTML(this.props.content);

    const state = ContentState.createFromBlockArray(
      blocksFromHTML.contentBlocks,
      blocksFromHTML.entityMap,
    );

    this.state = {
      editorState: EditorState.createWithContent(
        state,
        decorator,
      ),
    };

    this.focus = () => this.refs.editor.focus();

    this.onChange = function(editorState){
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
