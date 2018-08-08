import 'es6-shim';
import PropTypes from 'prop-types';
import React from 'react';
import L from "leaflet";
import "leaflet.path.drag";
import "leaflet-editable";

class GeoBounds extends React.Component {
  static propTypes = {
    bounds: PropTypes.object
  };

  constructor(props){
    super(props);
    this.bounds = this.bbox();
    this.mapId = 'geo-bounds-map';
    this.map = null;
    this.state = {
      mapHeight: 300
    };
  }

  bbox(){
    let field_bounds = this.props.bounds;
    let bounds = [[],[]];

    if (field_bounds.xmin) bounds[0][1] = field_bounds.xmin;
    if (field_bounds.ymin) bounds[0][0] = field_bounds.ymin;
    if (field_bounds.xmax) bounds[1][1] = field_bounds.xmax;
    if (field_bounds.ymax) bounds[1][0] = field_bounds.ymax;

    return bounds;
  }

  createMap(){
    this.map = L.map(this.mapId, {editable: true}).fitBounds(this.bounds, {padding: [10,10]});
    L.tileLayer('http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '',
      maxZoom: 19
    }).addTo(this.map);
  }

  drawBounds(){
    let boundsRect = L.rectangle(this.bounds, {weight: 2, draggable: true}).addTo(this.map);
    boundsRect.enableEdit();

    this.boundsEvent(boundsRect);
  }

  boundsEvent(boundsRect){
    this.map.on('editable:editing', function(_){
      let bnds = boundsRect.getBounds();
      let boundsValue = {
        xmin: bnds.getWest(), xmax: bnds.getEast(),
        ymin: bnds.getSouth(), ymax: bnds.getNorth()
      };
      document.getElementById('field_bounds').value = JSON.stringify(boundsValue);
    });
  }

  componentDidMount(){
    this.createMap();
    this.drawBounds();
  }

  render(){
    return (
      <div id={this.mapId} style={{height: this.state.mapHeight}}>map</div>
    );
  }
};

export default GeoBounds;
