class Validation {
  static isValid(isRequired, reference, type){
    if(isRequired) {
      const value = document.querySelector(reference).value;

      switch (type) {
        case 'Multiple':
          return Array.isArray(JSON.parse(value)) && JSON.parse(value).length
        case 'Single':
        default:
          return !!value;
      }
    }

    return true;
  }
}

export default Validation;
