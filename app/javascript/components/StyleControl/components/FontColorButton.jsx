import 'es6-shim';
import React, {useEffect, useId, useState} from 'react';

const FontColorButton = (props) => {
  const {
    onChange,
    name,
    value
  } = props

  const colorInputId = useId()
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
