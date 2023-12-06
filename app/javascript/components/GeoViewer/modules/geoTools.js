import L from "leaflet";
import Translations from "../../Translations/components/Translations";
import rewind from "@turf/rewind";

export const CustomMarkerEdit = L.Icon.extend({
  options: {
    popupAnchor: new L.Point(-3, -3),
    iconAnchor: new L.Point(12, 12),
    iconSize: new L.Point(24, 24),
    iconUrl: '/icons/circle-marker.png'
  }
});
export const CustomMarkerView = L.Icon.extend({
  options: {
    popupAnchor: new L.Point(0, -40),
    iconAnchor: new L.Point(12, 40),
    iconSize: new L.Point(25, 41),
    iconUrl: '/icons/plain-blue-marker.png'
  }
});
export const MarkerOptionsEdit = {
  icon: new CustomMarkerEdit()
}
export const MarkerOptionsView = {
  icon: new CustomMarkerView()
}

export class GeoTools {
  // Format a GeoJSON Feature object into a Leaflet layer.
  static featureToLayer(
      feature,
      type = 'viewer',
      polygonColor = null,
      polylineColor = null)
  {
    let layer = null;

    if(feature.geometry.type === 'Point') {
      layer = L.marker(
          [
            feature.geometry.coordinates[1],
            feature.geometry.coordinates[0]
          ],
          type === 'viewer' ? MarkerOptionsView : MarkerOptionsEdit
      );
    } else if(feature.geometry.type === 'LineString') {
      layer = L.polyline(
          feature.geometry.coordinates.map(
              (coord) => { return [coord[1], coord[0]] }
          ),
          {}
      );

      layer.setStyle({
        color: polylineColor
      });
    } else if(feature.geometry.type === 'Polygon') {
      layer = L.polygon(
          feature.geometry.coordinates[0].map(
              (coord) => { return [coord[1], coord[0]] }
          ),
          {}
      );

      layer.setStyle({
        color: polygonColor
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
          coordinates: [
            coords
          ]
        },
        properties: {}
      }

      // Ensure the polygon follows the right-hand rule as described in
      // https://datatracker.ietf.org/doc/html/rfc7946#section-3.1.6.
      feature = rewind(feature);
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
