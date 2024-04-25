import 'es6-shim';
import React from 'react';

const FontSize = (props) => {
  const {
    onChange,
    value
  } = props

  function _handleChange(e) {
    onChange({fontSize: e.target.value})
  }

  return (
    <select className="form-select btn btn-sm btn-outline-secondary"
            value={value}
            onChange={_handleChange}
            style={{height: '30px', width: '70px'}}>
      <option value="">Default</option>
      <option disabled>---</option>
      <option value="7pt">7 pt</option>
      <option value="8pt">8 pt</option>
      <option value="9pt">9 pt</option>
      <option value="10pt">10 pt</option>
      <option value="11pt">11 pt</option>
      <option value="12pt">12 pt</option>
      <option value="13pt">13 pt</option>
      <option value="14pt">14 pt</option>
      <option value="16pt">16 pt</option>
      <option value="18pt">18 pt</option>
      <option value="20pt">20 pt</option>
      <option value="22pt">22 pt</option>
      <option value="24pt">24 pt</option>
      <option value="28pt">28 pt</option>
      <option value="32pt">32 pt</option>
      <option value="36pt">36 pt</option>
      <option value="40pt">40 pt</option>
      <option value="48pt">48 pt</option>
      <option value="56pt">56 pt</option>
      <option value="64pt">64 pt</option>
      <option value="72pt">72 pt</option>
      <option value="96pt">96 pt</option>
    </select>
  )
};

export default FontSize;
