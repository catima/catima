import 'es6-shim';
import React from 'react';
import PropTypes from 'prop-types';

import {
  SlateEditor, SlateToolbar, SlateContent,
  AlignmentPlugin, AlignmentButtonBar,
  BoldPlugin, BoldButton,
  ItalicPlugin, ItalicButton,
  LinkPlugin, LinkButton,
  ListPlugin, ListButtonBar,
  StrikethroughPlugin, StrikethroughButton,
  UnderlinePlugin, UnderlineButton,
  FootnoteButton, EndnoteButton,
  ImportDocxButton,
  H1Button, H2Button, H3Button, H4Button, ParagraphButton
} from '../sled';

import { Value } from 'slate';

import Serializer from '../modules/Serializer';

import "../css/formatted-text-editor.css";

const uuidv4 = require('uuid/v4');

const plugins = [
  AlignmentPlugin(),
  BoldPlugin(),
  ItalicPlugin(),
  LinkPlugin(),
  ListPlugin(),
  StrikethroughPlugin(),
  UnderlinePlugin(),
]

const classNames = {
  button: 'btn btn-default btn-xs not-rounded',
  dropdown: 'select col-3 inline-block mx1 not-rounded',
  input: 'input col-3 inline-block mr1',
  lastButton: 'btn btn-primary not-rounded border border-gray linebreak'
}
const styles = {
  button: {
    borderRight: '1px solid #fff'
  },
  dropdown: {
    position: 'relative',
    top: 1,
    backgroundColor: 'white',
    height: 38,
    paddingLeft: 20,
    border: '3px solid #0275d8',
    color: '#0275d8',
    margin: '0',
    WebkitAppearance: 'none',
    padding: '0 10px 0 15px'
  },
  input: {
    position: 'relative',
    top: 1,
    backgroundColor: 'white',
    borderRadius: 0,
    height: 16,
    margin: 0,
    color: '#0275d8',
    border: '3px solid #0275d8'
  }
}

class FormattedTextEditor extends React.Component {
  static PropTypes = {
    contentRef: PropTypes.string.isRequired
  };

  constructor(props){
    super(props);
    this.uid = `fte-${uuidv4()}`;
    this.value = Serializer.deserialize(this._loadContent().content);
    this.onChange = this.onChange.bind(this);
  }

  onChange(value){
    this._updateContent(value);
  }

  _loadContent(){
    const v = document.getElementById(this.props.contentRef).value;
    try {
      return JSON.parse(v);
    } catch(err) {}
    return {format: 'html', content: v};
  }

  _updateContent(value){
    const el = document.getElementById(this.props.contentRef)
    const html = Serializer.serialize(value);
    el.value = JSON.stringify({
      format: 'html',
      content: html
    });
  }

  render(){
    return (
      <div className="fte" id={this.uid}>
        <SlateEditor plugins={plugins} onChange={this.onChange} initialState={this.value}>
          <SlateToolbar>
            <ParagraphButton className={classNames.button} />
            <H1Button className={classNames.button} />
            <H2Button className={classNames.button} />
            <H3Button className={classNames.button} />
            <H4Button className={classNames.button} />
            <BoldButton className={classNames.button} />
            <ItalicButton className={classNames.button} />
            <UnderlineButton className={classNames.button} />
            <StrikethroughButton className={classNames.button} />
            <AlignmentButtonBar className={classNames.button} />
            <LinkButton className={classNames.button} />
            <ListButtonBar className={classNames.button} />
            <FootnoteButton className={classNames.button} />
            <EndnoteButton className={classNames.button} />
            <ImportDocxButton className={classNames.button} />
          </SlateToolbar>

          <SlateContent />
        </SlateEditor>
      </div>
    )
  }
}

export default FormattedTextEditor;
