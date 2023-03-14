class Validation {
  static isValid(isRequired, reference){
    if(isRequired) {
      const value = document.querySelector(reference).value;

      if (!value) return false;

      if (Array.isArray(JSON.parse(value))) {
        return JSON.parse(value).length
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
