import Quill from 'quill';

const Embed = Quill.import('blots/embed');

class LineBreak extends Embed {
  static value() {
    return true;
  }

  // Use a clean <br> when Quill serializes the document semantically.
  html() {
    return '<br>';
  }
}

LineBreak.blotName = 'lineBreak';
LineBreak.tagName = 'BR';

Quill.register(LineBreak);

export default LineBreak;
