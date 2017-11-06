var StyleControl = React.createClass({

  getInitialState: function(){
    return $.extend(
      {
        font: '', 'fontSize': '',
        bold: '', italic: '', underline: '',
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
        <p>StyleControl: {this.state.font}</p>
        <FontMenu value={this.state.font} onChange={this.handleChange} />
        <FontSize value={this.state.fontSize} onChange={this.handleChange} />
        <FontStyle
          bold={this.state.bold}
          italic={this.state.italic}
          underline={this.state.underline}
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
          font={this.state.font}
          fontSize={this.state.fontSize}
          bold={this.state.bold}
          italic={this.state.italic}
          underline={this.state.underline}
          color={this.state.color}
          backgroundColor={this.state.backgroundColor}
        />

      </div>
    );
  }
});