class Validation {
  static isValid(isRequired, reference, type){
    if(isRequired) {
      const value = document.getElementById(reference).value;

      switch (type) {
        case 'MultiReferenceEditor':
          return Array.isArray(JSON.parse(value)) && JSON.parse(value).length
        case 'SingleReferenceEditor':
        default:
          return !!value;
      }
    }

    return true;
  }

  static getStyle(isRequired, reference, type) {
    return this.isValid(isRequired, reference, type) ? {} : { border: "2px solid #f00" };
  }

  static getMessage(isRequired, reference, type) {
    return this.isValid(isRequired, reference, type) ? "" : "Invalid value";
  }
}

export default Validation;
