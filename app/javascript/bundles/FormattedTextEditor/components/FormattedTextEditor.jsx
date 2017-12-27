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
    return (document.getElementById(this.props.contentRef).value || '');
  }

  _updateContent(content){
    const el = document.getElementById(this.props.contentRef)
    el.value = content;
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

    const content = this._loadContent();
    this.editor.clipboard.dangerouslyPasteHTML(content);

    this.editor.on('text-change', function(delta, oldDelta, source) {
      self._updateContent(self.editor.root.innerHTML);
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
