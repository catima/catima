import React from 'react'
import FontAwesome from 'react-fontawesome'
import classnames from 'classnames'

import { Button} from '../../components/button'
import { footnoteMarkStrategy, hasMark } from './FootnoteUtils'


const FootnoteButton = ({ value, onChange, changeState, className, style, type }) => (
  <Button
    style={style}
    type={type}
    onClick={e => onChange(footnoteMarkStrategy(value.change()))}
    className={classnames(
      'slate-footnote-plugin--button',
      { active: hasMark(value) },
      className,
    )}
  >
    Footnote
  </Button>
)

export default FootnoteButton
