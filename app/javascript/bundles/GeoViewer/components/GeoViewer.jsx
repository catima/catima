import 'es6-shim';
import PropTypes from 'prop-types';
import React from 'react';
import { Map, TileLayer, LayersControl, BaseLayer, GeoJSON } from 'react-leaflet';


const subs = ['server', 'services'];


class GeoViewer extends React.Component {

  static propTypes = {
    features: PropTypes.array.isRequired,
  };

  constructor(props){
    super(props);
    this.features = this.props.features;
    this.state = {
      mapHeight: 300,
    };
  }

  componentDidMount(){
    this._map = this.refs.map.leafletElement;
    setTimeout(this.resetMapView.bind(this), 500);
    setTimeout(this.resetMapView.bind(this), 1500);
  }

  resetMapView(){
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
    const coords = this.features.map(function(feat, i){ return feat.geometry.coordinates; });
    return this._minmax(coords);
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

  render(){
    const center = this.center();
    return (
      <div className="geoViewer" style={{height: this.state.mapHeight}}>
        <Map ref="map" center={center} zoom={2} zoomControl={true}>
          <TileLayer
            attribution='Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors'
            url="//{s}.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}"
            subdomains={subs}
            minZoom={1}
            maxZoom={19}
            attribution='USGS, NOAA'
            attributionUrl='https://static.arcgis.com/attribution/World_Topo_Map'
          />
          {this.features.map((feat, i) =>
            <GeoJSON key={i} data={feat.geometry} />
          )}
        </Map>
      </div>
    );
  }
};

export default GeoViewer;
