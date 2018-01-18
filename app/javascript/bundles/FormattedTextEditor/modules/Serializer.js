import React from 'react'
import Html from 'slate-html-serializer'


const BLOCK_TAGS = {
  p: 'paragraph',
  h1: 'h1',
  h2: 'h2',
  h3: 'h3',
  h4: 'h4',
  h5: 'h5',
  h6: 'h6',
  h7: 'h7',
  a: 'link',
  li: 'list-item',
  ol: 'ordered-list',
  ul: 'unordered-list',
}

const MARK_CLASSES = {
  footnote: 'footnote',
  endnote: 'endnote',
}

const MARK_TAGS = {
  em: 'italic',
  strong: 'bold',
  u: 'underline',
  s: 'strikethrough',
}

const rules = [
  {
    deserialize(el, next) {
      if (el.tagName.toLowerCase() == 'a') {
        return {
          object: 'inline',
          type: 'link',
          data: { href: el.getAttribute('href') },
          nodes: next(el.childNodes)
        };
      }

      const type = BLOCK_TAGS[el.tagName.toLowerCase()]
      if (!type) return;
      return {
        object: 'block',
        type: type,
        nodes: next(el.childNodes)
      }
    },
    serialize(obj, children) {
      if (obj.object != 'block') return
      switch (obj.type) {
        case 'paragraph': return <p>{children}</p>
        case 'h1': return <h1>{children}</h1>
        case 'h2': return <h2>{children}</h2>
        case 'h3': return <h3>{children}</h3>
        case 'h4': return <h4>{children}</h4>
        case 'h5': return <h5>{children}</h5>
        case 'h6': return <h6>{children}</h6>
        case 'h7': return <h7>{children}</h7>
        case 'list-item': return <li>{children}</li>
        case 'ordered-list': return <ol>{children}</ol>
        case 'unordered-list': return <ul>{children}</ul>
      }
    }
  },
  // Handle marks...
  {
    deserialize(el, next) {
      // Finding marks first based on tag name and then on class name.
      let type = MARK_TAGS[el.tagName.toLowerCase()];
      if (!type) {
        if (el.className) {
          type = MARK_CLASSES[el.className.toLowerCase()];
        }
      }
      if (!type) return;
      return {
        object: 'mark',
        type: type,
        nodes: next(el.childNodes)
      };
    },
    serialize(obj, children) {
      if (obj.object != 'mark') return
      switch (obj.type) {
        case 'bold': return <strong>{children}</strong>
        case 'italic': return <em>{children}</em>
        case 'underline': return <u>{children}</u>
        case 'footnote': return <span className="footnote">{children}</span>
        case 'endnote': return <span className="endnote">{children}</span>
      }
    }
  },
  // Handle links...
  {
    deserialize(el, next){
      if (el.tagName != 'a') return;
      return {
        object: 'inline',
        type: 'link',
        data: { href: el.getAttribute('href') },
        nodes: next(el.childNodes)
      };
    },
    serialize(obj, children){
      if (obj.object != 'inline') return;
      switch (obj.type) {
        case 'link':
          const url = obj.data.get('href');
          return <a href={url} target="_blank">{children}</a>
      }
    }
  }
]


const Serializer = new Html({ rules })

export default Serializer
