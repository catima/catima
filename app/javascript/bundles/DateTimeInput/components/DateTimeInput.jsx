import 'es6-shim';
import PropTypes from 'prop-types';
import React from 'react';

class DateTimeInput extends React.Component {

  static propTypes = {
    input: PropTypes.string.isRequired,
  };

  static defaultValues = {Y:"", M:"", D:"", h:"", m:"", s:""};

  static types = ["Y", "M", "h", "YM", "MD", "hm", "YMD", "hms", "MDh", "YMDh", "MDhm", "YMDhm", "MDhms", "YMDhms"];

  constructor(props){
    super(props);
    this.state = {};
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

    this.isRequired = (document.querySelector(this.props.input).getAttribute('data-field-required') == 'true')
  }

  componentDidMount() {
    if (jQuery.isEmptyObject(this.getData())) return this.initData(DateTimeInput.defaultValues, this.getFieldOptions().format);
  }

  _handleChangeDay(e){
    let v = parseInt(e.target.value);
    if (v < 1 || v > 31) return;
    if (isNaN(v)) v = "";
    this.updateData({D: v});
  }

  _handleChangeMonth(e){
    let v = parseInt(e.target.value);
    if (v < 1 || v > 12) return;
    if (isNaN(v)) v = "";
    this.updateData({M: v});
  }

  _handleChangeYear(e){
    let v = parseInt(e.target.value);
    if (isNaN(v)) v = "";
    this.updateData({Y: v});
  }

  _handleChangeHours(e){
    let v = parseInt(e.target.value);
    if (v < 0 || v > 23) return;
    if (isNaN(v)) v = "";
    this.updateData({h: v});
  }

  _handleChangeMinutes(e){
    let v = parseInt(e.target.value);
    if (v < 0 || v > 59) return;
    if (isNaN(v)) v = "";
    this.updateData({m: v});
  }

  _handleChangeSeconds(e){
    let v = parseInt(e.target.value);
    if (v < 0 || v > 59) return;
    if (isNaN(v)) v = "";
    this.updateData({s: v});
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
    let f = this.getFieldOptions().format;
    return f.split('').map(function(k){ return d[k] ? k : ''; }).join('')
  }

  isCurrentFormatValid(){
    let current = this.getCurrentFormat();
    if (current == '' && !this.isRequired) return true;   // allow empty value if field is not required
    let allowed = this.getAllowedFormats();
    return allowed.indexOf(current) > -1;
  }

  getFieldOptions() {
    return this.getInput().data("field-options") || {format: 'YMD'};
  }

  render(){
    let dateValid = this.isCurrentFormatValid()
    let errorStl = dateValid ? {} : { border: "2px solid #f00" };
    let errorMsg = dateValid ? "" : "Invalid value"
    let fmt = this.getFieldOptions().format;
    return (
      <div>
        <div className="dateTimeInput rails-bootstrap-forms-datetime-select">
          {fmt.includes('D') ? (
              <input  style={errorStl} type="number" min="0" max="31" className="input-2 form-control" value={this.state.D} onChange={this.handleChangeDay} />
            ) : null
          }
          {fmt.includes('M') ? (
            <select  style={errorStl} className="form-control" value={this.state.M} onChange={this.handleChangeMonth}>
              <option value=""></option>
              <option value="1">January</option>
              <option value="2">February</option>
              <option value="3">March</option>
              <option value="4">April</option>
              <option value="5">May</option>
              <option value="6">June</option>
              <option value="7">July</option>
              <option value="8">August</option>
              <option value="9">September</option>
              <option value="10">October</option>
              <option value="11">November</option>
              <option value="12">December</option>
            </select>) : null
          }
          {fmt.includes('Y') ? (
              <input  style={errorStl} className="input-4 margin-right form-control" value={this.state.Y} onChange={this.handleChangeYear} />
          ) : null
          }
          {fmt.includes('h') ? (
              <input  style={errorStl} min="0" max="23" type="number" className="input-2 form-control" value={this.state.h} onChange={this.handleChangeHours} />
            ) : null
          }
          {fmt.includes('m') ? (
              <input  style={errorStl} min="0" max="59" type="number" className="input-2 form-control" value={this.state.m} onChange={this.handleChangeMinutes} />
            ) : null
          }
          {fmt.includes('s') ? (
              <input  style={errorStl} min="0" max="59" type="number" className="input-2 form-control" value={this.state.s} onChange={this.handleChangeSeconds} />
            ) : null
          }
        </div>
        <span className="error helptext">{errorMsg}</span>
      </div>
    );
  }

};

export default DateTimeInput;
