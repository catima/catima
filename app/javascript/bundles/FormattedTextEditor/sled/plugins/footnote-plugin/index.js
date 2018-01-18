//
// Rendering
//
import FootnoteMark from './FootnoteMark'

//
// Keyboard
//
import FootnoteKeyboardShortcut from './FootnoteKeyboardShortcut'

//
// External
//
import * as FootnoteUtils from './FootnoteUtils'
import FootnoteButton from './FootnoteButton'


const FootnotePlugin = options => ({
  onKeyDown(...args) {
    return FootnoteKeyboardShortcut(...args)
  },
})

export {
  FootnotePlugin,
  FootnoteMark,
  FootnoteKeyboardShortcut,
  FootnoteUtils,
  FootnoteButton,
}
