import 'es6-shim';
import PropTypes from 'prop-types';
import React from 'react';
import {
  CompositeDecorator,
  Editor,
  EditorState,
  Modifier,
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

    const compositeDecorator = new CompositeDecorator([
      {
        strategy: fieldStrategy,
        component: FieldSpan,
      },
    ]);

    this.state = {
      editorState: EditorState.createWithContent(
        convertFromHTML(this._loadContent(this.props.contentRef)),
        compositeDecorator
      ),
    };
    this.focus = () => this.refs.editor.focus();
    this.onChange = function(editorState){
      self._updateContent(self.props.contentRef, convertToHTML(editorState.getCurrentContent()));
      self.setState({editorState});
    }
    this.handleKeyCommand = this._handleKeyCommand.bind(this);
    this.onTab = this._onTab.bind(this);
    this.toggleBlockType = this._toggleBlockType.bind(this);
    this.toggleInlineStyle = this._toggleInlineStyle.bind(this);
    this.addField = this._addField.bind(this);
    this.onFieldChange = this._confirmField.bind(this);
    this.onFieldInputKeyDown = this._onFieldInputKeyDown.bind(this);
  }

  _handleKeyCommand(command, editorState) {
    const newState = RichUtils.handleKeyCommand(editorState, command);
    if (newState) {
      this.onChange(newState);
      return 'handled';
    }
    return 'not-handled';
  }

  _onTab(e) {
    const maxDepth = 4;
    this.onChange(RichUtils.onTab(e, this.state.editorState, maxDepth));
  }

  _toggleBlockType(blockType) {
    this.onChange(RichUtils.toggleBlockType(this.state.editorState, blockType));
  }

   _toggleInlineStyle(inlineStyle) {
    this.onChange(RichUtils.toggleInlineStyle(this.state.editorState, inlineStyle));
  }

  _loadContent(ref){
    let v = JSON.parse(document.getElementById(ref).value || {});
    return v[this.props.locale] || '';
  }

  _updateContent(ref, html){
    let v = JSON.parse(document.getElementById(ref).value || {});
    v[this.props.locale] = html;
    document.getElementById(ref).value = JSON.stringify(v);
  }

  _addField(e){
    e.preventDefault();
    const {editorState, fieldName} = this.state;
    this.setState({
      showFieldInput: true,
      fieldName: fieldName,
    }, () => {
      setTimeout(() => this.refs.fieldName.focus(), 0);
    });
  }

  _onFieldInputKeyDown(e){
    if (e.which === 27) {
      this.setState({
        showFieldInput: false,
        fieldName: '',
      });
    }
  }

  _confirmField(e){
    e.preventDefault();
    let fieldName = e.target.value;
    const {editorState} = this.state;
    const selection = editorState.getSelection();
    const contentState = editorState.getCurrentContent();
    const ncs = Modifier.insertText(contentState, selection, " {{"+fieldName+"}} ");
    const es = EditorState.push(editorState, ncs, 'insert-fragment');
    this.setState({
      editorState: es,
      showFieldInput: false,
      fieldName: '',
    }, () => {
      setTimeout(() => this.refs.editor.focus(), 0);
    });
  }

  render(){
    const {editorState} = this.state;
    let className = 'RichEditor-editor';

    let fieldInput;
    if (this.state.showFieldInput){
      fieldInput =
        <div style={styles.fieldInputContainer}>
          <select
            onChange={this.onFieldChange}
            ref="fieldName"
            style={styles.fieldInput}
            type="text"
            value={this.state.fieldName}
            onKeyDown={this.onFieldInputKeyDown}
          >
            <option value="">---</option>
            <option value="test">Test</option>
          </select>
        </div>
    }

    return (
      <div className="RichEditor-root">
        <BlockStyleControls
          editorState={editorState}
          onToggle={this.toggleBlockType}
        />
        <InlineStyleControls
          editorState={editorState}
          onToggle={this.toggleInlineStyle}
        />
        <div className="RichEditor-controls">
          <span className="RichEditor-styleButton" onMouseDown={this.addField} style={{marginRight: 10}}>Add field</span>
          {fieldInput}
        </div>
        <div className={className} onClick={this.focus}>
          <Editor
            blockStyleFn={getBlockStyle}
            editorState={editorState}
            onChange={this.onChange}
            handleKeyCommand={this.handleKeyCommand}
            onTab={this.onTab}
            ref="editor"
          />
        </div>
      </div>
    );
  }
}

function getBlockStyle(block) {
  switch (block.getType()) {
    case 'blockquote': return 'RichEditor-blockquote';
    default: return null;
  }
}

class StyleButton extends React.Component {
  constructor() {
    super();
    this.onToggle = (e) => {
      e.preventDefault();
      this.props.onToggle(this.props.style);
    };
  }
  render() {
    let className = 'RichEditor-styleButton';
    if (this.props.active) {
      className += ' RichEditor-activeButton';
    }
    return (
      <span className={className} onMouseDown={this.onToggle}>
        {this.props.label}
      </span>
    );
  }
}

const BLOCK_TYPES = [
  {label: 'H1', style: 'header-one'},
  {label: 'H2', style: 'header-two'},
  {label: 'H3', style: 'header-three'},
  {label: 'H4', style: 'header-four'},
  {label: 'H5', style: 'header-five'},
  {label: 'H6', style: 'header-six'},
  {label: 'UL', style: 'unordered-list-item'},
  {label: 'OL', style: 'ordered-list-item'},
];

const BlockStyleControls = (props) => {
  const {editorState} = props;
  const selection = editorState.getSelection();
  const blockType = editorState
    .getCurrentContent()
    .getBlockForKey(selection.getStartKey())
    .getType();
  return (
    <div className="RichEditor-controls">
      {BLOCK_TYPES.map((type) =>
        <StyleButton
          key={type.label}
          active={type.style === blockType}
          label={type.label}
          onToggle={props.onToggle}
          style={type.style}
        />
      )}
    </div>
  );
};

var INLINE_STYLES = [
  {label: 'Bold', style: 'BOLD'},
  {label: 'Italic', style: 'ITALIC'},
  {label: 'Underline', style: 'UNDERLINE'},
];

const InlineStyleControls = (props) => {
  var currentStyle = props.editorState.getCurrentInlineStyle();
  return (
    <div className="RichEditor-controls">
      {INLINE_STYLES.map(type =>
        <StyleButton
          key={type.label}
          active={currentStyle.has(type.style)}
          label={type.label}
          onToggle={props.onToggle}
          style={type.style}
        />
      )}
    </div>
  );
};


const FIELD_REGEX = /{{[\w\-]+}}/g;

function fieldStrategy(contentBlock, callback, contentState) {
  findWithRegex(FIELD_REGEX, contentBlock, callback);
}

function findWithRegex(regex, contentBlock, callback) {
  const text = contentBlock.getText();
  let matchArr, start;
  while ((matchArr = regex.exec(text)) !== null) {
    start = matchArr.index;
    callback(start, start + matchArr[0].length);
  }
}

const FieldSpan = (props) => {
  return (
    <span
      style={styles.field}
      data-offset-key={props.offsetKey}
    >
      {props.children}
    </span>
  );
};

const styles = {
  field: {
    color: '#000',
    backgroundColor: '#eef',
    border: '1px solid #00f',
    padding: 4,
    fontFamily: 'monospace',
    fontSize: '90%',
    fontWeight: 800,
    cursor: 'pointer',
  },
  fieldInputContainer: {
    display: 'inline-block',
  },
  fieldInput: {},
};

export default TemplateEditor;

