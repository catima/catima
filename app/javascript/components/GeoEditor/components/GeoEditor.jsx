import 'es6-shim';
import PropTypes from 'prop-types';
import React, {useState, useEffect, useRef} from 'react';
import L from 'leaflet';
import {v4 as uuidv4} from 'uuid';

const subs = ['a', 'b', 'c'];

const GeoEditor = (props) => {
  const {
    input,
    layers: layersProps,
    bounds: boundsProps
  } = props

  const editorId = uuidv4();

  const [bounds, setBounds] = useState()
  const [layers, setLayers] = useState()
  const [fc, setFc] = useState()
  const [selectedMarker, setSelectedMarker] = useState(null)
  const [markers, setMarkers] = useState([])
  const [map, setMap] = useState()
  const [markerIconNormal, setMarkerIconNormal] = useState()
  const [markerIconSelected, setMarkerIconSelected] = useState()
  const [state, setState] = useState({
    mapHeight: 300,
    mapMinZoom: 1,
    mapMaxZoom: 18,
    selectedMarkerLatitude: '',
    selectedMarkerLongitude: '',
  })
  const [mapId, setMapId] = useState()
  const [editMarkerPaneId, setEditMarkerPaneId] = useState()

  const markersRef = useRef([])
  markersRef.current = markers

  useEffect(() => {
    setBounds(boundsProps || {xmin: -60, xmax: 60, ymin: -45, ymax: 60})
    setLayers(layersProps ? layersProps : [])
  }, [layersProps, boundsProps])

  useEffect(() => {
    const _mapId = 'map_' + editorId;
    const _editMarkerPaneId = 'editMarkerPane_' + editorId;
    setMapId(_mapId)
    setEditMarkerPaneId(_editMarkerPaneId)
  }, [])

  useEffect(() => {
    if (input) {
      let o = $(input).val()
      if (o) {
        setFc(JSON.parse((o == '' || o == null) ? '{"type": "FeatureCollection", "features": []}' : o))
      }
    }
  }, [input])

  useEffect(() => {
    if (mapId && !map) {
      setMap(L.map(mapId, {
        minZoom: state.mapMinZoom,
        maxZoom: state.mapMaxZoom
      }).setView([47, 7], 7))
    }
  }, [mapId])

  useEffect(() => {
    if (map) {
      // Initialize map layers & layer control if needed
      _initLayers(map);
      L.control.createMarkerControl({position: 'topleft'}).addTo(map);
      map.on('click', function (e) {
        _unselectAllMarkers();
      });
      // Add the markers for existing features
      _addMarkersFromFeatureCollection();
      // Display all markers
      map.fitBounds(_bbox());
    }
  }, [map])

  useEffect(() => {
    // Create marker icons
    setMarkerIconNormal(L.icon({
      iconUrl: '/icons/circle-marker.png',
      iconSize: [24, 24],
      iconAnchor: [12, 12],
      popupAnchor: [-3, -3],
    }))

    setMarkerIconSelected(L.icon({
      iconUrl: '/icons/circle-marker-selected.png',
      iconSize: [24, 24],
      iconAnchor: [12, 12],
      popupAnchor: [-3, -3],
    }))
    // Initialize the custom Leaflet control
    _buildMarkerControl();
  }, [map])

  useEffect(() => {
    _buildMarkerControl();
  }, [markerIconNormal, markerIconSelected])

  function _features() {
    return fc?.features || [];
  }

  function _bbox() {
    const features = _features();
    if (features.length == 0) return [[bounds.ymin, bounds.xmin], [bounds.ymax, bounds.xmax]];
    let bbox = {ymin: 90, xmin: 180, ymax: -90, xmax: -180};
    for (let i = 0; i < features.length; i++) {
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
    bbox.xmin -= xext;
    bbox.xmax += xext;
    bbox.ymin -= yext;
    bbox.ymax += xext;
    return [[bbox.ymin, bbox.xmin], [bbox.ymax, bbox.xmax]];
  }

  function _writeFeatures(m = false) {
    let newFeatures = [];
    let marks = m ? m : markers
    for (let i = 0; i < marks.length; i++) {
      let pos = marks[i].getLatLng();
      newFeatures.push({
        type: "Feature",
        geometry: {
          type: "Point",
          coordinates: [pos.lng, pos.lat]
        },
        properties: {}
      })
    }
    setFc({...fc, features: newFeatures})
    _save({...fc, features: newFeatures});
  }

  function _save(fc) {
    $(input).val(JSON.stringify(fc));
  }

  // Returns the coordinates of the feature.
  function _coords(feat) {
    return [feat.geometry.coordinates[1], feat.geometry.coordinates[0]];
  }

  function _addMarkersFromFeatureCollection() {
    const feats = _features();
    let ms = []
    for (let i = 0; i < feats.length; i++) {
      let m = L.marker(_coords(feats[i]), {icon: markerIconNormal, draggable: true}).addTo(map);
      _initMarker(m);
      ms.push(m)
    }
    setMarkers(ms);
  }

  // Builds the create marker control
  function _buildMarkerControl() {
    L.Control.CreateMarkerControl = L.Control.extend({
      onAdd: function (m) {
        const container = L.DomUtil.create('div', 'leaflet-create-marker');
        L.DomEvent
          .on(container, 'click', function (e) {
            e.stopPropagation();
            e.preventDefault();
            _createNewMarker(m);
          });
        return container;
      },
      onRemove: function (m) {
      }
    });

    L.control.createMarkerControl = function (opts) {
      return new L.Control.CreateMarkerControl(opts);
    }
  }

  function _initMarker(m) {
    m.on('click', function (e) {
      _unselectAllMarkers();
      _selectMarker(e.target);
    });
    m.on('drag', function (e) {
      _showMarkerEditPane(e.target);
    });
    m.on('moveend', function (e) {
      const marks = markersRef.current
      _unselectAllMarkers();
      _selectMarker(e.target);
      _writeFeatures(marks);
    });
  }

  function _initLayers(m) {
    if (layers.length === 1) {
      layers.forEach((layer) => {
        L.tileLayer(layer.value, {
          subdomains: subs,
          attribution: layer.attribution
        }).addTo(m);
      });
    } else if (layers.length > 1) {
      let baseMaps = {};

      layers.forEach((layer) => {
        baseMaps[layer.label] = L.tileLayer(layer.value, {
          subdomains: subs,
          attribution: layer.attribution
        });
      });
      Object.values(baseMaps)[0].addTo(m);
      L.control.layers(baseMaps, {}).addTo(m);
    } else {
      L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        subdomains: subs,
        attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors'
      }).addTo(m);
    }
  }

  function _unselectAllMarkers() {
    for (let i = 0; i < markers.length; i++) {
      markers[i].setIcon(markerIconNormal);
    }
    setSelectedMarker(null)
    setState({
      ...state,
      selectedMarkerLatitude: '',
      selectedMarkerLongitude: ''
    });
    _hideMarkerEditPane();
  }

  function _selectMarker(m) {
    m.setIcon(markerIconSelected);
    setSelectedMarker(m)
    // Update position in direct edit control
    _showMarkerEditPane(m);
  }

  function _showMarkerEditPane(m) {
    const pos = m.getLatLng();
    setState({
      ...state,
      selectedMarkerLatitude: pos.lat.toFixed(8),
      selectedMarkerLongitude: pos.lng.toFixed(8)
    })
    document.getElementById(editMarkerPaneId).style.display = 'block';
  }

  function _hideMarkerEditPane() {
    document.getElementById(editMarkerPaneId).style.display = 'none';
  }

  function _updatePositionOfSelectedMarker() {
    if (selectedMarker == null) return;
    let lat = parseFloat(state.selectedMarkerLatitude);
    let lng = parseFloat(state.selectedMarkerLongitude);
    if (isNaN(lat) || isNaN(lng)) return;
    const marks = markersRef.current
    selectedMarker.setLatLng([lat, lng]);
    _writeFeatures(marks);
  }

  function _handleChangeLatitude(e) {
    setState({
      ...state,
      selectedMarkerLatitude: e.target.value
    });
    _updatePositionOfSelectedMarker();
  }

  function _handleChangeLongitude(e) {
    setState({
      ...state,
      selectedMarkerLongitude: e.target.value
    });
    _updatePositionOfSelectedMarker();
  }

  function _createNewMarker(map) {
    const m = L.marker(_newMarkerPostion(map), {icon: markerIconNormal, draggable: true}).addTo(map);
    const marks = markersRef.current
    setMarkers([...marks, m]);

    _initMarker(m);
    _unselectAllMarkers();
    _selectMarker(m);

    _writeFeatures([...marks, m]);
  }

  // Returns the position of the new marker to create.
  // Currently this is a random position within the central part of the current view.
  // There is no overlay check implemented as it can be computationally quite expensive.
  function _newMarkerPostion(map) {
    let bbox = map.getBounds();
    const xr = Math.random(), yr = Math.random();
    const xext = bbox.getEast() - bbox.getWest();
    const yext = bbox.getNorth() - bbox.getSouth();
    const x = (xext / 2.0) * xr + bbox.getWest() + (xext / 4.0);
    const y = (yext / 2.0) * yr + bbox.getSouth() + (yext / 4.0);
    return [y, x];
  }

  function _deleteSelectedMarker() {
    if (selectedMarker == null) return;
    const marks = markersRef.current
    selectedMarker.remove();
    const idx = marks.indexOf(selectedMarker);
    if (idx > -1) {
      const splicedMarks = marks.splice(idx, 1)
      setMarkers(splicedMarks)
      _writeFeatures(splicedMarks);
    }
    _unselectAllMarkers();
  }

  return (
    <div className="geoEditor">
      <div id={mapId} style={{height: state.mapHeight}}></div>
      <div id={editMarkerPaneId} className="geo-edit-pane" style={{display: "none"}}>
        <label>Latitude: <input onKeyUp={_handleChangeLatitude} onChange={_handleChangeLatitude}
                                value={state.selectedMarkerLatitude}/></label>
        <label>&nbsp;Longitude: <input onKeyUp={_handleChangeLongitude} onChange={_handleChangeLongitude}
                                       value={state.selectedMarkerLongitude}/></label>
        <img onClick={_deleteSelectedMarker} src="/icons/delete-marker-white.png"/>
      </div>
    </div>
  );
};

GeoEditor.propTypes = {
  input: PropTypes.string.isRequired,
  bounds: PropTypes.object,
  layers: PropTypes.array
};

export default GeoEditor;
