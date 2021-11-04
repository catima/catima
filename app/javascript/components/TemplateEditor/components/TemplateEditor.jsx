import 'es6-shim';
import PropTypes from "prop-types";
import React, {useState, useEffect} from 'react';
import {v4 as uuidv4} from 'uuid';

const TemplateEditor = (props) => {
  const {
    contentRef,
    locale,
    fields
  } = props

  const uid = `summernote-${uuidv4()}`;
  const [editor, setEditor] = useState(false)
  const [html, setHtml] = useState(false)

  function _loadContent() {
    let v = JSON.parse(document.getElementById(contentRef).value || {});
    return v[locale] || '';
  }

  function _updateContent(html) {
    const el = document.getElementById(contentRef)
    let v = JSON.parse(el.value || {});
    v[locale] = html;
    el.value = JSON.stringify(v);
  }

  useEffect(() => {
    setHtml(_loadContent())

    setEditor($(`#${uid}`))
  }, [])

  useEffect(() => {
    if (editor && html !== false) {
      const options = {
        minHeight: 150,
        toolbar: [
          ['style', ['bold', 'italic', 'underline', 'clear']],
          ['font', ['strikethrough', 'superscript', 'subscript']],
          ['fontsize', ['fontsize']],
          ['color', ['color']],
          ['para', ['ul', 'ol', 'paragraph']],
          ['height', ['height']],
          ['insert', ['picture', 'link', 'table', 'hr']],
          ['templateEditor', ['fieldsMenu', 'itemLinkButton']]
        ],
        buttons: {
          fieldsMenu: fieldsMenu(editor, fields),
          itemLinkButton: itemLinkButton(editor),
        },
        callbacks: {
          onChange: _updateContent
        }
      };
      editor.summernote(options);
      editor.summernote('code', html);

      $('.note-link-popover').css('display', 'none');
      $('.dropdown-toggle').dropdown();
    }
  }, [editor, html])

  function fieldsMenu(editor, fields) {
    return function () {
      const ui = $.summernote.ui;
      let fieldsMenu = [];
      for (let i in fields) {
        let f = fields[i];
        fieldsMenu.push(`<${f.type}Field>${f.slug}</${f.type}Field>`);
      }
      const button = ui.buttonGroup([
        ui.button({
          className: 'dropdown-toggle',
          contents: 'Add field',
          data: {
            toggle: 'dropdown'
          }
        }),
        ui.dropdown({
          className: 'dropdown-fontsize',
          items: fieldsMenu,
          click: function (e) {
            e.preventDefault();
            const fieldSlug = $(e.target).text();
            editor.summernote('editor.insertText', ' {{' + fieldSlug + '}} ');
          },
        })
      ]);
      return button.render();
    };
  }

  function itemLinkButton(editor) {
    return function () {
      const ui = $.summernote.ui;
      const button = ui.button({
        contents: 'Item link',
        click: function () {
          const range = editor.summernote('editor.createRange');
          let selectedText = range.toString();
          if (selectedText.length < 1) selectedText = 'item-link';
          editor.summernote('editor.createLink', {text: selectedText, url: '{{_itemLink}}'});
        }
      });
      return button.render();
    };
  }

  return (
    <div className="templateEditor">
      <div id={uid}></div>
    </div>
  );
}

TemplateEditor.propTypes = {
  contentRef: PropTypes.string.isRequired,
  locale: PropTypes.string.isRequired,
  fields: PropTypes.array.isRequired,
};

export default TemplateEditor;
