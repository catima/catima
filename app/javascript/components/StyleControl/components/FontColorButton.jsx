import 'es6-shim';
import React, {useEffect, useState} from 'react';

function uuidv4() {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
    let r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
    return v.toString(16);
  });
}

const FontColorButton = (props) => {
  const {
    onChange,
    name,
    value
  } = props

  const [colorInputId, setColorInputId] = useState(uuidv4())
  const [minicolor, setMinicolor] = useState()
  const [v, setV] = useState('')

  useEffect(() => {

      setMinicolor($('#' + colorInputId).minicolors({
        theme: 'bootstrap',
        change: function (value, opacity) {
          _handleChange(value);
        }
      }))
  }, [v])

  useEffect(() => {
    if (typeof v != "boolean") {
      setV(value)
      setMinicolor($('#' + colorInputId).minicolors({
        theme: 'bootstrap',
        change: function (value, opacity) {
          _handleChange(value);
        }
      }))
    }
  }, [value])

  function _handleChange(val) {
    onChange(val);
  }

  return (
    <div className="colorButtonWrapper">
      {name}
      <div className="colorButton">
        <input id={colorInputId} type="hidden" value={value} onChange={_handleChange} className="form-control"/>
      </div>
    </div>
  );
}

export default FontColorButton;
