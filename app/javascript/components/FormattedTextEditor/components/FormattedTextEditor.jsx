import 'es6-shim';
import React, {useState, useEffect} from 'react';
import Translations from '../../Translations/components/Translations';
import {v4 as uuidv4} from 'uuid';

import Quill from 'quill';
import "quill/dist/quill.core.css";
import "quill/dist/quill.snow.css";

let icons = Quill.import('ui/icons');
icons['footnote'] = Translations.messages['catalog_admin.fields.text_option_inputs.add_footnote'];
icons['endnote'] = Translations.messages['catalog_admin.fields.text_option_inputs.add_endnote'];
icons['import_docx'] = Translations.messages['catalog_admin.fields.text_option_inputs.import_docx'];

import "../modules/footnote";
import "../modules/endnote";
import Noties from "../modules/noties";

// Table module for Quill
import "../modules/table";

// Ajax library for uploading DOCX files
import axios from 'axios';
import "../css/formatted-text-editor.css";

// Function to return closest element based on a selector.
// If self attribute is true, search is also applied to the element itself
function closest(el, selector, self = false) {
  var matchesFn;
  ['matches', 'webkitMatchesSelector', 'mozMatchesSelector', 'msMatchesSelector', 'oMatchesSelector'].some(function (fn) {
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

const FormattedTextEditor = (props) => {
  const {contentRef} = props

  const [handleFootnote, setHandleFootnote] = useState(() => {})
  const [handleEndnote, setHandleEndnote] = useState(() => {})

  const toolbarOptions = {
    container: [
      [{'header': [false, 1, 2, 3, 4]}],
      ['bold', 'italic', 'underline', 'strike'],
      [{'color': []}, {'background': []}],
      [{'script': 'sub'}, {'script': 'super'}],
      ['link'],
      [{'list': 'ordered'}, {'list': 'bullet'}],
      [{table: tableOptions()}, {table: 'append-row'}, {table: 'append-col'}],
      ['footnote', 'endnote', 'import_docx'],
    ],
    handlers: {
      'footnote': handleFootnote,
      'endnote': handleEndnote,
      'import_docx': importDocxCallback(),
    }
  }

  const [noteLabel, setNoteLabel] = useState('')
  const [noteElement, setNoteElement] = useState(null)
  const [noteText, setNoteText] = useState('')
  const [noteDialogDisplay, setNoteDialogDisplay] = useState('none')
  const [mainEditorDisplay, setMainEditorDisplay] = useState('block')
  const [footnoteRenderer, setFootnoteRenderer] = useState()
  const [endnoteRenderer, setEndnoteRenderer] = useState()
  const [editor, setEditor] = useState()
  const [noteEditor, setNoteEditor] = useState()
  const [uid, setUid] = useState(`quill-${uuidv4()}`)

  useEffect(() => {
    if (document.querySelector(`#${uid}`)) {
      setEditor(new Quill(`#${uid}`, {
        modules: {
          clipboard: true,
          toolbar: toolbarOptions,
          table: true
        },
        theme: 'snow',
        readOnly: true
      }))
    }
  }, [])

  useEffect(() => {
    if (!editor) return
    renderNotes();
    // Initialize the note editor
    setNoteEditor(new Quill(`#${uid}-noteEditorInstance`, {
      modules: {
        clipboard: true,
        toolbar: {
          container: [
            ['bold', 'italic', 'underline', 'strike'],
            ['link'], [{'list': 'ordered'}, {'list': 'bullet'}],
          ],
        }
      },
      theme: 'snow',
    }))

    setFootnoteRenderer(Noties(
      function () {
        return editor.root.querySelectorAll('.footnote');
      },   // footnotes
      function () {
        return editor.root.querySelectorAll('.footnote span');
      }, // reference nodes
      null  // footnote pane (we don't have any in the editor)
    ))

    setEndnoteRenderer(Noties(
      function () {
        return editor.root.querySelectorAll('.endnote');
      },   // endnotes
      function () {
        return editor.root.querySelectorAll('.endnote span');
      }, // reference nodes
      null,  // endnote pane (we don't have any in the editor)
      function (v) {
        return '[' + v + ']';
      }    // reference formatter
    ))
  }, [editor])

  useEffect(() => {
    if (!noteEditor) return

    editor.clipboard.addMatcher('SPAN', function (node, delta) {
      if (node.classList.contains('footnote')) {
        let noteText = node.innerHTML;
        if (node.hasAttribute('data-note')) noteText = node.getAttribute('data-note');
        delta.ops = [];
        return delta.insert({footnote: noteText});
      }
      return delta;
    });

    editor.clipboard.addMatcher('SPAN', function (node, delta) {
      if (node.classList.contains('endnote')) {
        let noteText = node.innerHTML;
        if (node.hasAttribute('data-note')) noteText = node.getAttribute('data-note');
        delta.ops = [];
        return delta.insert({endnote: noteText});
      }
      return delta;
    });

    const c = _loadContent();
    if (c.format === 'html' && typeof (c.doc) !== 'undefined') {
      editor.setContents(c.doc);
    } else {
      editor.clipboard.dangerouslyPasteHTML(c.content);
    }

    // The editor is created with the read-only option activated and should be only enabled after content is set.
    // This is to avoid the autofocus issue with quill.
    editor.enable(true);

    editor.on('text-change', function (delta, oldDelta, source) {
      _updateContent();
      renderNotes();
    });

    noteEditor.on('text-change', function (delta, oldDelta, source) {
      setNoteText(noteEditor.root.innerHTML);
    })

    setHandleFootnote(() => () => {
      var range = editor.getSelection();
      prompt(range)
      if (range) {
        let value = prompt(Translations.messages['catalog_admin.fields.text_option_inputs.enter_footnote']);
        if (value) editor.insertEmbed(range.index, "footnote", value, "user");
      }
      renderNotes();
    })

    setHandleEndnote(() => () => {
      var range = editor.getSelection();
      prompt(range)
      if (range) {
        let value = prompt(Translations.messages['catalog_admin.fields.text_option_inputs.enter_endnote']);
        if (value) editor.insertEmbed(range.index, "endnote", value, "user");
      }
      renderNotes();
    })
  }, [noteEditor])

  useEffect(() => {
    if (!footnoteRenderer || !endnoteRenderer) return

    renderNotes();
  }, [footnoteRenderer, endnoteRenderer])

  function tableOptions(maxRows = 10, maxCols = 5) {
    let tableOptions = [];
    for (let r = 1; r <= maxRows; r++) {
      for (let c = 1; c <= maxCols; c++) {
        tableOptions.push('newtable_' + r + '_' + c);
      }
    }
    return tableOptions;
  }

  function _loadContent() {
    const v = document.getElementById(contentRef).value;
    try {
      return JSON.parse(v);
    } catch (err) {
    }
    return {format: 'html', content: v};
  }

  function _updateContent() {
    const el = document.getElementById(contentRef)

    if (editor.getLength() > 1) {
      el.value = JSON.stringify({
        format: 'html',
        doc: editor.getContents(),
        content: '<p style="display:none;"></p>' +
            _prepareHtmlForSaving(editor.root.innerHTML) +
            '<p style="display:none;"></p>'
      });
    } else {
      el.value = '';
    }
  }

  function _prepareHtmlForSaving(html) {
    const el = document.createElement('div');
    el.innerHTML = html;
    const footnotes = el.querySelectorAll('span.footnote');
    for (let i = 0; i < footnotes.length; i++) {
      footnotes[i].innerHTML = '';
    }
    const endnotes = el.querySelectorAll('span.endnote');
    for (let i = 0; i < endnotes.length; i++) {
      endnotes[i].innerHTML = '';
    }
    return el.innerHTML;
  }

  // Function to trigger the file selection dialog based on a hidden file input
  function importDocxCallback() {
    return function () {
      const el = document.getElementById(`${uid}-fileInput`);
      el.click();
    };
  }

  // Handles the upload of the DOCX to the server
  function _docxUpload() {
    const el = document.getElementById(`${uid}-fileInput`);
    if (el.files.length == 0) return;
    const f = el.files[0];

    const data = new FormData();
    data.append('docx', f);

    axios.post('/s/docx2html', data)
      .then(function (response) {
        el.value = "";
        let html = response.data.html;
        if (html.length < 1) {
          alert(Translations.messages['catalog_admin.fields.text_option_inputs.import_error_not_supported']);
          return;
        }
        const range = editor.getSelection();
        editor.clipboard.dangerouslyPasteHTML(range.index, html);
      })
      .catch(function (err) {
        alert(Translations.messages['catalog_admin.fields.text_option_inputs.import_error'])
      })
  }

  function renderNotes() {
    if (!footnoteRenderer || !endnoteRenderer) return
    footnoteRenderer.render();
    const footnotesRefs = document.querySelectorAll('#' + uid + ' span.footnote');
    for (let i = 0; i < footnotesRefs.length; i++) {
      footnotesRefs[i].addEventListener('click', handleFootnoteClick);
    }
    endnoteRenderer.render();
    const endnotesRefs = document.querySelectorAll('#' + uid + ' span.endnote');
    for (let i = 0; i < endnotesRefs.length; i++) {
      endnotesRefs[i].addEventListener('click', handleEndnoteClick);
    }
  }

  function handleFootnoteClick(e) {
    const footnoteEl = closest(e.target, '.footnote');
    editNote(footnoteEl, Translations.messages['catalog_admin.fields.text_option_inputs.edit_footnote']);
  }

  function handleEndnoteClick(e) {
    const endnoteEl = closest(e.target, '.endnote');
    editNote(endnoteEl, Translations.messages['catalog_admin.fields.text_option_inputs.edit_endnote']);
  }

  function editNote(noteEl, lbl) {
    const noteHtml = noteEl.getAttribute('data-note');
    setNoteLabel(lbl);
    setNoteElement(noteEl);
    setNoteText(noteHtml);
    setNoteDialogDisplay('block');
    setMainEditorDisplay('none');
    noteEditor.setText('');
    noteEditor.clipboard.dangerouslyPasteHTML(noteHtml);
  }

  function saveNote(e) {
    e.preventDefault()
    noteElement.setAttribute('data-note', noteText);
    setNoteDialogDisplay('none');
    setMainEditorDisplay('block');
  }

  return (
    <React.Fragment>
      <div className="formattedTextEditor" id={uid + '-editor'}>
        <input id={uid + '-fileInput'} accept="application/vnd.openxmlformats-officedocument.wordprocessingml.document"
               type="file" onChange={_docxUpload} className="hide"/>
        <div id={uid + '-noteEditor'} className="noteEditor" style={{'display': noteDialogDisplay}}>
          <label>{noteLabel}</label><br/>
          <div id={uid + '-noteEditorInstance'}></div>
          <br/>
          <span onClick={saveNote} className="btn btn-sm btn-outline-secondary">
            {Translations.messages['catalog_admin.fields.text_option_inputs.save_note']}
          </span>

        </div>
        <div style={{'display': mainEditorDisplay}}>
          <div id={uid}></div>
        </div>
      </div>
    </React.Fragment>
  );
}

export default FormattedTextEditor;
