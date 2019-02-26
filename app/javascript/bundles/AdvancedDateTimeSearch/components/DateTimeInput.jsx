import 'es6-shim';
import PropTypes from 'prop-types';
import React from 'react';
import ReactDOM from 'react-dom';
import $ from 'jquery';
import moment from 'moment';
import 'eonasdan-bootstrap-datetimepicker';

class DateTimeInput extends React.Component {

  static propTypes = {
    input: PropTypes.string.isRequired,
  };

  static defaultValues = {Y:'', M:'', D:'', h:'', m:'', s:''};

  static types = ['Y', 'M', 'h', 'YM', 'MD', 'hm', 'YMD', 'hms', 'MDh', 'YMDh', 'MDhm', 'YMDhm', 'MDhms', 'YMDhms'];

  constructor(props){
    super(props);
    this.state = {
      disabled: this.props.disabled,
      isRange: this.props.isRange,
      selectedDate: '',
      isDatepickerOpen: false,
      localizedDateTimeData: []
    };
    const date = this.getData();
    const granularity = this.getFieldOptions().format;
    for (let i in granularity){
      let k = granularity[i];
      this.state[k] = date[k] || (DateTimeInput.defaultValues)[k];
    }
    this.handleChangeDay = this._handleChangeDay.bind(this);
    this.handleChangeMonth = this._handleChangeMonth.bind(this);
    this.handleChangeYear = this._handleChangeYear.bind(this);
    this.handleChangeHours = this._handleChangeHours.bind(this);
    this.handleChangeMinutes = this._handleChangeMinutes.bind(this);
    this.handleChangeSeconds = this._handleChangeSeconds.bind(this);
    this.styleMarginRight = '';

    if(document.querySelector(this.props.input) !== null) {
      this.isRequired = (document.querySelector(this.props.input).getAttribute('data-field-required') == 'true');
    }

    this.selectDate = this._selectDate.bind(this);
    this.openCloseDatepicker = this._openCloseDatepicker.bind(this);
    this.clearDatepicker = this._clearDatepicker.bind(this);
  }

  componentDidMount() {
    this._initDatePicker();
    this.setState({ localizedDateTimeData: this.props.localizedDateTimeData });
    window.addEventListener("click", this.onSelectMonthClick);
    if (jQuery.isEmptyObject(this.getData())) return this.initData(DateTimeInput.defaultValues, this.getFieldOptions().format)
  }

  componentWillReceiveProps(nextProps) {
    if (nextProps.disabled !== this.state.disabled) {
      this.setState({ disabled: nextProps.disabled });
      //When the selected condition changes, we clear the inputs if the user has left une field empty
      if(nextProps.disabled) {
          var formatArray = this.props.format.split('');
          var count = 0;
          formatArray.forEach((item) => {
              if(this.state[item] !== '') {
                  count++;
              }
          });

          if(count < formatArray.length) {
              //The user has left a field empty => clear all fields
              this._clearDatepicker();
          }
      }
    }

    if (nextProps.isRange !== this.state.isRange) {
      this.setState({ isRange: nextProps.isRange });
    }
  }

  _initDatePicker() {
    if(typeof this.props.datepicker !== 'undefined' && this.props.datepicker) {
      const node = ReactDOM.findDOMNode(this);
      const dateInputElements = node.querySelectorAll('.form-control');

      if(dateInputElements.length > 3) {
        this.styleMarginRight = ' margin-right';
      }

      $(this.refs['hiddenInput']).datetimepicker({
        format: this.props.format,
        locale: this.props.locale
      });

      $(this.refs['hiddenInput']).datetimepicker().on('dp.change', (event) => this._onDatepickerChangerDate(event));
    }
  }

  _openCloseDatepicker() {
      if(this.state.isDatepickerOpen) {
          this.setState({isDatepickerOpen: false});
          $(this.refs['hiddenInput']).data("DateTimePicker").hide();
      } else {
          this.setState({isDatepickerOpen: true});
          $(this.refs['hiddenInput']).data("DateTimePicker").show();
      }
  }

  _getSelectClassNames() {
      if(this.state.disabled) {
          return "form-control disabled";
      } else {
          return "form-control";
      }
  }

  _clearDatepicker() {
    $(this.refs['hiddenInput']).data("DateTimePicker").clear();
    this.updateData({ Y: '', M: '', D: '', h: '', m: '', s: ''});
  }

  _onDatepickerChangerDate(data) {
    if(data.date !== false) {
      this.setState({selectedDate: data.date});
      this.updateData({ Y: data.date.year(), M: (data.date.month() + 1), D: data.date.date(), h: data.date.hour(), m: data.date.minute(), s: data.date.second()});
    } else {
      this.setState({selectedDate: ''});
      this.updateData({ Y: '', M: '', D: '', h: '', m: '', s: ''});
    }
  }

  _selectDate(event){
    if(typeof event === 'undefined' || event.action !== "pop-value" || !this.props.req) {
      if(typeof event !== 'undefined') {
        this.setState({ selectedDate: event.target.value });
      } else {
        this.setState({ selectedDate: '' });
      }
    }
  }

  _handleChangeDay(e){
    let v = parseInt(e.target.value);
    if (v < 1 || v > 31) return;
    if (isNaN(v)) v = "";
    this.updateData({D: v});
    //this.updateDatePicker({D: v});
  }

  _handleChangeMonth(e){
    let v = parseInt(e.target.value);
    if (v < 1 || v > 12) return;
    if (isNaN(v)) v = "";
    this.updateData({M: v});
    //this.updateDatePicker({M: v});
  }

  _handleChangeYear(e){
    let v = parseInt(e.target.value);
    if (isNaN(v)) v = "";
    this.updateData({Y: v});
    //this.updateDatePicker({Y: v});
  }

  _handleChangeHours(e){
    let v = parseInt(e.target.value);
    if (v < 0 || v > 23) return;
    if (isNaN(v)) v = "";
    this.updateData({h: v});
    //this.updateDatePicker({h: v});
  }

  _handleChangeMinutes(e){
    let v = parseInt(e.target.value);
    if (v < 0 || v > 59) return;
    if (isNaN(v)) v = "";
    this.updateData({m: v});
    //this.updateDatePicker({m: v});
  }

  _handleChangeSeconds(e){
    let v = parseInt(e.target.value);
    if (v < 0 || v > 59) return;
    if (isNaN(v)) v = "";
    this.updateData({s: v});
    //this.updateDatePicker({s: v});
  }

  initData(data, format) {
    let dt = {};
    for (let i in data){
      dt[i] = format.includes(i) ? data[i] || "" : null ;
    }
    this.updateData(dt);
  }

  updateData(h){
    this.setState(h);
    const d = this.getData();
    for (let k in h) d[k] = h[k];
    this.setData(d);
  }

  updateDatePicker(d) {
    var newDate = {Y: this.state.Y, M: this.state.M, D: this.state.D, h: this.state.h, m: this.state.m, s: this.state.s};
    Object.keys(d).forEach((index) => {
      newDate[index] = d[index];
    });
    $(this.refs['hiddenInput']).data("DateTimePicker").date(new Date(newDate.Y, newDate.M - 1, newDate.D, newDate.h, newDate.m, newDate.s));
  }

  getData(){
    const value = this.getInput().val();
    if (!value) return {};
    let v = JSON.parse(value);
    return v.raw_value ? this.rawValueToDateTime(v.raw_value) : v;
  }

  rawValueToDateTime(v){
    const dt = new Date(v * 1000)
    return {Y: dt.getFullYear(), M: dt.getMonth()+1, D: dt.getDate(), h: dt.getHours(), m: dt.getMinutes(), s: dt.getSeconds()};
  }

  setData(d){
    this.getInput().val(JSON.stringify(d));
  }

  getInput() {
    return $(this.props.input);
  }

  getAllowedFormats() {
    const granularity = this.getFieldOptions().format;
    return DateTimeInput.types.filter(obj => {
      if (granularity.includes(obj) || granularity == obj) return obj;
    });
  }

  getCurrentFormat() {
    let d = this.getData();
    let f = this.props.format;
    return f.split('').map(function(k){return d[k] ? k : ''; }).join('');
  }

  isCurrentFormatValid(){
    let current = this.getCurrentFormat();
    if (current == '' && !this.isRequired) return true;   // allow empty value if field is not required
    let allowed = this.getAllowedFormats();
    return allowed.indexOf(current) > -1;
  }

  getFieldOptions() {
    return this.getInput().data("field-options") || {format: this.props.format};
  }

  render(){
    let dateValid = this.isCurrentFormatValid()
    let errorStl = dateValid ? {} : { border: "2px solid #f00" };
    let errorMsg = dateValid ? "" : "Invalid value"
    let fmt = this.getFieldOptions().format;
    return (
      <div id={this.props.inputId + '_' + this.props.inputSuffixId}>
        <div className="dateTimeInput rails-bootstrap-forms-datetime-select">
            <div className="row">
              {fmt.includes('D') ? (
                <input id={this.props.inputId + '_' + this.props.inputSuffixId + '_day'} name={this.props.inputName + '[D]'} style={errorStl} type="number" min="0" max="31" className="input-2 form-control" value={this.state.D} onChange={this.handleChangeDay} readOnly={this.state.disabled || this.props.isRange} />
              ) : null
              }
              {fmt.includes('M') ? (
                    <select id={this.props.inputId + '_' + this.props.inputSuffixId + '_month'} style={errorStl} name={this.props.inputName + '[M]'} className={this._getSelectClassNames()} value={this.state.M} onChange={this.handleChangeMonth} ref={this.props.inputName + '[M]'} readOnly={this.state.disabled || this.props.isRange}>
                    { this.props.localizedDateTimeData.month_names.map((month, index) => {
                      if (month !== null) {
                        month = month.charAt(0).toUpperCase() + month.slice(1);
                      }
                      if (index === 0) {
                        index = ''
                      }

                      return <option key={index} value={index}>{ month }</option>
                    }
                    )}
                    </select>
              ) : null
              }
              {fmt.includes('Y') ? (
                <input id={this.props.inputId + '_' + this.props.inputSuffixId + '_year'} name={this.props.inputName + '[Y]'} style={errorStl} type="number" className={'input-4 form-control' + this.styleMarginRight} value={this.state.Y} onChange={this.handleChangeYear} readOnly={this.state.disabled || this.props.isRange} />
              ) : null
              }
              {fmt.includes('h') ? (
                <input id={this.props.inputId + '_' + this.props.inputSuffixId + '_hour'} name={this.props.inputName + '[h]'} style={errorStl} min="0" max="23" type="number" className="input-2 form-control" value={this.state.h} onChange={this.handleChangeHours} readOnly={this.state.disabled || this.props.isRange} />
              ) : null
              }
              {fmt.includes('m') ? (
                <input id={this.props.inputId + '_' + this.props.inputSuffixId + '_minute'} name={this.props.inputName + '[m]'} style={errorStl} min="0" max="59" type="number" className="input-2 form-control" value={this.state.m} onChange={this.handleChangeMinutes} readOnly={this.state.disabled || this.props.isRange} />
              ) : null
              }
              {fmt.includes('s') ? (
                <input id={this.props.inputId + '_' + this.props.inputSuffixId + '_second'} name={this.props.inputName + '[s]'} style={errorStl} min="0" max="59" type="number" className="input-2 form-control" value={this.state.s} onChange={this.handleChangeSeconds} readOnly={this.state.disabled || this.props.isRange} />
              ) : null
              }
              <div className="hidden-datepicker">
                <input type="text" ref="hiddenInput" value={this.state.selectedDate} onChange={this.selectDate}/>
              </div>
              <div className="calendar-button-container">
                <a id={this.props.inputId + '_calendar_icon' + '_' + this.props.inputSuffixId} onClick={this.openCloseDatepicker} type="button"><span className="glyphicon glyphicon-calendar"></span></a>
                <a onClick={this.clearDatepicker} type="button"><span className="glyphicon glyphicon-remove"></span></a>
              </div>
            </div>
        </div>
        <span className="error helptext">{errorMsg}</span>
      </div>
);
}

};

export default DateTimeInput;
