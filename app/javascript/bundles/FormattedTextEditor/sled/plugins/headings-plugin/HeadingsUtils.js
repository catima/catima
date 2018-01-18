export const hasParagraphNode = value => value.blocks.some(block => block.type === 'paragraph')
export const paragraphNodeStrategy = change => change
  .setBlock('paragraph')
  .focus()

export const hasH1Node = value => value.blocks.some(block => block.type === 'h1')
export const h1NodeStrategy = change => change
  .setBlock('h1')
  .focus()

export const hasH2Node = value => value.blocks.some(block => block.type === 'h2')
export const h2NodeStrategy = change => change
  .setBlock('h2')
  .focus()

export const hasH3Node = value => value.blocks.some(block => block.type === 'h3')
export const h3NodeStrategy = change => change
  .setBlock('h3')
  .focus()

export const hasH4Node = value => value.blocks.some(block => block.type === 'h4')
export const h4NodeStrategy = change => change
  .setBlock('h4')
  .focus()

export const hasH5Node = value => value.blocks.some(block => block.type === 'h5')
export const h5NodeStrategy = change => change
  .setBlock('h5')
  .focus()


export const hasH6Node = value => value.blocks.some(block => block.type === 'h6')
export const h6NodeStrategy = change => change
  .setBlock('h6')
  .focus()

export const hasH7Node = value => value.blocks.some(block => block.type === 'h7')
export const h7NodeStrategy = change => change
  .setBlock('h7')
  .focus()
