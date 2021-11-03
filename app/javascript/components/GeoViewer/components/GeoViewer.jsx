import 'es6-shim';
import PropTypes from "prop-types";
import React, {useState, useEffect} from 'react';
import axios from 'axios';
import { MapContainer, TileLayer, LayersControl, GeoJSON } from 'react-leaflet';
import MarkerClusterGroup from 'react-leaflet-markercluster';
import 'react-leaflet-markercluster/dist/styles.min.css';

const subs = ['a', 'b', 'c'];
const { BaseLayer } = LayersControl;

const GeoViewer = (props) => {
  const {
    layers,
    features,
    catalog,
    locale,
    mapHeight,
    maxBBZoom,
    noResultsMessage
  } = props

  const computedLayers = layers ? layers : []
  let computedFeatures = JSON.parse(features)

  if(computedFeatures.features) {
    computedFeatures = computedFeatures.features
  }

  computedFeatures = computedFeatures.filter(function (el) {
    return el != null;
  });

  const translations = {
    "loading": {
      fr: "Chargement...",
      en: "Loading...",
      de: "Laden...",
      it: "Carico..."
    },
    "error": {
      fr: "Erreur. Impossible de charger l'objet.",
      en: "Error. Unable to load item data.",
      de: "Fehler. Kann Element nicht laden.",
      it: "Errore. Impossibile caricare l'oggetto."
    }
  };

  const plainBlueMarker = L.icon({
    iconUrl: '/icons/plain-blue-marker.png',
    iconSize: [25, 41],
    iconAnchor:   [12, 40],
    popupAnchor:  [0, -40]
  });

  const [mapInitialized, setMapInitialized] = useState(false)
  const [computedMapHeight, setComputedMapHeight] = useState(mapHeight ? mapHeight : 300)
  const [computedMapZoom, setComputedMapZoom] = useState( maxBBZoom ? maxBBZoom : 2)
  const [computedMapMinZoom, setComputedMapMinZoom] = useState( 1)
  const [computedMapMaxZoom, setComputedMapMaxZoom] = useState( 18)
  const [computedMaxBBZoom, setComputedMaxBBZoom] = useState( 10)
  const [map, setMap] = useState()
  const [mapElement, setMapElement] = useState()

  useEffect(() => {
    mapBecomesVisible();
  }, [mapElement])

  useEffect(() => {
    setComputedMapHeight(mapHeight ? mapHeight : 300);
  }, [mapHeight])

  function waitForMapDisplay(el){
    const observer = new MutationObserver(function(mutations) {
      mutations.forEach(function(mutationRecord) {
        mapBecomesVisible();
      });
    });
    observer.observe(el, { attributes : true, attributeFilter : ['style', 'class'] });
  }

  function mapBecomesVisible(){
    if (!mapElement || mapInitialized) return;
    const mapHideElement = isMapHidden();
    if (mapHideElement == null){
      // Map is visible. Fix the map viewport.
      setTimeout(resetMapView, 500);
      setMapInitialized(true);
    } else {
      // Map is invisible. Define an event on the element that
      // hides the map to fix the viewport once the map becomes visible.
      console.log('Map is hidden. Waiting for map to show up.');
      waitForMapDisplay(mapHideElement);
    }
  }

  /**
   * Returns the element that makes the map hidden,
   * or if the map is shown, null.
   */
  function isMapHidden(){
    const mapDiv = mapElement._container;
    if (mapDiv && getComputedStyle(mapDiv).display != 'none') {
      return _isAnyParentHidden(mapDiv);
    }
    return mapDiv;
  }

  function _isAnyParentHidden(el){
    if (el.tagName == 'BODY') return null;
    if (getComputedStyle(el.parentElement).display == 'none') return el.parentElement;
    return _isAnyParentHidden(el.parentElement);
  }

  function resetMapView() {
    const bboxVar = bbox();
    const w = bboxVar[1] - bboxVar[0], h = bboxVar[3] - bboxVar[2];
    if(mapElement) {
      mapElement.invalidateSize();
      mapElement.flyToBounds([
        [bboxVar[2] - 0.2*h, bboxVar[0] - 0.2*w],
        [bboxVar[3] + 0.2*h, bboxVar[1] + 0.2*w]
      ], { duration: 0.5, maxZoom: computedMaxBBZoom });
    }
  }

  function center(){
    const minmax = bbox();
    return [ (minmax[0] + minmax[1]) / 2, (minmax[2] + minmax[3]) / 2 ];
  }

  function bbox(){
    let coords = [];
    computedFeatures.map(function(feat, i){
      if(feat.geometry) {
        coords.push(feat.geometry.coordinates);
      } else {
        feat.map(function(f, j) {
          if (typeof f !== "undefined" && f !== null) {
            coords.push(f.geometry.coordinates);
          }
        });
      }
    });

    const minmax = _minmax(coords);
    // Check if there are non valid numbers in the minmax. If so, we return a default bbox
    if (minmax.map((a) => isNaN(a)).reduce((a, b) => a || b, false)) return [-60, 60, -120, 120];
    return minmax;
  }

  function _minmax(coords){
    if (typeof(coords) !== 'undefined' && typeof(coords[0]) === 'number') {
      return [coords[0], coords[0], coords[1], coords[1]];
    }
    return _minmaxArray(coords);
  }

  function _minmaxArray(coords){
    let xmin = null, xmax = null, ymin = null, ymax = null;
    for (let i in coords){
      let xyminmax = _minmax(coords[i]);
      if (xmin == null || xyminmax[0] < xmin) xmin = xyminmax[0];
      if (xmax == null || xyminmax[1] > xmax) xmax = xyminmax[1];
      if (ymin == null || xyminmax[2] < ymin) ymin = xyminmax[2];
      if (ymax == null || xyminmax[3] > ymax) ymax = xyminmax[3];
    }
    return [xmin, xmax, ymin, ymax];
  }

  function _pointToLayer(feature, latlng){
    return L.marker(latlng, { icon: plainBlueMarker });
  }

  const _onEachFeature = (feature, layer) => {
    if(feature.properties.id) {
      layer.on({
        click: (event) => {
          let marker = event.target;
          if (marker._popup == null) {
            marker.bindPopup(translations.loading[locale]).openPopup();
            loadPopupContent(marker, feature);
          }
        }
      });
    }
  };

  function loadPopupContent(marker, feature){
    const fid = feature.properties.id;
    let config = {
      retry: 3,
      retryDelay: 1000,
    };

    axios.get('/react/' + catalog + '/' + locale + '/items/' + fid + '.json', config)
      .then(res => {
        marker._popup.setContent(res.data.views.map_popup);
      })
      .catch(error => {
        marker._popup.setContent(
          translations.error[locale]
        );
        console.log(error.message);
      });

    // Retry failed requests
    axios.interceptors.response.use(undefined, (err) => {
      let config = err.config;
      if(!config || !config.retry) return Promise.reject(err);
      config.__retryCount = config.__retryCount || 0;
      if(config.__retryCount >= config.retry) {
        return Promise.reject(err);
      }
      config.__retryCount += 1;
      let backoff = new Promise(function(resolve) {
        setTimeout(function() {
          resolve();
        }, config.retryDelay || 1);
      });
      return backoff.then(function() {
        return axios(config);
      });
    });
  }

  function renderLayer() {
    // Create map layers
    let layers;
    if (computedLayers.length === 1) {
      layers = <TileLayer
        subdomains={ subs }
        attribution={ computedLayers[0].attribution }
        url={ computedLayers[0].value }
      />
    } else if (computedLayers.length > 1) {
      layers = <LayersControl position="topright" collapsed={ true }>
        { computedLayers.map((layer, i) =>
          <BaseLayer key={ i } checked={ i === 0 } name={ layer.label }>
            <TileLayer
              subdomains={ subs }
              attribution={ layer.attribution }
              url={ layer.value }
            />
          </BaseLayer>
        )}
      </LayersControl>
    } else {
      layers = <TileLayer
        attribution='Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors'
        url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
        subdomains={ subs }
        attributionUrl='https://www.openstreetmap.org/copyright'
      />
    }

    return layers;
  }

  function renderMarkers() {
    // Create map markers
    return computedFeatures.map((feat, i) =>
      <GeoJSON key={ i } data={ feat } pointToLayer={ _pointToLayer } onEachFeature={ _onEachFeature } />
    );
  }

  return (
    <div className="geoViewer" style={{height: computedMapHeight}}>
      <MapContainer center={ center() } zoom={ computedMapZoom } zoomControl={ true } minZoom={ computedMapMinZoom } maxZoom={ computedMapMaxZoom }
                    whenCreated={ mapInstance => { setMapElement(mapInstance) } }>
        { (computedFeatures.length === 0) &&
        <div className="messageBox">
          <div className="message"><i className="fa fa-info-circle"></i> { noResultsMessage }</div>
        </div>
        }
        { renderLayer() }
        <MarkerClusterGroup showCoverageOnHover={ true }>
          { renderMarkers() }
        </MarkerClusterGroup>
      </MapContainer>
    </div>
  );
}

GeoViewer.propTypes = {
  features: PropTypes.string.isRequired,
  layers: PropTypes.array,
  mapHeight: PropTypes.number,
  catalog: PropTypes.string.isRequired,
  locale: PropTypes.string.isRequired
};

export default GeoViewer;
