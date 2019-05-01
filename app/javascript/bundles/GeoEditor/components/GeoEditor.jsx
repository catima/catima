import 'es6-shim';
import PropTypes from 'prop-types';
import React from 'react';
import L from 'leaflet';
import uuid from 'uuid';

const subs = ['a', 'b', 'c'];

class GeoEditor extends React.Component {

  static propTypes = {
    input: PropTypes.string.isRequired,
    bounds: PropTypes.object,
    layers: PropTypes.array
  };

  constructor(props){
    super(props);
    this.input = this.props.input;
    this.layers = this.props.layers ? this.props.layers : [];
    this.bounds = this.props.bounds || {xmin: -60, xmax: 60, ymin: -45, ymax: 60};
    const obj = $(this.input).val();
    this.fc = JSON.parse((obj == '' || obj == null) ? '{"type": "FeatureCollection", "features": []}' : obj);
    this.state = {
      mapHeight: 300,
      mapMinZoom: 1,
      mapMaxZoom: 18,
      selectedMarkerLatitude: '',
      selectedMarkerLongitude: '',
    };

    this.selectedMarker = null;
    this.markers = [];

    // Create unique IDs for the different DOM elements
    const editorId = uuid.v4();
    this.mapId = 'map_' + editorId;
    this.editMarkerPaneId = 'editMarkerPane_' + editorId;

    // Create marker icons
    this._createMarkerIcons();

    // Initialize the custom Leaflet control
    this._buildMarkerControl();

    this.handleChangeLatitude = this._handleChangeLatitude.bind(this);
    this.handleChangeLongitude = this._handleChangeLongitude.bind(this);
    this.deleteSelectedMarker = this._deleteSelectedMarker.bind(this);
  }

  _features(){
    return this.fc.features || [];
  }

  _bbox(){
    const features = this._features();
    if (features.length == 0) return [[this.bounds.ymin, this.bounds.xmin], [this.bounds.ymax, this.bounds.xmax]];
    let bbox = {ymin: 90, xmin: 180, ymax: -90, xmax: -180};
    for (let i=0; i < features.length; i++){
      let c = features[i].geometry.coordinates;
      if (c[0] < bbox.xmin) bbox.xmin = c[0];
      if (c[1] < bbox.ymin) bbox.ymin = c[1];
      if (c[0] > bbox.xmax) bbox.xmax = c[0];
      if (c[1] > bbox.ymax) bbox.ymax = c[1];
    }
    let xext = (bbox.xmax - bbox.xmin) / 2;
    let yext = (bbox.ymax - bbox.ymin) / 2;
    if (xext < 0.0001) xext = 0.3;
    if (yext < 0.0001) yext = 0.3;
    bbox.xmin -= xext; bbox.xmax += xext;
    bbox.ymin -= yext; bbox.ymax += xext;
    return [[bbox.ymin, bbox.xmin], [bbox.ymax, bbox.xmax]];
  }

  _writeFeatures(){
    let newFeatures = [];
    for (let i=0; i < this.markers.length; i++){
      let pos = this.markers[i].getLatLng();
      newFeatures.push({
        type: "Feature",
        geometry: {
          type: "Point",
          coordinates: [pos.lng, pos.lat]
        },
        properties: {}
      })
    }
    this.fc.features = newFeatures;
    this._save(this.fc);
  }

  _save(fc){
    $(this.input).val(JSON.stringify(fc));
  }

  // Returns the coordinates of the feature.
  _coords(feat){
    return [feat.geometry.coordinates[1], feat.geometry.coordinates[0]];
  }

  _addMarkersFromFeatureCollection(){
    const feats = this._features();
    for (let i=0; i < feats.length; i++){
      let m = L.marker(this._coords(feats[i]), { icon: this.markerIconNormal, draggable: true }).addTo(this._map);
      this._initMarker(m);
      this.markers.push(m);
    }
  }

  _createMarkerIcons(){
    this.markerIconNormal = L.icon({
      iconUrl: '/icons/circle-marker.png',
      iconSize: [24, 24],
      iconAnchor: [12, 12],
      popupAnchor: [-3, -3],
    });

    this.markerIconSelected = L.icon({
      iconUrl: '/icons/circle-marker-selected.png',
      iconSize: [24, 24],
      iconAnchor: [12, 12],
      popupAnchor: [-3, -3],
    });
  }

  // Builds the create marker control
  _buildMarkerControl() {
    const self = this;
    L.Control.CreateMarkerControl = L.Control.extend({
      onAdd: function(map){
        const container = L.DomUtil.create('div', 'leaflet-create-marker');
        L.DomEvent
          .on(container, 'click', function(e){
            e.stopPropagation();
            e.preventDefault();
            self._createNewMarker();
          });
        return container;
      },
      onRemove: function(map){}
    });

    L.control.createMarkerControl = function(opts){
      return new L.Control.CreateMarkerControl(opts);
    }
  }

  _initMarker(m){
    const self = this;
    m.on('click', function(e){
      self._unselectAllMarkers();
      self._selectMarker(e.target);
    });
    m.on('drag', function(e){
      self._showMarkerEditPane(e.target);
    });
    m.on('moveend', function(e){
      self._unselectAllMarkers();
      self._selectMarker(e.target);
      self._writeFeatures();
    });
  }

  _initLayers(map){
    if (this.layers.length === 1) {
      this.layers.forEach((layer) => {
        L.tileLayer(layer.value, {
          subdomains: subs,
          attribution: layer.attribution
        }).addTo(map);
      });
    } else if (this.layers.length > 1) {
      let baseMaps = {};

      this.layers.forEach((layer) => {
        baseMaps[layer.label] = L.tileLayer(layer.value, {
          subdomains: subs,
          attribution: layer.attribution
        });
      });

      Object.values(baseMaps)[0].addTo(map);

      L.control.layers(baseMaps, {}).addTo(map);
    } else {
      L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        subdomains: subs,
        attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors'
      }).addTo(map);
    }
  }

  _unselectAllMarkers(){
    for (var i=0; i < this.markers.length; i++) {
      this.markers[i].setIcon(this.markerIconNormal);
    }
    this.selectedMarker = null;
    this.setState({
      selectedMarkerLatitude: '',
      selectedMarkerLongitude: ''
    });
    this._hideMarkerEditPane();
  }

  _selectMarker(m){
    m.setIcon(this.markerIconSelected);
    this.selectedMarker = m;
    // Update position in direct edit control
    this._showMarkerEditPane(m);
  }

  _showMarkerEditPane(m){
    const pos = m.getLatLng();
    this.setState({
      selectedMarkerLatitude: pos.lat.toFixed(8),
      selectedMarkerLongitude: pos.lng.toFixed(8)
    })
    document.getElementById(this.editMarkerPaneId).style.display = 'block';
  }

  _hideMarkerEditPane(){
    document.getElementById(this.editMarkerPaneId).style.display = 'none';
  }

  _updatePositionOfSelectedMarker(){
    if (this.selectedMarker == null) return;
    let lat = parseFloat(this.state.selectedMarkerLatitude);
    let lng = parseFloat(this.state.selectedMarkerLongitude);
    if (isNaN(lat) || isNaN(lng)) return;
    this.selectedMarker.setLatLng([lat, lng]);
    this._writeFeatures();
  }

  _handleChangeLatitude(e){
    this.setState({selectedMarkerLatitude: e.target.value});
    this._updatePositionOfSelectedMarker();
  }

  _handleChangeLongitude(e){
    this.setState({selectedMarkerLongitude: e.target.value});
    this._updatePositionOfSelectedMarker();
  }

  _createNewMarker(){
    const m = L.marker(this._newMarkerPostion(), { icon: this.markerIconNormal, draggable: true }).addTo(this._map);
    this.markers.push(m);
    this._initMarker(m);
    this._unselectAllMarkers();
    this._selectMarker(m);
    this._writeFeatures();
  }

  // Returns the position of the new marker to create.
  // Currently this is a random position within the central part of the current view.
  // There is no overlay check implemented as it can be computationally quite expensive.
  _newMarkerPostion(){
    let bbox = this._map.getBounds();
    const xr = Math.random(), yr = Math.random();
    const xext = bbox.getEast() - bbox.getWest();
    const yext = bbox.getNorth() - bbox.getSouth();
    const x = (xext / 2.0) * xr + bbox.getWest() + (xext / 4.0);
    const y = (yext / 2.0) * yr + bbox.getSouth() + (yext / 4.0);
    return [y, x];
  }

  _deleteSelectedMarker(){
    if (this.selectedMarker == null) return;
    this.selectedMarker.remove();
    const idx = this.markers.indexOf(this.selectedMarker);
    if (idx > -1) this.markers.splice(idx, 1);
    this._unselectAllMarkers();
    this._writeFeatures();
  }

  componentDidMount() {
    const self = this;
    this._map = L.map(this.mapId, {
      minZoom: this.state.mapMinZoom,
      maxZoom: this.state.mapMaxZoom
    }).setView([47, 7], 7);

    // Initialize map layers & layer control if needed
    this._initLayers(this._map);

    L.control.createMarkerControl({ position: 'topleft' }).addTo(this._map);
    this._map.on('click', function(e){
      self._unselectAllMarkers();
    });

    // Add the markers for existing features
    this._addMarkersFromFeatureCollection();

    // Display all markers
    this._map.fitBounds(this._bbox());
  }

  render(){
    let markerEditPaneDisplay = 'none';
    return (
      <div className="geoEditor">
        <div id={this.mapId} style={{height: this.state.mapHeight}}></div>
        <div id={this.editMarkerPaneId} className="geo-edit-pane" style={{display: "none"}}>
          <label>Latitude: <input onKeyUp={this.handleChangeLatitude} onChange={this.handleChangeLatitude} value={this.state.selectedMarkerLatitude} /></label>
          <label>&nbsp;Longitude: <input onKeyUp={this.handleChangeLongitude} onChange={this.handleChangeLongitude} value={this.state.selectedMarkerLongitude} /></label>
          <img onClick={this.deleteSelectedMarker} src="/icons/delete-marker-white.png" />
        </div>
      </div>
    );
  }

};

export default GeoEditor;
