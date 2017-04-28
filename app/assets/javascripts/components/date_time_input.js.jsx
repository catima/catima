var DateTimeInput = React.createClass({

  getInitialState: function() {
    var s = {};
    var date = this.props.date || {};
    for (var i in this.props.granularity){
      var k = this.props.granularity[i];
      s[k] = date[k] || ({Y:2000, M:1, D:1, h:0, m:0, s:0})[k];
    }
    return s;
  },

  handleChangeDay: function(e){
    var v = parseInt(e.target.value);
    if (v < 1 || v > 31) return;
    this.updateData({D: v});
  },

  handleChangeMonth: function(e){
    var v = parseInt(e.target.value);
    if (v < 1 || v > 12) return;
    this.updateData({M: v});
  },

  handleChangeYear: function(e){
    var v = parseInt(e.target.value);
    if (isNaN(v)) return;
    this.updateData({Y: v});
  },

  handleChangeHours: function(e){
    var v = parseInt(e.target.value);
    if (v < 0 || v > 23) return;
    this.updateData({h: v});
  },

  handleChangeMinutes: function(e){
    var v = parseInt(e.target.value);
    if (v < 0 || v > 59) return;
    this.updateData({m: v});
  },

  handleChangeSeconds: function(e){
    var v = parseInt(e.target.value);
    if (v < 0 || v > 59) return;
    this.updateData({s: v});
  },

  updateData: function(h){
    this.setState(h);
    var d = this.getData();
    for (var k in h) d[k] = h[k];
    this.setData(d);
  },

  getData: function(){
    var value = $('#item_'+this.props.field+"_json").val();
    if (value === "") {
      return {};
    }
    return JSON.parse(value);
  },

  setData: function(d){
    $('#item_'+this.props.field+"_json").val(JSON.stringify(d));
  },

  render: function(){
    return (
      <div className="dateTimeInput rails-bootstrap-forms-datetime-select">
        {this.state.D != null ? (
            <input type="number" min="1" max="31" className="input-2 form-control" value={this.state.D} onChange={this.handleChangeDay} />
          ) : null
        }
        {this.state.M != null ? (
          <select className="form-control" value={this.state.M} onChange={this.handleChangeMonth}>
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

});
