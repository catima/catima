var StyleControl = React.createClass({

  getInitialState: function(){
    return $.extend(
      {
        fontFamily: '', 'fontSize': '',
        fontWeight: 'normal', fontStyle: 'normal', textDecoration: 'none',
        color: '', 'backgroundColor': ''
      },
      this.getData()
    );
  },

  getData: function(){
    var value = this.getInput().val();
    if (value === '') {
      return {};
    }
    var v = JSON.parse(value);
    return (this.props.element ? v[this.props.element] : v);
  },

  setData: function(d){
    var dobj = $.extend(this.getData(), d);
    var s = JSON.parse(this.getInput().val() || {});
    if (this.props.element) {
      s[this.props.element] = dobj;
    } else {
      s = dobj
    }
    this.getInput().val(JSON.stringify(s));
  },

  getInput: function(){
    return $(this.props.input);
  },

  handleChange: function(d){
    this.setState(d);
    this.setData(d);
  },

  render: function(){
    return (
      <div>
        <p>StyleControl: {this.state.fontFamily}</p>
        <FontMenu value={this.state.fontFamily} onChange={this.handleChange} />
        <FontSize value={this.state.fontSize} onChange={this.handleChange} />
        <FontStyle
          fontWeight={this.state.bold}
          fontStyle={this.state.italic}
          textDecoration={this.state.underline}
          onChange={this.handleChange}
        />
        <FontColorButton
          name="Font color:"
          elem="color"
          value={this.state.color}
          onChange={this.handleChange}
        />
        <FontColorButton
          name="Background color:"
          elem="backgroundColor"
          value={this.state.backgroundColor}
          onChange={this.handleChange}
        />
        <FontExample
          fontFamily={this.state.font}
          fontSize={this.state.fontSize}
          fontWeight={this.state.bold}
          fontStyle={this.state.italic}
          textDecoration={this.state.underline}
          color={this.state.color}
          backgroundColor={this.state.backgroundColor}
        />

      </div>
    );
  }
});