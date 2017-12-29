import 'es6-shim';
import PropTypes from 'prop-types';
import React from 'react';

import Quill from 'quill';
import "quill/dist/quill.core.css";
import "quill/dist/quill.snow.css";

// Ajax library for uploading DOCX files
import axios from 'axios';

import "../css/formatted-text-editor.css";

const uuidv4 = require('uuid/v4');

class FormattedTextEditor extends React.Component {
  static propTypes = {
    contentRef: PropTypes.string.isRequired
  };

  constructor(props){
    super(props);
    this.uid = `quill-${uuidv4()}`;
    this.updateContent = this._updateContent.bind(this);
    this.docxUpload = this._docxUpload.bind(this);

    const self = this;

    this.toolbarOptions = {
      container: [
        [{ 'header': [false, 1, 2, 3, 4] }],
        ['bold', 'italic', 'underline', 'strike'],
        [{ 'script': 'sub'}, { 'script': 'super' }],
        ['link', 'image'],
        [{ 'list': 'ordered'}, { 'list': 'bullet' }],
        ['import_docx'],
      ],
      handlers: {
        'import_docx': this.importDocxCallback(),
      }
    };
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
        toolbar: this.toolbarOptions,
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

  // Function to trigger the file selection dialog based on a hidden file input
  importDocxCallback(){
    const self = this;
    return function(){
      const el = document.getElementById(`${self.uid}-fileInput`);
      el.click();
    };
  }

  // Handles the upload of the DOCX to the server
  _docxUpload(){
    const self = this;

    const el = document.getElementById(`${this.uid}-fileInput`);
    if (el.files.length == 0) return;
    const f = el.files[0];

    const data = new FormData();
    data.append('docx', f);

    const csrfToken = document.getElementsByName('csrf-token')[0].content;

    axios.post('/s/docx2html', data, { headers: {'X-CSRF-Token': csrfToken} })
    .then(function(response){
      const html = response.data.html;
      if (html.length < 1){
        alert('Error while importing Word file. Only DOCX files are supported.');
        return;
      }

      const range = self.editor.getSelection();
      self.editor.clipboard.dangerouslyPasteHTML(range.index, html);
    })
    .catch(function(err){
      alert('Error while importing Word file.')
    });
  }

  render(){
    return (
      <div className="formattedTextEditor">
        <input id={this.uid + '-fileInput'} accept="application/vnd.openxmlformats-officedocument.wordprocessingml.document" type="file" onChange={this.docxUpload} className="hide" />
        <div id={this.uid}></div>
      </div>
    );
  }
}

export default FormattedTextEditor;
