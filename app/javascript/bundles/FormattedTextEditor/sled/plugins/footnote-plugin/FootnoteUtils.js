export const hasMark = value => value.marks.some(mark => mark.type === 'footnote')

export const footnoteMarkStrategy = change => change
  .toggleMark('footnote')
  .focus()
