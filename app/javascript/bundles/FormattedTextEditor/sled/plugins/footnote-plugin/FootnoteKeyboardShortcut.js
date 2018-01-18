import { isMod } from '../../utils/keyboard-event'
import { footnoteMarkStrategy } from './FootnoteUtils'

const FootnoteKeyboardShortcut = (event, change) => {
  if (isMod(event) && event.key === 'n') return footnoteMarkStrategy(change)
  return
}

export default FootnoteKeyboardShortcut
