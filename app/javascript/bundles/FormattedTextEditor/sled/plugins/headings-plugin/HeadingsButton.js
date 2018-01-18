import React from 'react'
import classnames from 'classnames'

import { Button } from '../../components/button'
import {
  h1NodeStrategy, hasH1Node,
  h2NodeStrategy, hasH2Node,
  h3NodeStrategy, hasH3Node,
  h4NodeStrategy, hasH4Node,
  h5NodeStrategy, hasH5Node,
  h6NodeStrategy, hasH6Node,
  h7NodeStrategy, hasH7Node,
  paragraphNodeStrategy, hasParagraphNode
} from './HeadingsUtils'



const ParagraphButton = ({ value, onChange, changeState, className, style, type }) => (
  <Button
    style={style}
    type={type}
    onClick={e => onChange(paragraphNodeStrategy(value.change()))}
    className={classnames(
      'slate-paragraph-plugin--button',
      { active: hasParagraphNode(value) },
      className,
    )}
  >
    Text
  </Button>
)


const H1Button = ({ value, onChange, changeState, className, style, type }) => (
  <Button
    style={style}
    type={type}
    onClick={e => onChange(h1NodeStrategy(value.change()))}
    className={classnames(
      'slate-headings-plugin--button',
      { active: hasH1Node(value) },
      className,
    )}
  >
    H1
  </Button>
)

const H2Button = ({ value, onChange, changeState, className, style, type }) => (
  <Button
    style={style}
    type={type}
    onClick={e => onChange(h2NodeStrategy(value.change()))}
    className={classnames(
      'slate-headings-plugin--button',
      { active: hasH2Node(value) },
      className,
    )}
  >
    H2
  </Button>
)

const H3Button = ({ value, onChange, changeState, className, style, type }) => (
  <Button
    style={style}
    type={type}
    onClick={e => onChange(h3NodeStrategy(value.change()))}
    className={classnames(
      'slate-headings-plugin--button',
      { active: hasH3Node(value) },
      className,
    )}
  >
    H3
  </Button>
)

const H4Button = ({ value, onChange, changeState, className, style, type }) => (
  <Button
    style={style}
    type={type}
    onClick={e => onChange(h4NodeStrategy(value.change()))}
    className={classnames(
      'slate-headings-plugin--button',
      { active: hasH4Node(value) },
      className,
    )}
  >
    H4
  </Button>
)

const H5Button = ({ value, onChange, changeState, className, style, type }) => (
  <Button
    style={style}
    type={type}
    onClick={e => onChange(h5NodeStrategy(value.change()))}
    className={classnames(
      'slate-headings-plugin--button',
      { active: hasH5Node(value) },
      className,
    )}
  >
    H5
  </Button>
)

const H6Button = ({ value, onChange, changeState, className, style, type }) => (
  <Button
    style={style}
    type={type}
    onClick={e => onChange(h6NodeStrategy(value.change()))}
    className={classnames(
      'slate-headings-plugin--button',
      { active: hasH6Node(value) },
      className,
    )}
  >
    H6
  </Button>
)

const H7Button = ({ value, onChange, changeState, className, style, type }) => (
  <Button
    style={style}
    type={type}
    onClick={e => onChange(h7NodeStrategy(value.change()))}
    className={classnames(
      'slate-headings-plugin--button',
      { active: hasH7Node(value) },
      className,
    )}
  >
    H7
  </Button>
)

export { ParagraphButton, H1Button, H2Button, H3Button, H4Button, H5Button, H6Button, H7Button }
