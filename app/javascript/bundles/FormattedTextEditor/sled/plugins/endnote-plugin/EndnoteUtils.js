export const hasMark = value => value.marks.some(mark => mark.type === 'endnote')

export const endnoteMarkStrategy = change => change
  .toggleMark('endnote')
  .focus()
