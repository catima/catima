class Validation {
  static isValid(isRequired, reference){
    if(isRequired) {
      const value = document.querySelector(reference).value;

      if (!value) return false;

      if (JSON.parse(value).features) {
        return JSON.parse(value).features.length;
      }

      return !!value;
    }

    return true;
  }

  static getStyle(isRequired, reference) {
    return this.isValid(isRequired, reference) ? {} : { border: "2px solid #f00" };
  }

  static getMessage(isRequired, reference) {
    return this.isValid(isRequired, reference) ? "" : "Invalid value";
  }
}

export default Validation;
