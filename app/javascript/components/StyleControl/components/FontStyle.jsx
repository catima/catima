import 'es6-shim';
import React, {useEffect, useState} from 'react';

const FontStyle = (props) => {
  const {
    fontWeight,
    fontStyle,
    textDecoration,
    onChange,
  } = props

  const [bold, setBold] = useState()
  const [italic, setItalic] = useState()
  const [underline, setUnderline] = useState()

  useEffect(() => {
    setBold(fontWeight == 'bold')
    setItalic(fontStyle == 'italic')
    setUnderline(textDecoration == 'underline')
  }, [fontWeight, fontStyle, textDecoration])

  function _handleBoldChange(e) {
    let newState = !bold;
    setBold(newState);
    onChange({fontWeight: newState ? 'bold' : 'normal'});
  }

  function _handleItalicChange(e) {
    let newState = !italic;
    setItalic(newState);
    onChange({fontStyle: newState ? 'italic' : 'normal'});
  }

  function _handleUnderlineChange(e) {
    let newState = !underline;
    setUnderline(newState);
    onChange({textDecoration: newState ? 'underline' : 'none'});
  }

  return (
    <div className="btn-group" role="group" aria-label="Font style">
      <button type="button" onClick={_handleBoldChange} data-active={bold} className="btn btn-sm btn-outline-secondary">
        <b>B</b></button>
      <button type="button" onClick={_handleItalicChange} data-active={italic}
              className="btn btn-sm btn-outline-secondary"><i>I</i></button>
      <button type="button" onClick={_handleUnderlineChange} data-active={underline}
              className="btn btn-sm btn-outline-secondary"><u>U</u></button>
    </div>
  )
};

export default FontStyle;
