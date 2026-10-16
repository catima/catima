import 'es6-shim';
import React, {useState} from 'react';
import Lightbox from 'yet-another-react-lightbox';
import Captions from 'yet-another-react-lightbox/plugins/captions';
import Zoom from 'yet-another-react-lightbox/plugins/zoom';
import 'yet-another-react-lightbox/styles.css';
import 'yet-another-react-lightbox/plugins/captions.css';

const ImageViewer = (props) => {
  const {thumbnails, images, legends} = props;

  const [isOpen, setIsOpen] = useState(false)
  const [idx, setIdx] = useState(0)

  const slides = images.map((src, i) => ({src, description: legends[i]}))

  return (
    <div>
      {thumbnails.map((thumb, index) => (
        <div key={index} className="imageViewerGallery">
          <img
            className="imageViewer"
            src={thumb}
            data-idx={index}
            alt={legends[idx]}
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
        open={isOpen}
        index={idx}
        slides={slides}
        plugins={[Captions, Zoom]}
        carousel={{finite: images.length <= 1}}
        render={images.length <= 1 ? {buttonPrev: () => null, buttonNext: () => null} : {}}
        close={() => setIsOpen(false)}
        on={{view: ({index}) => setIdx(index)}}
      />
      }
    </div>
  );
}

export default ImageViewer;
