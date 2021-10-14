import 'es6-shim';
import React, {useEffect, useState} from 'react';
import FontMenu from './FontMenu';
import FontSize from './FontSize';
import FontStyle from './FontStyle';
import FontColorButton from './FontColorButton';
import FontExample from './FontExample';

const StyleControl = (props) => {
  const {
    element,
    input
  } = props


  const [isLoading, setIsLoading] = useState(true)
  const [color, setColor] = useState(false)
  const [backgroundColor, setBackgroundColor] = useState(false)
  const [state, setState] = useState({
    fontFamily: "",
    fontSize: "",
    fontWeight: "",
    fontStyle: "",
    textDecoration: "",
    color: '',
    backgroundColor: ''
  })

  useEffect(() => {
    const d = getData()
    setState($.extend(
      {
        fontFamily: '', 'fontSize': '',
        fontWeight: 'normal',
        fontStyle: 'normal',
        textDecoration: 'none',
      },
      d
    ))
    if (d && d.color) {
      setColor(d.color)
    }

    if (d && d.backgroundColor) {
      setBackgroundColor(d.backgroundColor)
    }
    setIsLoading(false)
  }, [])

  function getData() {
    const value = getInput().val();
    if (value === '') {
      return {};
    }
    const v = JSON.parse(value);
    return (element ? v[element] : v);
  }

  function setData(d) {
    const dobj = $.extend(getData(), d);
    let s = JSON.parse(getInput().val() || {});
    if (element) {
      s[element] = dobj;
    } else {
      s = dobj
    }
    getInput().val(JSON.stringify(s));
  }

  function getInput() {
    return $(input);
  }

  function _handleChange(d) {
    let filteredD = Object.fromEntries(Object.entries(d).filter(([_, v]) => (v != null && v != '')));
    console.log({...state, ...filteredD})
    setState({...state, ...filteredD});
    setData(d);
  }

  function _handleColorChange(d) {
    setColor(d)
    setData({color: d});
  }

  function _handleBackgroundColorChange(d) {
    setBackgroundColor(d)
    setData({backgroundColor: d});
  }

  if (isLoading) return ''

  return (
    <div>
      <FontMenu value={state.fontFamily} onChange={_handleChange}/>
      <FontSize value={state.fontSize} onChange={_handleChange}/>
      <FontStyle
        fontWeight={state.fontWeight}
        fontStyle={state.fontStyle}
        textDecoration={state.textDecoration}
        onChange={_handleChange}
      />
      <FontColorButton
        elem="color"
        name="Font color:"
        value={color}
        onChange={_handleColorChange}
      />
      <FontColorButton
        elem="backgroundColor"
        name="Background color:"
        value={backgroundColor}
        onChange={_handleBackgroundColorChange}
      />
      <FontExample
        fontFamily={state.fontFamily}
        fontSize={state.fontSize}
        fontWeight={state.fontWeight}
        fontStyle={state.fontStyle}
        textDecoration={state.textDecoration}
        color={color}
        backgroundColor={backgroundColor}
      />

    </div>
  );
};

export default StyleControl;
