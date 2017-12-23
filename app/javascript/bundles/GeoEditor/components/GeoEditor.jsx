import 'es6-shim';
import PropTypes from 'prop-types';
import React from 'react';
import { Map, TileLayer, FeatureGroup, Marker } from 'react-leaflet';
import { EditControl } from 'react-leaflet-draw';

const subs = ['a', 'b', 'c'];
const fc = {
  type: "FeatureCollection",
  features: [{
    type: "Feature",
    properties: {},
    geometry: {
      type: "Point",
      coordinates: [5.0, 47.0]
    }
  }]
};

class GeoEditor extends React.Component {

  static propTypes = {
    input: PropTypes.string.isRequired,
  };

  constructor(props){
    super(props);
    this.input = this.props.input;
    const obj = $(this.input).val();
    this.fc = JSON.parse((obj == '' || obj == null) ? '{}' : obj);
    this.state = {
      mapHeight: 300,
    };

    this.onChanged = this._onChanged.bind(this);
    this.onMounted = this._onMounted.bind(this);
  }

  _features(){
    return this.fc.features || [];
  }

  _onMounted(e){
    this._map = e._map;
  }

  _onChanged(e){
    const lg = this._layerGroup(this._map);
    this._save(lg.toGeoJSON());
  }

  _save(fc){
    $(this.input).val(JSON.stringify(fc));
  }

  _layerGroup(map){
    window.M = map;
    const layers = map._layers;
    for (let i in layers){
      if (typeof(layers[i]._layers) !== 'undefined') return layers[i];
    }
  }

  // Returns the coordinates of the feature.
  _coords(feat){
    return [feat.geometry.coordinates[1], feat.geometry.coordinates[0]];
  }

  render(){
    return (
      <div className="geoEditor" style={{height: this.state.mapHeight}}>
        <Map center={[47, 5]} zoom={2} zoomControl={true}>
          <TileLayer
            attribution='Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors'
            url="http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
            subdomains={subs}
          />
          <FeatureGroup>
            <EditControl
              position='topright'
              onMounted={this.onMounted}
              onEdited={this.onChanged}
              onCreated={this.onChanged}
              onDeleted={this.onChanged}
              draw={{
                rectangle: false,
                circle: false,
                circlemarker: false,
                polygon: false,
                polyline: false,
              }}
            />
            {this._features().map((feat, i) =>
              <Marker key={i} position={this._coords(feat)} />
            )}
          </FeatureGroup>
        </Map>
      </div>
    );
  }

};

export default GeoEditor;
