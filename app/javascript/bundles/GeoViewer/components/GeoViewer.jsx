import 'es6-shim';
import PropTypes from 'prop-types';
import React from 'react';
import { Map, TileLayer, LayersControl, GeoJSON } from 'react-leaflet';
import MarkerClusterGroup from 'react-leaflet-markercluster';

const subs = ['a', 'b', 'c'];
const { BaseLayer } = LayersControl;

class GeoViewer extends React.Component {
  static propTypes = {
    features: PropTypes.array.isRequired,
    layers: PropTypes.array
  };

  constructor(props){
    super(props);

    this.features = this.props.features.filter(function (el) {
      return el != null;
    });

    this.layers = this.props.layers ? this.props.layers : [];

    this.state = {
      mapHeight: 300,
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
    if (typeof this.props.mapHeight !== 'undefined') {
      this.setState({mapHeight: this.props.mapHeight})
    }

    this._map = this.refs.map.leafletElement;
    this._mapElement = this.refs.map;
    this.mapBecomesVisible();
  }

  waitForMapDisplay(el){
    const self = this;
    const observer = new MutationObserver(function(mutations) {
      mutations.forEach(function(mutationRecord) {
        self.mapBecomesVisible();
      });
    });
    observer.observe(el, { attributes : true, attributeFilter : ['style', 'class'] });
  }

  mapBecomesVisible(){
    if (this._mapInitialized) return;
    const mapHideElement = this.isMapHidden();
    if (mapHideElement == null){
      // Map is visible. Fix the map viewport.
      setTimeout(this.resetMapView.bind(this), 500);
      setTimeout(this.resetMapView.bind(this), 1500);
      this._mapInitialized = true;
    } else {
      // Map is invisible. Define an event on the element that
      // hides the map to fix the viewport once the map becomes visible.
      console.log('Map is hidden. Waiting for map to show up.');
      this.waitForMapDisplay(mapHideElement);
    }
  }

  /**
   * Returns the element that makes the map hidden,
   * or if the map is shown, null.
   */
  isMapHidden(){
    const mapDiv = this._mapElement.container;
    if (getComputedStyle(mapDiv).display != 'none') {
      return this._isAnyParentHidden(mapDiv);
    }
    return mapDiv;
  }

  _isAnyParentHidden(el){
    if (el.tagName == 'BODY') return null;
    if (getComputedStyle(el.parentElement).display == 'none') return el.parentElement;
    return this._isAnyParentHidden(el.parentElement);
  }

  resetMapView(){
    const bbox = this.bbox();
    const w = bbox[1] - bbox[0], h = bbox[3] - bbox[2];
    this._map.invalidateSize();
    this._map.flyToBounds([
      [bbox[2] - 0.2*h, bbox[0] - 0.2*w],
      [bbox[3] + 0.2*h, bbox[1] + 0.2*w]
    ], { duration: 0.5, maxZoom: 13 });
  }

  center(){
    const minmax = this.bbox();
    return [ (minmax[0] + minmax[1]) / 2, (minmax[2] + minmax[3]) / 2 ];
  }

  bbox(){
    var coords = [];
    this.features.map(function(feat, i) {
      if (typeof feat.geometry === 'undefined') {
        feat.map(function(f, j) {
          if (f !== "undefined" && f !== null) { coords.push(f.geometry.coordinates); }
        });
      } else {
        coords = feat.geometry.coordinates;
      }
    });
    const minmax = this._minmax(coords);
    // Check if there are non valid numbers in the minmax. If so, we return a default bbox
    if (minmax.map((a) => isNaN(a)).reduce((a, b) => a || b, false)) return [-60, 60, -120, 120];
    return minmax;
  }

  _minmax(coords){
    if (typeof(coords) !== 'undefined' && typeof(coords[0]) === 'number') {
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

  _onEachFeature(feature, layer) {
    //On each marker, bind a popup
    if (feature.properties && feature.properties.popupContent) {
      layer.bindPopup(feature.properties.popupContent);
    }
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
    let features = this.features.map((feat, i) =>
        <GeoJSON key={ i } data={ feat } pointToLayer={ this.pointToLayer } onEachFeature={ this.onEachFeature } />
    );

    return features;
  }

  render(){
    const center = this.center();

    return (
      <div className="geoViewer" style={{height: this.state.mapHeight}}>
        <Map ref="map" center={ center } zoom={ this.state.mapZoom } zoomControl={ true } minZoom={ this.state.mapMinZoom } maxZoom={ this.state.mapMaxZoom } >
          { (this.features.length === 0) &&
            <div className="messageBox">
              <div className="message"><i className="fa fa-info-circle"></i> { this.props.noResultsMessage }</div>
            </div>
          }
          { this.renderLayer() }
          <MarkerClusterGroup showCoverageOnHover={ true }>
            { this.renderMarkers() }
          </MarkerClusterGroup>
        </Map>
      </div>
    );
  }
}

export default GeoViewer;
