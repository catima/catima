import 'es6-shim';
import PropTypes from 'prop-types';
import React, {useState, useEffect} from 'react';

const TranslatedTextField = (props) => {
  const {
    updateMenuItem,
    input: inputProps,
    locales: localesProps,
    disabled
  } = props

  const [input, setInput] = useState(inputProps)
  const [locales, setLocales] = useState(localesProps)
  const [initVal, setInitVal] = useState()
  const [value, setValue] = useState()
  const [state, setState] = useState({disabled: disabled ? 'disabled' : ''});

  useEffect(() => {
    setValue(_inputValue())
    let initialValue = {};
    localesProps.forEach(l => {
      initialValue[l] = ''
    })
    setInitVal(initialValue)
  }, [])

  function _inputValue() {
    let val = document.getElementById(input).value;
    if (val == '' || val == null || val == '{}') {
      return function () {
        let initialValue = {};
        localesProps.forEach(l => {
          initialValue[l] = ''
        })
        return initialValue
      }();
    }
    return JSON.parse(val);
  }

  function _save(v) {
    document.getElementById(input).value = JSON.stringify(v);
    if(updateMenuItem){
      updateMenuItemsDisabled(v)
    }
  }

  function updateMenuItemsDisabled(v) {
    let menu_item_item_type_id = document.getElementById('menu_item_item_type_id')
    let menu_item_page_id = document.getElementById('menu_item_page_id')
    if (menu_item_item_type_id) {
      if (JSON.stringify(orderObjectKeys(v)) == JSON.stringify(orderObjectKeys(initVal)) || JSON.stringify(orderObjectKeys(v)) === '{}') {
        menu_item_item_type_id.removeAttribute('disabled')
      } else {
        menu_item_item_type_id.setAttribute('disabled', 'disabled')
      }
    }
    if (menu_item_page_id) {
      if (JSON.stringify(orderObjectKeys(v)) == JSON.stringify(orderObjectKeys(initVal)) || JSON.stringify(orderObjectKeys(v)) === '{}') {
        menu_item_page_id.removeAttribute('disabled')
      } else {
        menu_item_page_id.setAttribute('disabled', 'disabled')
      }
    }
  }

  function orderObjectKeys(o) {
    return Object.keys(o).sort().reduce(
      (obj, key) => {
        obj[key] = o[key];
        return obj;
      },
      {}
    );
  }

  function _handleChange(e) {
    const locale = e.target.getAttribute('data-locale');
    let v = value
    v[locale] = e.target.value;
    setValue(v)
    setState({...state, name: e.target.value});
    _save(v);
  }

  if (!value) return ''
  return (
    <div className="translatedTextField form-group">
      {locales.map((locale, i) =>
        (
          <div key={i} className="input-group">
            <div className="input-group-prepend"><span className="input-group-text">{locale}</span></div>
            <input className="form-control" data-locale={locale} type="text" value={value[locale]}
                   onChange={_handleChange} disabled={state.disabled}/>
          </div>
        )
      )}
    </div>
  );
}

TranslatedTextField.propTypes = {
  input: PropTypes.string.isRequired,
  locales: PropTypes.array.isRequired,
}

export default TranslatedTextField;
