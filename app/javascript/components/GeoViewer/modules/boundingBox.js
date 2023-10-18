class BoundingBox {
  static bbox(features){
    const coords = features.flatMap((feature) => {
      if (feature.geometry) {
        if (feature.geometry.type === 'Point') {
          // Used for Point features
          return [feature.geometry.coordinates];
        } else {
          // Used for LineString and Polygon features
          return feature.geometry.coordinates;
        }
      } else {
        return feature.flatMap(
          (f) => (f && f.geometry ? f.geometry.coordinates : [])
        );
      }
    });

    const minmax = BoundingBox.#minmax(coords);
    // Check if there are non-valid numbers in the minmax. If so, we return a default bbox
    if (minmax.map((a) => isNaN(a)).reduce((a, b) => a || b, false)) return [-60, 60, -120, 120];

    return minmax;
  }

  static #minmax(coords){
    if (typeof(coords) !== 'undefined' && typeof(coords[0]) === 'number') {
      return [coords[0], coords[0], coords[1], coords[1]];
    }

    return BoundingBox.#minmaxArray(coords);
  }

  static #minmaxArray(coords){
    let xmin = null, xmax = null, ymin = null, ymax = null;

    for (let i in coords){
      let xyminmax = BoundingBox.#minmax(coords[i]);

      if (xmin == null || xyminmax[0] < xmin) xmin = xyminmax[0];
      if (xmax == null || xyminmax[1] > xmax) xmax = xyminmax[1];
      if (ymin == null || xyminmax[2] < ymin) ymin = xyminmax[2];
      if (ymax == null || xyminmax[3] > ymax) ymax = xyminmax[3];
    }

    return [xmin, xmax, ymin, ymax];
  }
}

export default BoundingBox;
