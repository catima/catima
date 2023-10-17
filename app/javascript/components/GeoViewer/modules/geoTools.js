import L from "leaflet";
import Translations from "../../Translations/components/Translations";

export const CustomMarker = L.Icon.extend({
  options: {
    popupAnchor: new L.Point(-3, -3),
    iconAnchor: new L.Point(12, 12),
    iconSize: new L.Point(24, 24),
    iconUrl: '/icons/circle-marker.png'
  }
});
export const PolylineColor = '#000000';
export const PolygonColor = '#9336af';
export const PolygonOptions = {
  allowIntersection: false,
  drawError: {
    color: '#e10000',
    message: Translations.messages[
        'catalog_admin.fields.geometry_option_inputs.cannot_intersects'
        ]
  },
  shapeOptions: {
    color: PolygonColor
  }
};
export const PolylineOptions = {
  allowIntersection: true,
  shapeOptions: {
    color: PolylineColor
  }
}
export const MarkerOptions = {
  icon: new CustomMarker()
}

export class GeoTools {
  // Format a GeoJSON Feature object into a Leaflet layer.
  static featureToLayer(feature){
    let layer = null;

    if(feature.geometry.type === 'Point') {
      layer = L.marker(
          [
            feature.geometry.coordinates[1],
            feature.geometry.coordinates[0]
          ],
          MarkerOptions
      );
    } else if(feature.geometry.type === 'LineString') {
      layer = L.polyline(
          feature.geometry.coordinates.map(
              (coord) => { return [coord[1], coord[0]] }
          ),
          {}
      );

      layer.setStyle({
        color: PolylineColor
      });
    } else if(feature.geometry.type === 'Polygon') {
      layer = L.polygon(
          feature.geometry.coordinates.map(
              (coord) => { return [coord[1], coord[0]] }
          ),
          {}
      );

      layer.setStyle({
        color: PolygonColor
      });
    }

    return layer;
  }

  // Format a Leaflet layer into a GeoJSON Feature object as described
  // in https://datatracker.ietf.org/doc/html/rfc7946#section-3.2.
  static layerToFeature(layer){
    let feature = null;

    if (layer instanceof L.Marker) {
      feature = {
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

      feature = {
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

      feature = {
        type: "Feature",
        geometry: {
          type: "LineString",
          coordinates: coords
        },
        properties: {}
      }
    }

    return feature;
  }
}
