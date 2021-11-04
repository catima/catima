import 'es6-shim';
import React, {useState} from 'react';
import Lightbox from 'react-image-lightbox';

const ImageViewer = (props) => {
  const {thumbnails, images, legends} = props;

  const [isOpen, setIsOpen] = useState(false)
  const [idx, setIdx] = useState(0)

  return (
    <div>
      {thumbnails.map((thumb, index) => (
        <div key={index} className="imageViewerGallery">
          <img
            className="imageViewer"
            src={thumb}
            data-idx={index}
            onClick={(e) => {
              setIdx(parseInt(e.target.getAttribute('data-idx')))
              setIsOpen(true)
            }}
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
        onCloseRequest={() => setIsOpen(false)}
        onMovePrevRequest={() => setIdx((idx + images.length - 1) % images.length)}
        onMoveNextRequest={() => setIdx((idx + 1) % images.length)}
      />
      }
    </div>
  );
}

export default ImageViewer;
