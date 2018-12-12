import React, { Component } from 'react';
import ReactDOM from 'react-dom';
import DateTimeInput from './DateTimeInput';
import $ from 'jquery';
import 'moment';
import 'eonasdan-bootstrap-datetimepicker';

class DateTimeSearch extends Component {
  constructor(props){
    super(props);

    this.state = {
      selectedCondition: '',
      selectedFieldCondition: '',
      startDateInputName: this.props.startDateInputName,
      endDateInputName: this.props.endDateInputName,
      startDateInputNameArray: this.props.startDateInputName.split("[exact]"),
      endDateInputNameArray: this.props.endDateInputName.split("[exact]"),
      disabled: true
    };

    this.dateTimeSearchId = `${this.props.srcId}-datetime`;
    this.dateTimeSearchRef = `${this.props.srcRef}-datetime`;
    this.dateTimeSearchRef2 = `${this.props.srcRef}-datetime2`;
    this.dateTimeCollapseId = `${this.props.srcId}-collapse`;

    this.selectCondition = this._selectCondition.bind(this);
    this.selectFieldCondition = this._selectFieldCondition.bind(this);
  }

  componentDidMount(){

    if(typeof this.props.selectCondition !== 'undefined' && this.props.selectCondition.length !== 0) {
        this.setState({selectedCondition: this.props.selectCondition[0].key});
        this.setState({startDateInputNameArray: this.props.startDateInputName.split("["+ this.props.selectCondition[0].key +"]")})
        this.setState({endDateInputNameArray: this.props.endDateInputName.split("["+ this.props.selectCondition[0].key +"]")})
        this._updateDisableState(this.props.selectCondition[0].key);
    }
  }

  componentWillReceiveProps(nextProps) {
    if(typeof nextProps.disableInputByCondition !== 'undefined') {
        this._updateDisableState(nextProps.disableInputByCondition);
    }

    if (nextProps.startDateInputName !== this.state.startDateInputName) {
      this.setState({ startDateInputName: nextProps.startDateInputName });
    }

    if (nextProps.endDateInputName !== this.state.endDateInputName) {
      this.setState({ endDateInputName: nextProps.endDateInputName });
    }
  }

  _buildInputNameCondition(inputName, condition) {
      if(inputName.length === 2) {
        if (condition !== '') return inputName[0] + '[' + condition + ']' + inputName[1];
        else return inputName[0] + '[default]' + inputName[1];
      } else {
        return inputName;
      }
  }

  _getDateTimeClassname() {
    if(this.props.selectCondition.length > 0) {
      return 'col-md-7';
    } else {
      return 'col-md-12';
    }
  }

  _linkRangeDatepickers(ref1, ref2, disabled) {
    if(!disabled) {
      $(this.refs[ref1].refs.hiddenInput).datetimepicker().on("dp.change", (e) => {
        $(this.refs[ref2].refs.hiddenInput).data("DateTimePicker").minDate(e.date);
      });
      $(this.refs[ref2].refs.hiddenInput).datetimepicker().on("dp.change", (e) => {
        $(this.refs[ref1].refs.hiddenInput).data("DateTimePicker").maxDate(e.date);
      });
    } else {
      $(this.refs[ref2].refs.hiddenInput).data("DateTimePicker").clear();
    }
  }

  _updateDisableState(value) {
    if(typeof value !== 'undefined') {
      if(value === 'between' || value === 'outside') {
        this.setState({ disabled: false });
        $('#' + this.dateTimeCollapseId).slideDown();
        this._linkRangeDatepickers(this.dateTimeSearchRef, this.dateTimeSearchRef2, false);
      } else {
        this.setState({ disabled: true });
        $('#' + this.dateTimeCollapseId).slideUp();
        this._linkRangeDatepickers(this.dateTimeSearchRef, this.dateTimeSearchRef2, true);
      }
    }
  }

  _selectCondition(event){
    if(typeof event === 'undefined' || event.action !== "pop-value" || !this.props.req) {
      if(typeof event !== 'undefined') {
        this.setState({ startDateInputName: this._buildInputNameCondition(this.state.startDateInputNameArray, event.target.value)});
        this.setState({ endDateInputName: this._buildInputNameCondition(this.state.endDateInputNameArray, event.target.value)});
        this.setState({ selectedCondition: event.target.value });
        this._updateDisableState(event.target.value);
      } else {
        this.setState({ startDateInputName: this._buildInputNameCondition(this.state.startDateInputNameArray, 'exact')});
        this.setState({ endDateInputName: this._buildInputNameCondition(this.state.endDateInputNameArray, 'exact')});
        this.setState({ selectedCondition: '' });
        this._updateDisableState('');
      }
    }
  }

  _selectFieldCondition(event){
    if(typeof event === 'undefined' || event.action !== "pop-value" || !this.props.req) {
      if(typeof event !== 'undefined') {
        this.setState({ selectedFieldCondition: event.target.value });
      } else {
        this.setState({ selectedFieldCondition: '' });
      }
    }
  }

  renderSelectConditionElement(){
    return (
      <select className="form-control filter-condition" name={this.props.selectConditionName} value={this.state.selectedCondition} onChange={this.selectCondition}>
      { this.props.selectCondition.map((item) => {
        return <option key={item.key} value={item.key}>{item.value}</option>
      })}
      </select>
    );
  }

  renderDateTimeElement(){
    return (
      <div className="d-inline-block">
        <DateTimeInput input={this.props.inputStart} inputId={this.dateTimeSearchId} inputSuffixId="start_date" inputName={this.state.startDateInputName} ref={this.dateTimeSearchRef} datepicker={true} locale={this.props.locale} format={this.props.format}/>
        { !this.state.disabled &&
          <i className="fa fa-chevron-down"></i>
        }
      </div>
    );
  }

  renderFieldConditionElement(){
    return (
      <select className="form-control filter-condition" name={this.props.fieldConditionName} value={this.state.selectedFieldCondition} onChange={this.selectFieldCondition}>
      { this.props.fieldConditionData.map((item) => {
        return <option key={item.key} value={item.key}>{item.value}</option>
      })}
      </select>
    );
  }


  render() {
    return (
      <div className="datetime-search-container row">
        { this.props.selectCondition.length > 0 &&
        <div className="col-md-2">
            { this.renderFieldConditionElement() }
        </div>
        }
        <div className={this._getDateTimeClassname()}>
          { this.props.startLabel !== '' && (typeof this.props.startLabel !== 'undefined') &&
          <label>{ this.props.startLabel }</label>
          }
          { this.renderDateTimeElement() }
          <div className="collapse" id={this.dateTimeCollapseId}>
            { this.props.endLabel !== '' && (typeof this.props.endLabel !== 'undefined') &&
            <div className="row">
              <div className="col-md-12"><label>{ this.props.endLabel }</label></div>
            </div>
            }
            <div className="row">
              <div className="col-md-12"><DateTimeInput input={this.props.inputEnd} inputId={this.dateTimeSearchId} inputSuffixId="end_date" inputName={this.state.endDateInputName} disabled={this.state.disabled} ref={this.dateTimeSearchRef2} datepicker={true} locale={this.props.locale} format={this.props.format}/></div>
            </div>
          </div>
        </div>
        { this.props.selectCondition.length > 0 &&
        <div className="col-md-3">
          { this.renderSelectConditionElement() }
        </div>
        }
      </div>
    );
  }

}

export default DateTimeSearch;
