import 'es6-shim';
import PropTypes from 'prop-types';
import React from 'react';

import Quill from 'quill';
import "quill/dist/quill.core.css";
import "quill/dist/quill.snow.css";

var icons = Quill.import('ui/icons');
icons['footnote'] = 'Add footnote';
icons['import_docx'] = 'Import DOCX';

import "../modules/footnote";

const noties = require('noties'),
      Noties = noties.Noties;

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

    this.handleFootnote = this.handleFootnote.bind(this);

    const self = this;

    this.toolbarOptions = {
      container: [
        [{ 'header': [false, 1, 2, 3, 4] }],
        ['bold', 'italic', 'underline', 'strike'],
        [{ 'script': 'sub'}, { 'script': 'super' }],
        ['link', 'image'],
        [{ 'list': 'ordered'}, { 'list': 'bullet' }],
        ['footnote', 'import_docx'],
      ],
      handlers: {
        'footnote': this.handleFootnote,
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

    this.footnoteRenderer = Noties(
      function(){ return self.editor.root.querySelectorAll('.footnote'); },   // footnotes
      function(){ return self.editor.root.querySelectorAll('.footnote span'); }, // reference nodes
      null  // footnote pane (we don't have any in the editor)
    );

    const c = this._loadContent();
    if (c.format == 'html' && typeof(c.doc) !== 'undefined'){
      this.editor.setContents(c.doc);
    } else {
      this.editor.clipboard.dangerouslyPasteHTML(c.content);
    }

    this.editor.on('text-change', function(delta, oldDelta, source) {
      self._updateContent();
    });

    this.footnoteRenderer.render();
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
      let html = response.data.html;
      if (html.length < 1){
        alert('Error while importing Word file. Only DOCX files are supported.');
        return;
      }

      html = self.convertDocxHtml(html);
      const range = self.editor.getSelection();
      self.editor.clipboard.dangerouslyPasteHTML(range.index, html);
    })
    .catch(function(err){
      alert('Error while importing Word file.')
    });
  }

  // Takes the HTML as produced from a custom version of Mammoth.js
  // and converts it into HTML code compatible with the text editor.
  convertDocxHtml(html){
    return html;
  }

  handleFootnote(){
    // The footnote reference is the child tag of the footnote
    // which is by default the selection and editable.
    var range = this.editor.getSelection();
    if (range) {
      let value = prompt('Enter footnote:');
      this.editor.insertEmbed(range.index, "footnote", value, "user");
    }
    this.footnoteRenderer.render();
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
