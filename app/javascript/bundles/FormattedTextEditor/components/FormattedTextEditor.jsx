import 'es6-shim';
import PropTypes from 'prop-types';
import React from 'react';

import Quill from 'quill';
import "quill/dist/quill.core.css";
import "quill/dist/quill.snow.css";

const uuidv4 = require('uuid/v4');

class FormattedTextEditor extends React.Component {
  static propTypes = {
    contentRef: PropTypes.string.isRequired
  };

  constructor(props){
    super(props);
    this.uid = `quill-${uuidv4()}`;
    this.updateContent = this._updateContent.bind(this);
  }

  _loadContent(){
    const v = document.getElementById(this.props.contentRef).value;
    try {
      return JSON.parse(v);
    } catch(err) {}
    return {format: 'html', content: v};
  }

  _updateContent(){
    const el = document.getElementById(this.props.contentRef)
    el.value = JSON.stringify({
      format: 'html',
      doc: this.editor.getContents(),
      content: this.editor.root.innerHTML
    });
  }

  componentDidMount(){
    const self = this;

    this.editor = new Quill(`#${this.uid}`, {
      modules: {
        clipboard: true,
        toolbar: true
      },
      theme: 'snow',
    });

    const c = this._loadContent();
    if (c.format == 'html' && typeof(c.doc) !== 'undefined'){
      this.editor.setContents(c.doc);
    } else {
      this.editor.clipboard.dangerouslyPasteHTML(c.content);
    }

    this.editor.on('text-change', function(delta, oldDelta, source) {
      self._updateContent();
    });
  }

  componentWillUnmount(){}

  render(){
    return (
      <div className="formattedTextEditor">
        <div id={this.uid}></div>
      </div>
    );
  }
}

export default FormattedTextEditor;
