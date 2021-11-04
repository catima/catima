import 'es6-shim';
import PropTypes from 'prop-types';
import React, {useState, useEffect} from 'react';
import L from "leaflet";
import "leaflet.path.drag";
import "leaflet-editable";

const subs = ['a', 'b', 'c'];

const GeoBounds = (props) => {
  const {
    layers: layersProps,
    bounds: boundsProps
  } = props

  const [layers, setLayers] = useState(layersProps ? layersProps : [])
  const [bounds, setBounds] = useState(bbox())
  const [mapId, setMapId] = useState('geo-bounds-map')
  const [map, setMap] = useState(null)
  const [state, setState] = useState({
    mapHeight: 300
  })

  function _initLayers(map) {
    if (layers.length === 1) {
      layers.forEach((layer) => {
        L.tileLayer(layer.value, {
          subdomains: subs,
          attribution: layer.attribution
        }).addTo(map);
      });
    } else if (layers.length > 1) {
      let baseMaps = {};
      layers.forEach((layer) => {
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

  function bbox() {
    let field_bounds = boundsProps;
    let b = [[], []];
    if (field_bounds.xmin) b[0][1] = field_bounds.xmin;
    if (field_bounds.ymin) b[0][0] = field_bounds.ymin;
    if (field_bounds.xmax) b[1][1] = field_bounds.xmax;
    if (field_bounds.ymax) b[1][0] = field_bounds.ymax;

    return b;
  }

  function createMap() {
    setMap(L.map(mapId, {editable: true}).fitBounds(bounds, {padding: [10, 10]}))
  }

  function drawBounds() {
    let boundsRect = L.rectangle(bounds, {weight: 2, draggable: true}).addTo(map);
    boundsRect.enableEdit();
    boundsEvent(boundsRect);
  }

  function boundsEvent(boundsRect) {
    map.on('editable:editing', function (_) {
      let bnds = boundsRect.getBounds();
      let boundsValue = {
        xmin: bnds.getWest(), xmax: bnds.getEast(),
        ymin: bnds.getSouth(), ymax: bnds.getNorth()
      };
      document.getElementById('field_bounds').value = JSON.stringify(boundsValue);
    });
  }

  useEffect(() => {
    createMap();
  }, [])


  useEffect(() => {
    if (map) {
      _initLayers(map);
      drawBounds();
    }
  }, [map])

  return (
    <div id={mapId} style={{height: state.mapHeight}}></div>
  );
};


GeoBounds.propTypes = {
  bounds: PropTypes.object
};

export default GeoBounds;
