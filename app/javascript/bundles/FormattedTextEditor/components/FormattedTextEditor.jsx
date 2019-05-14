import 'es6-shim';
import PropTypes from 'prop-types';
import React from 'react';

import Quill from 'quill';
import "quill/dist/quill.core.css";
import "quill/dist/quill.snow.css";

var icons = Quill.import('ui/icons');
icons['footnote'] = 'Add footnote';
icons['endnote'] = 'Add endnote';
icons['import_docx'] = 'Import DOCX';

import "../modules/footnote";
import "../modules/endnote";
import Noties from "../modules/noties";

// Table module for Quill
import "../modules/table";

// Ajax library for uploading DOCX files
import axios from 'axios';

import "../css/formatted-text-editor.css";

const uuidv4 = require('uuid/v4');


// Function to return closest element based on a selector.
// If self attribute is true, search is also applied to the element itself
function closest(el, selector, self=false) {
    var matchesFn;
    ['matches','webkitMatchesSelector','mozMatchesSelector','msMatchesSelector','oMatchesSelector'].some(function(fn) {
        if (typeof document.body[fn] == 'function') {
            matchesFn = fn;
            return true;
        }
        return false;
    })
    if (self && el[matchesFn](selector)) return el;
    var parent;
    while (el) {
        parent = el.parentElement;
        if (parent && parent[matchesFn](selector)) {
            return parent;
        }
        el = parent;
    }
    return null;
}


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
    this.handleEndnote = this.handleEndnote.bind(this);
    this.handleFootnoteClick = this.handleFootnoteClick.bind(this);
    this.handleEndnoteClick = this.handleEndnoteClick.bind(this);
    this.saveNote = this.saveNote.bind(this);

    this.state = {
      noteLabel: '',
      noteElement: null,
      noteText: '',
      noteDialogDisplay: 'none',
      mainEditorDisplay: 'block',
    };

    const self = this;

    this.toolbarOptions = {
      container: [
        [{ 'header': [false, 1, 2, 3, 4] }],
        ['bold', 'italic', 'underline', 'strike'],
        [{ 'color': [] }, { 'background': [] }],
        [{ 'script': 'sub'}, { 'script': 'super' }],
        ['link'],
        [{ 'list': 'ordered'}, { 'list': 'bullet' }],
        [{ table: FormattedTextEditor.tableOptions() }, { table: 'append-row' }, { table: 'append-col' }],
        ['footnote', 'endnote', 'import_docx'],
      ],
      handlers: {
        'footnote': this.handleFootnote,
        'endnote': this.handleEndnote,
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
      content: '<p style="display:none;"></p>' +
          this._prepareHtmlForSaving(this.editor.root.innerHTML) +
          '<p style="display:none;"></p>'
    });
  }

  _prepareHtmlForSaving(html){
    const el = document.createElement('div');
    el.innerHTML = html;
    const footnotes = el.querySelectorAll('span.footnote');
    for (let i=0; i < footnotes.length; i++){
      footnotes[i].innerHTML = '';
    }
    const endnotes = el.querySelectorAll('span.endnote');
    for (let i=0; i < endnotes.length; i++){
      endnotes[i].innerHTML = '';
    }
    return el.innerHTML;
  }

  componentDidMount(){
    const self = this;

    this.editor = new Quill(`#${this.uid}`, {
      modules: {
        clipboard: true,
        toolbar: this.toolbarOptions,
        table: true
      },
      theme: 'snow',
    });

    this.editor.clipboard.addMatcher('SPAN', function(node, delta){
      if (node.classList.contains('footnote')) {
        let noteText = node.innerHTML;
        if (node.hasAttribute('data-note')) noteText = node.getAttribute('data-note');
        delta.ops = [];
        return delta.insert({ footnote: noteText });
      }
      return delta;
    });

    this.editor.clipboard.addMatcher('SPAN', function(node, delta){
      if (node.classList.contains('endnote')) {
        let noteText = node.innerHTML;
        if (node.hasAttribute('data-note')) noteText = node.getAttribute('data-note');
        delta.ops = [];
        return delta.insert({ endnote: noteText });
      }
      return delta;
    });

    this.footnoteRenderer = Noties(
      function(){ return self.editor.root.querySelectorAll('.footnote'); },   // footnotes
      function(){ return self.editor.root.querySelectorAll('.footnote span'); }, // reference nodes
      null  // footnote pane (we don't have any in the editor)
    );

    this.endnoteRenderer = Noties(
      function(){ return self.editor.root.querySelectorAll('.endnote'); },   // endnotes
      function(){ return self.editor.root.querySelectorAll('.endnote span'); }, // reference nodes
      null,  // endnote pane (we don't have any in the editor)
      function(v){ return '['+v+']'; }    // reference formatter
    );

    const c = this._loadContent();
    if (c.format == 'html' && typeof(c.doc) !== 'undefined'){
      this.editor.setContents(c.doc);
    } else {
      this.editor.clipboard.dangerouslyPasteHTML(c.content);
    }

    this.editor.on('text-change', function(delta, oldDelta, source) {
      self._updateContent();
      self.renderNotes();
    });

    this.renderNotes();

    // Initialize the note editor
    this.noteEditor = new Quill(`#${this.uid}-noteEditorInstance`, {
      modules: {
        clipboard: true,
        toolbar: {
          container: [
            ['bold', 'italic', 'underline', 'strike'],
            ['link'], [{ 'list': 'ordered'}, { 'list': 'bullet' }],
          ],
        }
      },
      theme: 'snow',
    });

    this.noteEditor.on('text-change', function(delta, oldDelta, source){
      self.setState({noteText: self.noteEditor.root.innerHTML});
    })

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

    const csrfToken = $('meta[name="csrf-token"]').attr('content');

    axios.post('/s/docx2html', data, { headers: {'X-CSRF-Token': csrfToken} })
    .then(function(response){
      el.value = "";
      let html = response.data.html;
      if (html.length < 1){
        alert('Error while importing Word file. Only DOCX files are supported.');
        return;
      }

      const range = self.editor.getSelection();
      self.editor.clipboard.dangerouslyPasteHTML(range.index, html);
    })
    .catch(function(err){
      console.log('Error while importing Word file', err);
      alert('Error while importing Word file.')
    })
  }

  handleFootnote(){
    // The footnote reference is the child tag of the footnote
    // which is by default the selection and editable.
    var range = this.editor.getSelection();
    if (range) {
      let value = prompt('Enter footnote:');
      if (value) this.editor.insertEmbed(range.index, "footnote", value, "user");
    }
    this.renderNotes();
  }

  handleEndnote(){
    var range = this.editor.getSelection();
    if (range) {
      let value = prompt('Enter endnote:');
      if (value) this.editor.insertEmbed(range.index, "endnote", value, "user");
    }
    this.renderNotes();
  }

  renderNotes(){
    this.footnoteRenderer.render();
    const footnotesRefs = document.querySelectorAll('#' + this.uid + ' span.footnote');
    for (let i=0; i < footnotesRefs.length; i++) {
      footnotesRefs[i].addEventListener('click', this.handleFootnoteClick);
    }
    this.endnoteRenderer.render();
    const endnotesRefs = document.querySelectorAll('#' + this.uid + ' span.endnote');
    for (let i=0; i < endnotesRefs.length; i++) {
      endnotesRefs[i].addEventListener('click', this.handleEndnoteClick);
    }
  }

  handleFootnoteClick(e){
    const footnoteEl = closest(e.target, '.footnote');
    this.editNote(footnoteEl, 'Edit footnote');
  }

  handleEndnoteClick(e){
    const endnoteEl = closest(e.target, '.endnote');
    this.editNote(endnoteEl, 'Edit endnote');
  }

  editNote(noteEl, lbl){
    const noteHtml = noteEl.getAttribute('data-note');
    this.setState({noteLabel: lbl});
    this.setState({noteElement: noteEl});
    this.setState({noteText: noteHtml});
    this.setState({noteDialogDisplay: 'block'});
    this.setState({mainEditorDisplay: 'none'});
    this.noteEditor.setText('');
    this.noteEditor.clipboard.dangerouslyPasteHTML(noteHtml);
  }

  saveNote(){
    this.state.noteElement.setAttribute('data-note', this.state.noteText);
    this.setState({noteDialogDisplay: 'none'});
    this.setState({mainEditorDisplay: 'block'});
  }

  // handleNoteTextChange(e){
  //   this.setState({noteText: e.target.value});
  // }

  // Return options array for Quill table module
  static tableOptions(maxRows = 10, maxCols = 5){
    let tableOptions = [];
    for (let r = 1; r <= maxRows; r++) {
      for (let c = 1; c <= maxCols; c++) {
        tableOptions.push('newtable_' + r + '_' + c);
      }
    }
    return tableOptions;
  }

  render(){
    // onChange={this.handleNoteTextChange} value={this.state.noteText}
    return (
      <div className="formattedTextEditor" id={this.uid + '-editor'}>
        <input id={this.uid + '-fileInput'} accept="application/vnd.openxmlformats-officedocument.wordprocessingml.document" type="file" onChange={this.docxUpload} className="hide" />
        <div id={this.uid + '-noteEditor'} className="noteEditor" style={{'display': this.state.noteDialogDisplay}}>
          <label>{this.state.noteLabel}</label><br/>
          <div id={this.uid + '-noteEditorInstance'}></div><br/>
          <span onClick={this.saveNote} className="btn btn-sm btn-default">Save</span>
        </div>
        <div style={{'display': this.state.mainEditorDisplay}}>
          <div id={this.uid}></div>
        </div>
      </div>
    );
  }
}

export default FormattedTextEditor;
