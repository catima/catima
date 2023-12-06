import 'es6-shim';
import PropTypes from "prop-types";
import React, {useState, useEffect} from 'react';
import ReactCrop from 'react-image-crop';
import Translations from '../../Translations/components/Translations';

const ThumbnailControl = (props) => {
  const {
    srcRef: srcRefProps,
    srcId,
    multiple: multipleProps,
  } = props

  const _id = srcId + '_thumbnail_control';
  const multiple = multipleProps || false;

  const [src, setSrc] = useState(false)
  const [controlClass, setControlClass] = useState((!src || src.length === 0) ? 'hide' : 'show')
  const [crop, setCrop] = useState((!src || src.length === 0) ? {x: 0, y: 0} : $.extend(src[0].crop || {x: 0, y: 0}, {aspect: 1}))
  const [modalClass, setModalClass] = useState('hide')
  const [img, setImg] = useState((!src || src.length === 0) ? '' : '/' + src[0].path)
  const [state, setState] = useState()
  const [srcRef, setSrcRef] = useState(srcRefProps)

  useEffect(() => {
    setSrc(_loadSrc())
  }, [])

  useEffect(() => {
    setControlClass((!src || src.length === 0) ? 'hide' : 'show')
    setCrop((!src || src.length === 0) ? {x: 0, y: 0} : $.extend(src[0].crop || {x: 0, y: 0}, {aspect: 1}))
    setImg((!src || src.length === 0) ? '' : '/' + src[0].path)
  }, [src])

  function _loadSrc() {
    const d = document.getElementById(srcRef).innerText;
    try {
      const j = JSON.parse(d);
      return $.isArray(j) ? j : [j,];
    } catch (e) {
      return [];
    }
  }

  function _saveSrc(src) {
    const s = JSON.stringify(src);
    document.getElementById(srcRef).innerText = s;
  }

  function _onChange(crop) {
    crop.aspect = 1;
    setState({crop});
    const src = _loadSrc();
    src[0].crop = crop;
    _saveSrc(src);
  }

  function _toggleModal(e) {
    e.preventDefault();
    if (modalClass === 'hide') {
      setModalClass('show');
    } else {
      setModalClass('hide');
    }
  }

  return (
    <div id={_id} className={controlClass}>
      <span
        className="btn btn-outline-secondary mb-1"
        onClick={_toggleModal}>
        {Translations.messages['catalog_admin.fields.date_time_option_inputs.define_thumbnail']}
      </span>
      <div className={modalClass}>
        <ReactCrop
          {...state}
          onChange={_onChange}
          src={img}
        />
      </div>
    </div>
  )
}

ThumbnailControl.propTypes = {
  srcRef: PropTypes.string.isRequired,
  srcId: PropTypes.string.isRequired,
}

export default ThumbnailControl;
