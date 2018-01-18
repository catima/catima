import React from 'react'
import classnames from 'classnames'

import { Button} from '../../components/button'
import { endnoteMarkStrategy, hasMark } from './EndnoteUtils'


const EndnoteButton = ({ value, onChange, changeState, className, style, type }) => (
  <Button
    style={style}
    type={type}
    onClick={e => onChange(endnoteMarkStrategy(value.change()))}
    className={classnames(
      'slate-endnote-plugin--button',
      { active: hasMark(value) },
      className,
    )}
  >
    Endnote
  </Button>
)

export default EndnoteButton
