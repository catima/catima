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
    this.legend = props.legend;
    const src = this._loadSrc();
    this.state = {
      controlClass: (src.length == 0) ? 'hide' : 'show',
      crop: (src.length == 0) ? {x: 0, y: 0} : $.extend(src[0].crop || {x: 0, y: 0}, {aspect: 1}),
      cropModalClass: 'hide',
      legendModalClass: 'hide',
      img: (src.length == 0) ? '' : '/'+src[0].path,
      legend: (src.length == 0) ? '' : src[0].legend
    }

    this.onChangeCrop = this._onChangeCrop.bind(this);
    this.toggleModalCrop = this._toggleModalCrop.bind(this);
    this.toggleModalLegend = this._toggleModalLegend.bind(this);
    this.onChangeLegend = this._onChangeLegend.bind(this);
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

  _onChangeCrop(crop){
    this.setState({ crop });
    const src = this._loadSrc();
    src[0].crop = crop;
    this._saveSrc(src);
  }

  _onChangeLegend(element){
    this.setState({legend: element.target.value});
    const src = this._loadSrc();
    src[0].legend = element.target.value;
    this._saveSrc(src);
  }

  _toggleModalCrop(e) {
    e.preventDefault();
    if (this.state.cropModalClass == 'hide') {
      this.setState({ cropModalClass: 'show' });
      this.setState({ legendModalClass: 'hide' });
    } else {
      this.setState({ cropModalClass: 'hide' });
    }
  }

  _toggleModalLegend(e) {
    e.preventDefault();
    if (this.state.legendModalClass == 'hide') {
      this.setState({ legendModalClass: 'show' });
      this.setState({ cropModalClass: 'hide' });
    } else {
      this.setState({ legendModalClass: 'hide' });
    }
  }

  render(){
    let legendButton;
    if (this.legend) {
      legendButton = (
        <span
          className="btn btn-sm btn-default image-legend-btn"
          onClick={this.toggleModalLegend}>
          Define legend
        </span>
      )
    }
    return (
      <div id={this._id} className={this.state.controlClass}>
        <span
          className="btn btn-sm btn-default"
          onClick={this.toggleModalCrop}>
          Define thumbnail
        </span>
        { legendButton }
        <div className={this.state.cropModalClass}>
          <ReactCrop
            {...this.state}
            onChange={this.onChangeCrop}
            src={this.state.img}
          />
        </div>
        <div className={this.state.legendModalClass}>
          <input className="form-control image-legend-input"
             placeholder="Add legend here"
             type="text"
             onChange={this.onChangeLegend}
             value={this.state.legend}
          />
        </div>
      </div>
    )
  }
}

export default ThumbnailControl;
