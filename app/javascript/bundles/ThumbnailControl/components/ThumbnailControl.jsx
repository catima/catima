import 'es6-shim';
import React from 'react';
import PropTypes from 'prop-types';
import ReactCrop from 'react-image-crop';

class ThumbnailControl extends React.Component {
  static propTypes = {
    srcRef: PropTypes.string.isRequired,
    srcId: PropTypes.string.isRequired,
  };

  constructor(props){
    super(props);
    this.srcRef = props.srcRef;
    this._id = props.srcId + '_thumbnail_control';
    this.multiple = props.multiple || false;
    const src = this._loadSrc();
    this.state = {
      controlClass: (src.length == 0) ? 'hide' : 'show',
      crop: (src.length == 0) ? {x: 0, y: 0} : $.extend(src[0].crop || {x: 0, y: 0}, {aspect: 1}),
      modalClass: 'hide',
      img: (src.length == 0) ? '' : '/'+src[0].path
    }

    this.onChange = this._onChange.bind(this);
    this.toggleModal = this._toggleModal.bind(this);
  }

  _loadSrc(){
    const d = document.getElementById(this.srcRef).innerText;
    try {
      const j = JSON.parse(d);
      return $.isArray(j) ? j : [j,];
    } catch (e) {
      return [];
    }
  }

  _saveSrc(src){
    const s = JSON.stringify(src);
    document.getElementById(this.srcRef).innerText = s;
  }

  _onChange(crop){
    this.setState({ crop });
    const src = this._loadSrc();
    src[0].crop = crop;
    this._saveSrc(src);
  }

  _toggleModal(e) {
    e.preventDefault();
    if (this.state.modalClass == 'hide') {
      this.setState({ modalClass: 'show' });
    } else {
      this.setState({ modalClass: 'hide' });
    }
  }

  render(){
    return (
      <div id={this._id} className={this.state.controlClass}>
        <span
          className="btn btn-sm btn-default"
          onClick={this.toggleModal}>
          Define thumbnail
        </span>
        <div className={this.state.modalClass}>
          <ReactCrop
            {...this.state}
            onChange={this.onChange}
            src={this.state.img}
          />
        </div>
      </div>
    )
  }
}

export default ThumbnailControl;
