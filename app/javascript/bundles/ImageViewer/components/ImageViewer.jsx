import React, { Component } from 'react';
import Lightbox from 'react-image-lightbox';
import 'react-image-lightbox/style.css';

class ImageViewer extends Component {
  constructor(props) {
    super(props);
    this.state = {
      isOpen: false,
      idx: 0,
    };
  }

  render() {
    const { idx, isOpen } = this.state;
    const { thumbnails, images, legends } = this.props;
    const thumb = thumbnails[0],
          image = images[0];
    return (
      <div>
        {thumbnails.map((thumb, index) => (
          <div key={index} className="imageViewerGallery">
            <img
              className="imageViewer"
              src={thumb}
              data-idx={index}
              onClick={(e) => this.setState({ idx: parseInt(e.target.getAttribute('data-idx')), isOpen: true })}
            />
            <br/>
            <span className="img-enlarge">Click to enlarge</span>
          </div>
        ))}
        {isOpen &&
          <Lightbox
            ariaHideApp={false}
            mainSrc={images[idx]}
            imageCaption={legends[idx]}
            nextSrc={images.length === 1 ? null : images[(idx + 1) % images.length]}
            prevSrc={images.length === 1 ? null : images[(idx + images.length - 1) % images.length]}
            onCloseRequest={() => this.setState({ isOpen: false })}
            onMovePrevRequest={() => this.setState({
              idx: (idx + images.length - 1) % images.length,
            })}
            onMoveNextRequest={() => this.setState({
              idx: (idx + 1) % images.length,
            })}
          />
        }
      </div>
    );
  }
};

export default ImageViewer;
