import 'es6-shim';
import PropTypes from 'prop-types';
import React, {useState, useEffect, useRef} from 'react';
import L from 'leaflet';
import 'leaflet-draw';
import {v4 as uuidv4} from 'uuid';
import Validation from "../../GeoEditor/modules/validation";
import Translations from "../../Translations/components/Translations";
import BoundingBox from "../../GeoViewer/modules/boundingBox";

const subs = ['a', 'b', 'c'];

const GeoEditor = (props) => {
  const {
    input,
    layers: layersProps,
    bounds: boundsProps,
    zoom: zoomProps,
    required: requiredProps
  } = props

  const editorId = uuidv4();

  const [bounds, setBounds] = useState()
  const [layers, setLayers] = useState()
  const [editing, setEditing] = useState(false)
  const [zoomLevel, setZoomLevel] = useState()
  const [fc, setFc] = useState() // TODO: to be removed
  const [selectedMarker, setSelectedMarker] = useState(null)
  const [map, setMap] = useState()
  const [drawnItems, setDrawnItems] = useState(new L.FeatureGroup())
  const [state, setState] = useState({
    mapHeight: 300,
    mapMinZoom: 1,
    mapMaxZoom: 18,
    selectedMarkerLatitude: ' ',
    selectedMarkerLongitude: '',
  })
  const [mapId, setMapId] = useState()
  const [editMarkerPaneId, setEditMarkerPaneId] = useState()
  const [isValid, setIsValid] = useState(Validation.isValid(
      requiredProps,
      input
  ))

  const CustomMarker = L.Icon.extend({
    options: {
      popupAnchor: new L.Point(-3, -3),
      iconAnchor: new L.Point(12, 12),
      iconSize: new L.Point(24, 24),
      iconUrl: '/icons/circle-marker.png'
    }
  });

  const editingRef = useRef(false)
  editingRef.current = editing

  useEffect(() => {
    setBounds(boundsProps || {xmin: -60, xmax: 60, ymin: -45, ymax: 60})
    setLayers(layersProps ? layersProps : [])
    setZoomLevel(zoomProps ? zoomProps : 10)
  }, [layersProps, boundsProps, zoomProps])

  useEffect(() => {
    const _mapId = 'map_' + editorId;
    const _editMarkerPaneId = 'editMarkerPane_' + editorId;
    setMapId(_mapId)
    setEditMarkerPaneId(_editMarkerPaneId)
  }, [])

  useEffect(() => {
    if (input) {
      let data = $(input).val()

      console.log('loadedFeatures', data);

      // TODO: remove fc, setFc() & _features() to use only drawnItems layers
      // TODO: update data init to also allow polylines & polygons

      if (data) {
        setFc(
          JSON.parse(
              (data === '' || data == null) ?
                  '{"type": "FeatureCollection", "features": []}' : data
          )
        )
      }
    }
  }, [input])

  useEffect(() => {
    if (mapId && !map) {
      // TODO: add translations for interface (L.drawLocal)

      const drawControl = new L.Control.Draw({
        draw: {
          polygon: {
            allowIntersection: false,
            drawError: {
              color: '#e10000',
              message: Translations.messages[
                  'catalog_admin.fields.geometry_option_inputs.cannot_intersects'
                  ]
            },
            shapeOptions: {
              color: '#9336af'
            }
          },
          marker: {
            icon: new CustomMarker()
          },
          polyline: {
            allowIntersection: true,
            shapeOptions: {
              color: '#000000'
            }
          },
          rectangle: false,
          circle: false,
          circlemarker: false
        },
        edit: {
          featureGroup: drawnItems,
        }
      });

      setMap(
          L.map(
            mapId,
            {
              minZoom: state.mapMinZoom,
              maxZoom: state.mapMaxZoom
            }
          )
              .setView(center(), 10)
              .addLayer(drawnItems)
              .addControl(drawControl)
      )
    }
  }, [mapId])

  useEffect(() => {
    if (map) {
      // Initialize map layers & layer control if needed
      _initLayers(map);

      // Leaflet Draw Events - Create
      map.on(L.Draw.Event.CREATED, function (event) {
        const layer = event.layer;

        // Add the new layer to the map
        drawnItems.addLayer(layer);

        // Add events to the new layer
        addEvents(layer);

        // Format & save the layers into features
        saveFeatures();
      });

      // Leaflet Draw Events - Edited
      map.on(L.Draw.Event.EDITED, function (event) {
        // Format & save the layers into features
        saveFeatures();
      });

      // Leaflet Draw Events - Edit Start
      map.on(L.Draw.Event.EDITSTART, function (event) {
        setEditing(true);
      });

      // Leaflet Draw Events - Edit Stop
      map.on(L.Draw.Event.EDITSTOP, function (event) {
        setEditing(false);

        _hideMarkerEditPane();

        setSelectedMarker(null);
      });

      // Leaflet Draw Events - Deleted
      map.on(L.Draw.Event.DELETED, function (event) {
        // Format & save the layers into features
        saveFeatures();
      });

      // Add the markers for existing features
      _addMarkersFromFeatureCollection();

      // Fit the map to the spacial extent of the markers
      const bboxVar = bbox();
      const w = bboxVar[1] - bboxVar[0], h = bboxVar[3] - bboxVar[2];
      map.fitBounds([
          [bboxVar[2] - 0.2*h, bboxVar[0] - 0.2*w],
          [bboxVar[3] + 0.2*h, bboxVar[1] + 0.2*w]
        ], { maxZoom: fc ? zoomLevel : null }
      );
    }
  }, [map])

  function saveFeatures() {
    let featureCollection = {
      "type": "FeatureCollection",
      "features": []
    };

    // Format the layers into a valid GeoJSON FeatureCollection
    // object (https://datatracker.ietf.org/doc/html/rfc7946#section-3.3).
    drawnItems.getLayers().forEach((layer) => {
      featureCollection.features.push(
          formatLayer(layer)
      );
    })

    console.log('saveFeatures', featureCollection);

    $(input).val(
      JSON.stringify(
          featureCollection
      )
    );

    setIsValid(Validation.isValid(
        requiredProps,
        input
      )
    )
  }

  // Format a layer into a valid GeoJSON Feature
  // object (https://datatracker.ietf.org/doc/html/rfc7946#section-3.2).
  function formatLayer(layer) {
    if (layer instanceof L.Marker) {
      return {
        type: "Feature",
        geometry: {
          type: "Point",
          coordinates: [layer._latlng.lng, layer._latlng.lat]
        },
        properties: {}
      }
    } else if (layer instanceof L.Polygon) {
      let coords = [];
      let start = [];

      layer._latlngs[0].forEach((latlng, index) => {
        coords.push([latlng.lng, latlng.lat]);

        if(index === 0) {
          start = [latlng.lng, latlng.lat];
        }
      })

      // The first and last positions are equivalent, and
      // they must contain identical values
      coords.push(start);

      return {
        type: "Feature",
        geometry: {
          type: "Polygon",
          coordinates: coords
        },
        properties: {}
      }
    } else if (layer instanceof L.Polyline) {
      let coords = [];

      layer._latlngs.forEach((latlng) => {
        coords.push([latlng.lng, latlng.lat]);
      })

      return {
        type: "Feature",
        geometry: {
          type: "LineString",
          coordinates: coords
        },
        properties: {}
      }
    }
  }

  function addEvents(layer) {
    layer.on('click', function (event) {
      if(editingRef.current) {
        if(layer instanceof L.Marker) {
          _showMarkerEditPane(
            event.target._latlng.lat,
            event.target._latlng.lng
          );

          setSelectedMarker(event.target);
        } else {
          _hideMarkerEditPane();

          setSelectedMarker(null);
        }
      }
    });

    layer.on('drag', function (event) {
      if(editingRef.current) {
        if(layer instanceof L.Marker) {
          _showMarkerEditPane(
              event.target._latlng.lat,
              event.target._latlng.lng
          );
        }
      }
    });
  }

  function _features() {
    return fc?.features || [];
  }

  function center(){
    const minmax = bbox();

    return [ (minmax[0] + minmax[1]) / 2, (minmax[2] + minmax[3]) / 2 ];
  }

  function bbox() {
    const features = _features();

    // Check if there are coordinates available, if not we return the spatial extent defined for the field
    if (features.length === 0) return [bounds.xmin, bounds.xmax, bounds.ymin, bounds.ymax];

    return BoundingBox.bbox(features);
  }

  // Returns the coordinates of the feature.
  function _coords(feat) {
    return [feat.geometry.coordinates[1], feat.geometry.coordinates[0]];
  }

  function _addMarkersFromFeatureCollection() {
    const feats = _features();

    let ms = []
    for (let i = 0; i < feats.length; i++) {
      let marker = L.marker(_coords(feats[i]), {
          icon: new CustomMarker(),
        }
      );

      // Add existing markers to the map
      drawnItems.addLayer(marker);

      // Add events to the existing markers
      addEvents(marker);
    }
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

  function _showMarkerEditPane(lat, lng) {
    setState({
      ...state,
      selectedMarkerLatitude: lat.toFixed(8),
      selectedMarkerLongitude: lng.toFixed(8)
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

    selectedMarker.setLatLng([lat, lng]);
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

  return (
    <div className="geoEditor"
         style={Validation.getStyle(requiredProps, input)}>
      <div id={mapId} style={{height: state.mapHeight}}></div>
      <div id={editMarkerPaneId} className="geo-edit-pane" style={{display: "none"}}>
        <label>Latitude: <input onKeyUp={_handleChangeLatitude} onChange={_handleChangeLatitude}
                                value={state.selectedMarkerLatitude}/></label>
        <label>&nbsp;Longitude: <input onKeyUp={_handleChangeLongitude} onChange={_handleChangeLongitude}
                                       value={state.selectedMarkerLongitude}/></label>
      </div>
    </div>
  );
};

GeoEditor.propTypes = {
  input: PropTypes.string.isRequired,
  bounds: PropTypes.object,
  layers: PropTypes.array,
  zoom: PropTypes.number.isRequired,
};

export default GeoEditor;
