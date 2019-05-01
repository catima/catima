import 'es6-shim';
import PropTypes from 'prop-types';
import React from 'react';
import axios from 'axios';
import { Map, TileLayer, LayersControl, GeoJSON } from 'react-leaflet';
import MarkerClusterGroup from 'react-leaflet-markercluster';
import 'react-leaflet-markercluster/dist/styles.min.css';

const subs = ['a', 'b', 'c'];
const { BaseLayer } = LayersControl;

class GeoContainerViewer extends React.Component {
  static propTypes = {
    features: PropTypes.string.isRequired,
    layers: PropTypes.array,
    mapHeight: PropTypes.number,
    catalog: PropTypes.string.isRequired,
    locale: PropTypes.string.isRequired
  };

  constructor(props){
    super(props);

    this.layers = this.props.layers ? this.props.layers : [];
    this.features = JSON.parse(this.props.features);
    this.mapHeight = this.props.mapHeight;
    this.catalog = this.props.catalog;
    this.locale = this.props.locale;

    this.translations = {
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

    this.state = {
      mapZoom: 2,
      mapMinZoom: 1,
      mapMaxZoom: 18
    };

    this._mapInitialized = false;

    this.plainBlueMarker = L.icon({
      iconUrl: '/icons/plain-blue-marker.png',
      iconSize: [25, 41],
      iconAnchor:   [12, 40],
      popupAnchor:  [0, -40]
    });

    this.pointToLayer = this._pointToLayer.bind(this);
    this.onEachFeature = this._onEachFeature.bind(this);
  }

  componentDidMount(){
    this._map = this.refs.map.leafletElement;
    this._mapElement = this.refs.map;
    this.flyToMarkersBounds();
  }

  flyToMarkersBounds() {
    const bbox = this.bbox();
    const w = bbox[1] - bbox[0], h = bbox[3] - bbox[2];
    this._map.invalidateSize();
    this._map.flyToBounds([
      [bbox[2] - 0.2*h, bbox[0] - 0.2*w],
      [bbox[3] + 0.2*h, bbox[1] + 0.2*w]
    ], { duration: 0.5, maxZoom: 10 });
  }

  center(){
    const minmax = this.bbox();
    return [ (minmax[0] + minmax[1]) / 2, (minmax[2] + minmax[3]) / 2 ];
  }

  bbox(){
    const coords = this.features.features.map(function(feat, i){ return feat.geometry.coordinates; });
    const minmax = this._minmax(coords);
    // Check if there are non valid numbers in the minmax. If so, we return a default bbox
    if (minmax.map((a) => isNaN(a)).reduce((a, b) => a || b, false)) return [-60, 60, -120, 120];
    return minmax;
  }

  _minmax(coords){
    if (typeof(coords[0]) == 'number') {
      return [coords[0], coords[0], coords[1], coords[1]];
    }
    return this._minmaxArray(coords);
  }

  _minmaxArray(coords){
    let xmin = null, xmax = null, ymin = null, ymax = null;
    for (let i in coords){
      let xyminmax = this._minmax(coords[i]);
      if (xmin == null || xyminmax[0] < xmin) xmin = xyminmax[0];
      if (xmax == null || xyminmax[1] > xmax) xmax = xyminmax[1];
      if (ymin == null || xyminmax[2] < ymin) ymin = xyminmax[2];
      if (ymax == null || xyminmax[3] > ymax) ymax = xyminmax[3];
    }
    return [xmin, xmax, ymin, ymax];
  }

  _pointToLayer(feature, latlng){
    return L.marker(latlng, { icon: this.plainBlueMarker });
  }

  _onEachFeature = (feature, layer) => {
    layer.on({
      click: (event) => {
        let marker = event.target;
        if (marker._popup == null) {
          marker.bindPopup(this.translations.loading[this.locale]).openPopup();
          this.loadPopupContent(marker, feature);
        }
      }
    });
  };

  loadPopupContent(marker, feature){
    const fid = feature.properties.id;
    const csrfToken = $('meta[name="csrf-token"]').attr('content');

    let config = {
      retry: 1,
      retryDelay: 1000,
      headers: {'X-CSRF-Token': csrfToken}
    };

    let self = this;
    axios.get('/api/v1/'+this.locale+'/catalogs/'+this.catalog+'/items/'+fid+'.json', config)
        .then(res => {
          marker._popup.setContent(res.data.views.map_popup);
        })
        .catch(error => {
          marker._popup.setContent(
              self.translations.error[self.locale]
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

  renderLayer() {
    // Create map layers
    let layers;
    if (this.layers.length === 1) {
      layers = <TileLayer
          subdomains={ subs }
          attribution={ this.layers[0].attribution }
          url={ this.layers[0].value }
      />
    } else if (this.layers.length > 1) {
      layers = <LayersControl position="topright" collapsed={ true }>
        { this.layers.map((layer, i) =>
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

  renderMarkers() {
    // Create map markers
    return this.features.features.map((feat, i) =>
        <GeoJSON key={ i } data={ feat } pointToLayer={ this.pointToLayer } onEachFeature={this.onEachFeature} />
    );
  }

  render(){
    const center = this.center();

    return (
        <div className="geoContainerViewer" style={{height: this.mapHeight}}>
          <Map ref="map" center={ center } zoom={ this.state.mapZoom } zoomControl={ true } minZoom={ this.state.mapMinZoom } maxZoom={ this.state.mapMaxZoom } >
            { this.renderLayer() }
            <MarkerClusterGroup showCoverageOnHover={ true }>
              { this.renderMarkers() }
            </MarkerClusterGroup>
          </Map>
        </div>
    );
  }
}

export default GeoContainerViewer;
