import 'es6-shim';
import PropTypes from "prop-types";
import React, {useState, useEffect} from 'react';
import ReactCrop from 'react-image-crop';
import 'react-image-crop/dist/ReactCrop.css';
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
  const [crop, setCrop] = useState(_toPercentCrop(src && src.length > 0 ? src[0].crop : null))
  const [modalClass, setModalClass] = useState('hide')
  const [img, setImg] = useState((!src || src.length === 0) ? '' : '/' + src[0].path)
  const [srcRef, setSrcRef] = useState(srcRefProps)

  useEffect(() => {
    setSrc(_loadSrc())
  }, [])

  useEffect(() => {
    setControlClass((!src || src.length === 0) ? 'hide' : 'show')
    setCrop(_toPercentCrop(src && src.length > 0 ? src[0].crop : null))
    setImg((!src || src.length === 0) ? '' : '/' + src[0].path)
  }, [src])

  // Crops are stored and consumed server-side as percentages of the image
  function _toPercentCrop(c) {
    if (!c) return undefined;
    return {unit: '%', x: c.x || 0, y: c.y || 0, width: c.width || 0, height: c.height || 0};
  }

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

  function _onChange(pixelCrop, percentCrop) {
    setCrop(percentCrop);
    const src = _loadSrc();
    src[0].crop = {...percentCrop, aspect: 1};
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
          crop={crop}
          aspect={1}
          onChange={_onChange}
        >
          <img src={img || undefined} alt="" />
        </ReactCrop>
      </div>
    </div>
  )
}

ThumbnailControl.propTypes = {
  srcRef: PropTypes.string.isRequired,
  srcId: PropTypes.string.isRequired,
}

export default ThumbnailControl;
