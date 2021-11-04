import Quill from 'quill';

let Embed = Quill.import('blots/embed');

class Footnote extends Embed {
  static create(value) {
    let node = super.create(value);
    node.setAttribute('data-note', value);
    return node;
  }

  static value(node) {
    return node.getAttribute('data-note');
  }
};

Footnote.blotName = 'footnote';
Footnote.className = 'footnote';
Footnote.tagName = 'span';

Quill.register(Footnote);

export default Footnote;
