import React, { Component } from 'react';
import ReactDOM from 'react-dom';
import ReactSelect from 'react-select';
import axios from 'axios';
import $ from 'jquery';
import 'moment';
import 'eonasdan-bootstrap-datetimepicker';
import DateTimeSearch from '../../AdvancedDateTimeSearch/components/DateTimeSearch';
import striptags from 'striptags';

class LinkedCategoryInput extends Component {
  constructor(props){
    super(props);

    this.state = {
      isLoading: true,
      inputName: this.props.inputName,
      inputNameArray: [],
      startDateInputName: '',
      endDateInputName: '',
      dateFormat: '',
      inputType: 'Field::Text',
      inputData: null,
      inputOptions: null,
      selectedFilter: {},
      selectedItem: [],
      selectCondition: [],
      selectedCondition: this.props.selectedCondition,
      hiddenInputValue: []
    };

    this.selectItem = this._selectItem.bind(this);
  }

  componentWillReceiveProps(nextProps) {
    if (nextProps.selectedCategory !== this.state.selectedCategory) {
      this._getDataFromServer(nextProps.selectedCategory);
      this.setState({ selectedCategory: nextProps.selectedCategory });
    }

    if (nextProps.inputName !== this.state.inputName && nextProps.selectedCondition === this.state.selectedCondition) {
      this._buildDateTimeInputNames(this.state.inputType, nextProps.inputName, this.state.selectedCondition);
      this.setState({ inputName: nextProps.inputName });
    } else if (nextProps.inputName === this.state.inputName && nextProps.selectedCondition !== this.state.selectedCondition) {
      this._buildDateTimeInputNames(this.state.inputType, this.state.inputName, nextProps.selectedCondition);
      this.setState({ selectedCondition: nextProps.selectedCondition });
    } else {
        this._buildDateTimeInputNames(this.state.inputType, nextProps.inputName, nextProps.selectedCondition);
        this.setState({ inputName: nextProps.inputName });
        this.setState({ selectedCondition: nextProps.selectedCondition });
    }
  }

  componentDidMount(){
    this._getDataFromServer();
    this._buildDateTimeInputNames(this.state.inputType, this.props.inputName, this.props.selectedCondition);
  }

  _buildDateTimeInputNames(type, inputName, condition) {
    if(type === 'Field::DateTime') {
      var endName = inputName.split(this.state.inputNameArray[0]);
      this.setState({startDateInputName: this.state.inputNameArray[0] + '[start]' + endName[1] + '[' + condition + ']' });
      this.setState({endDateInputName: this.state.inputNameArray[0] + '[end]' + endName[1] + '[' + condition + ']'});
    }
  }

  _buildInputNameCondition(condition) {
      var nameArray = this.props.inputName.split("[category_criteria]");
      if(nameArray.length === 2) {
        if(condition !== '') return nameArray[0] + "[category_criteria]" + '[' + condition + ']' + nameArray[1];
        else return nameArray[0] + "[category_criteria]" + '[default]' + nameArray[1];
      } else {
        return this.props.inputName;
      }
  }

  _save(){
    if(this.state.selectedItem !== null && this.state.selectedItem.length !== 0) {

      var idArray = [];
      this.state.selectedItem.forEach((item) => {
        idArray.push(item.value);
      });

      this.setState({ hiddenInputValue: idArray });

      document.getElementsByName(this.props.inputName)[0].value = this.state.hiddenInputValue;
    }
  }

  _selectItem(event){
    if(typeof event === 'undefined' || event.action !== "pop-value" || !this.props.req) {
      if(typeof item !== 'undefined') {
        this.setState({ selectedItem: event.target.value }, () => this._save());
      } else {
        this.setState({ selectedItem: [] }, () => this._save());
      }
    }
  }

  _getDataFromServer(selectedCategory) {
    let config = {
      retry: 1,
      retryDelay: 1000
    };

    if (typeof selectedCategory !== 'undefined') {
      this.props.selectedCategory.value = selectedCategory.value;
      this.props.selectedCategory.label = selectedCategory.label;
    }

    axios.get(`/api/v2/${this.props.catalog}/${this.props.locale}/categories/${this.props.selectedCategory.choiceSetId}/${this.props.selectedCategory.value}`, config)
    .then(res => {
      if(res.data.inputData === null) this.setState({ inputData: [] });
      else this.setState({ inputData: res.data.inputData });

      this._updateSelectCondition(res.data.selectCondition);
      this.setState({ inputNameArray: this.state.inputName.split('[' + res.data.selectCondition[0].key + ']')});
      this._buildDateTimeInputNames(res.data.inputType, this.state.inputName, this.state.selectedCondition);
      this.setState({ inputOptions: res.data.inputOptions });
      this._updateDateTimeFormatOption(res.data.inputOptions);
      this.setState({ inputType: res.data.inputType });
      this.setState({ isLoading: false });
    });

    // Retry failed requests
    axios.interceptors.response.use(undefined, (err) => {
      let config = err.config;

      if(!config || !config.retry) return Promise.reject(err);

      config.__retryCount = config.__retryCount || 0;

      if(config.__retryCount >= config.retry) {
        return Promise.reject(err);
      }

      config.__retryCount += 1;

      let backoff = new Promise(function(resolve) {
        setTimeout(function() {
          resolve();
        }, config.retryDelay || 1);
      });

      return backoff.then(function() {
        return axios(config);
      });
    });
  }

  _updateSelectCondition(array) {
    this.props.updateSelectCondition(array);
    this.setState({ selectCondition: array });
  }

  _updateDateTimeFormatOption(format) {
    var formatOption = this._searchInArray(format, 'format');
    if (formatOption === false) {
      this.setState({dateFormat: ''});
    }
    else {
      this.setState({dateFormat: formatOption.format});
    }
  }

  _getChoiceSetMultipleOption() {
    var multipleOption = this._searchInArray(this.state.inputOptions, 'multiple');
    if (multipleOption === false) return false;
    else return multipleOption.multiple;
  }

  _searchInArray(array, key) {
    if(array !== null) {
      for (var i = 0; i < array.length; i++) {
          if (typeof array[i][key] !== 'undefined') {
              return array[i];
          }
      }
    }
    return false;
  }

  _getMultipleChoiceSetOptions(){
    var optionsList = [];
    optionsList = this.state.inputData.map(option =>
      this._getJSONOption(option)
    );

    return optionsList;
  }

  _getJSONOption(option) {
    return {value: option.key, label: option.value};
  }

  renderInput(){
    if (this.state.isLoading) return null;
    if (this.state.inputType === 'Field::DateTime') {
      return <DateTimeSearch
                id={this.referenceSearchId}
                selectCondition={[]}
                disableInputByCondition={this.props.selectedCondition}
                startDateInputName={this.state.startDateInputName}
                endDateInputName={this.state.endDateInputName}
                catalog={this.props.catalog}
                itemType={this.props.itemType}
                inputStart='input1'
                inputEnd='input2'
                isRange={true}
                format={this.state.dateFormat}
                locale={this.props.locale}
                onChange={this.selectItem}
              />
    } else if (this.state.inputType === 'Field::Email') {
      return <input name={this._buildInputNameCondition(this.state.selectedCondition)} onChange={this.selectItem} type="text" className="form-control"/>
    } else if (this.state.inputType === 'Field::Int' || this.state.inputType === 'Field::Decimal') {
      return <input name={this._buildInputNameCondition(this.state.selectedCondition)} onChange={this.selectItem} type="number" className="form-control"/>
    } else if (this.state.inputType === 'Field::URL') {
      return <input name={this._buildInputNameCondition(this.state.selectedCondition)} onChange={this.selectItem} type="url" className="form-control"/>
    } else if ((this.state.inputType === 'Field::ChoiceSet' && !this._getChoiceSetMultipleOption()) || this.state.inputType === 'Field::Boolean') {
      return (
        <select name={this._buildInputNameCondition(this.state.selectedCondition)} onChange={this.selectItem} className="form-control">
          { this.state.inputData.map((item) => {
            return <option key={item.key}>{item.value}</option>
            })
          }
        </select>
      );
    } else if (this.state.inputType === 'Field::ChoiceSet' && this._getChoiceSetMultipleOption()) {
      return (
        <ReactSelect name={this._buildInputNameCondition(this.state.selectedCondition)} isMulti options={this._getMultipleChoiceSetOptions()} className="basic-multi-select" onChange={this.selectItem} classNamePrefix="select" placeholder={this.props.searchPlaceholder}/>
      );
    } else {
      return <input name={this._buildInputNameCondition(this.state.selectedCondition)} onChange={this.selectItem} type="text" className="form-control"/>
    }
  }

  render() {
    return (
      <div className="single-reference-container">
        { this.state.isLoading && <div className="loader"></div> }
        { this.renderInput() }
      </div>
    );
  }

}

export default LinkedCategoryInput;
