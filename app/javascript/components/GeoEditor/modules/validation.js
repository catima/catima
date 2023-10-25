import booleanValid from "@turf/boolean-valid";

class Validation {
  static isValid(isRequired, reference){
    const value = document.querySelector(reference).value;

    // If the field has features, we check whether they are valid
    if (this.hasFeatures(value) && !this.featuresValidity(value)) {
      return false;
    }

    // If the field is required, we check whether it has features
    return !(isRequired && !this.hasFeatures(value));
  }

  static hasFeatures(value) {
    if (!value) return false;

    return JSON.parse(value).features && JSON.parse(value).features.length > 0;
  }

  static featuresValidity(value) {
    const features = JSON.parse(value).features;
    const isValid = features.every(feature => booleanValid(feature));

    if (!isValid) {
      console.log('One or more features are not valid');
    }

    return isValid;
  }

  static getStyle(isRequired, reference) {
    return this.isValid(isRequired, reference) ? {} : { border: "2px solid #f00" };
  }

  static getMessage(isRequired, reference) {
    return this.isValid(isRequired, reference) ? "" : "Invalid value";
  }
}

export default Validation;
