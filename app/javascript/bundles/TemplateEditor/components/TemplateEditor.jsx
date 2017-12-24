import 'es6-shim';
import PropTypes from 'prop-types';
import React from 'react';
import 'bootstrap/dist/css/bootstrap.css';
import 'summernote/dist/summernote.css';
import 'bootstrap/js/modal';
import 'bootstrap/js/dropdown';
import 'bootstrap/js/tooltip';
import 'bootstrap/dist/css/bootstrap.css';
import 'summernote';


const uuidv4 = require('uuid/v4');

class TemplateEditor extends React.Component {
  static propTypes = {
    contentRef: PropTypes.string.isRequired,
    locale: PropTypes.string.isRequired,
    fields: PropTypes.array.isRequired,
  };

  constructor(props){
    super(props);
    this.uid = `summernote-${uuidv4()}`;
    this.updateContent = this._updateContent.bind(this);
    this.options = {
      minHeight: 150,
      toolbar: [
        ['style', ['bold', 'italic', 'underline', 'clear']],
        ['font', ['strikethrough', 'superscript', 'subscript']],
        ['fontsize', ['fontsize']],
        ['color', ['color']],
        ['para', ['ul', 'ol', 'paragraph']],
        ['height', ['height']],
        ['insert', ['picture', 'link', 'table', 'hr']],
        ['misc', ['codeview']],
        ['templateEditor', ['fieldsMenu', 'itemLinkButton']]
      ],
      buttons: {
        fieldsMenu: this.fieldsMenu(this.props.fields),
        itemLinkButton: this.itemLinkButton(),
      },
      callbacks: {
        onChange: this.updateContent
      }
    };
  }

  _loadContent(){
    let v = JSON.parse(document.getElementById(this.props.contentRef).value || {});
    return v[this.props.locale] || '';
  }

  _updateContent(html){
    const el = document.getElementById(this.props.contentRef)
    let v = JSON.parse(el.value || {});
    v[this.props.locale] = html;
    el.value = JSON.stringify(v);
  }

  componentDidMount(){
    const html = this._loadContent();
    this.editor = $(`#${this.uid}`);
    this.editor.summernote(this.options);
    this.editor.summernote('code', html);
    $('.note-link-popover').css('display', 'none');
  }

  componentWillUnmount(){
    this.editor.summernote('destroy');
  }

  fieldsMenu(fields){
    return function(context){
      const ui = $.summernote.ui;
      let fieldsMenu = [];
      for (let i in fields){
        let f = fields[i];
        fieldsMenu.push(`<${f.type}Field>${f.slug}</${f.type}Field>`);
      }
      const button = ui.buttonGroup([
        ui.button({
          className: 'dropdown-toggle',
          contents: 'Add field <i class="fa fa-caret-down"></i>',
          data: {
            toggle: 'dropdown'
          }
        }),
        ui.dropdown({
          className: 'dropdown-fontsize',
          items: fieldsMenu,
          click: function(e){
            e.preventDefault();
            const fieldSlug = $(e.target).text();
            context.invoke('editor.insertText', ' {{'+fieldSlug+'}} ');
          },
        })
      ]);
      return button.render();
    };
  }

  itemLinkButton(){
    return function(context) {
      const ui = $.summernote.ui;
      const button = ui.button({
        contents: 'Item link',
        click: function(){
          const range = context.invoke('editor.createRange');
          let selectedText = range.toString();
          if (selectedText.length < 1) selectedText = 'item-link';
          context.invoke('editor.createLink', {text: selectedText, url: '{{_itemLink}}'});
        }
      });
      return button.render();
    };
  }

  render(){
    return (
      <div className="templateEditor">
        <div id={this.uid}></div>
      </div>
    );
  }
}

export default TemplateEditor;
