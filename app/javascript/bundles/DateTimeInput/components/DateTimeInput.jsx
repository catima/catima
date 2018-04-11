import 'es6-shim';
import PropTypes from 'prop-types';
import React from 'react';


class DateTimeInput extends React.Component {

  static propTypes = {
    input: PropTypes.string.isRequired,
  };

  constructor(props){
    super(props);
    this.state = {};
    const date = this.getData();
    const granularity = this.getFieldOptions().format;
    for (let i in granularity){
      let k = granularity[i];
      this.state[k] = date[k] || ({Y:0, M:0, D:0, h:0, m:0, s:0})[k];
    }
    this.handleChangeDay = this._handleChangeDay.bind(this);
    this.handleChangeMonth = this._handleChangeMonth.bind(this);
    this.handleChangeYear = this._handleChangeYear.bind(this);
    this.handleChangeHours = this._handleChangeHours.bind(this);
    this.handleChangeMinutes = this._handleChangeMinutes.bind(this);
    this.handleChangeSeconds = this._handleChangeSeconds.bind(this);
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

  updateData(h){
    this.setState(h);
    const d = this.getData();
    for (let k in h) d[k] = h[k];
    this.setData(d);
  }

  getData(){
    const value = this.getInput().val();
    if (typeof(value) === 'undefined' || value === "") {
      return {};
    }
    return JSON.parse(value);
  }

  setData(d){
    this.getInput().val(JSON.stringify(d));
  }

  getInput() {
    return $(this.props.input);
  }

  getFieldOptions() {
    return this.getInput().data("field-options") || {format: 'YMD'};
  }

  render(){
    return (
      <div className="dateTimeInput rails-bootstrap-forms-datetime-select">
        {this.state.D != null ? (
            <input type="number" min="0" max="31" className="input-2 form-control" value={this.state.D} onChange={this.handleChangeDay} />
          ) : null
        }
        {this.state.M != null ? (
          <select className="form-control" value={this.state.M} onChange={this.handleChangeMonth}>
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
        <input className="input-4 margin-right form-control" value={this.state.Y} onChange={this.handleChangeYear} />
        {this.state.h != null ? (
            <input min="0" max="23" type="number" className="input-2 form-control" value={this.state.h} onChange={this.handleChangeHours} />
          ) : null
        }
        {this.state.m != null ? (
            <input min="0" max="59" type="number" className="input-2 form-control" value={this.state.m} onChange={this.handleChangeMinutes} />
          ) : null
        }
        {this.state.s != null ? (
            <input min="0" max="59" type="number" className="input-2 form-control" value={this.state.s} onChange={this.handleChangeSeconds} />
          ) : null
        }
      </div>
    );
  }

};

export default DateTimeInput;

