import Quill from 'quill';

let Embed = Quill.import('blots/embed');

class Endnote extends Embed {
  static create(value) {
    let node = super.create(value);
    node.setAttribute('data-note', value);
    return node;
  }

  static value(node) {
    return node.getAttribute('data-note');
  }
};

Endnote.blotName = 'endnote';
Endnote.className = 'endnote';
Endnote.tagName = 'span';

Quill.register(Endnote);

export default Endnote;
