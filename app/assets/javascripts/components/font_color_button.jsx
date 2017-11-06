function uuidv4() {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
    var r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
    return v.toString(16);
  });
}


var FontColorButton = React.createClass({

  getInitialState: function(){
    return {
      colorInputId: uuidv4()
    };
  },

  componentDidMount: function(){
    var self = this;
    $('#'+this.state.colorInputId).minicolors({
      theme: 'bootstrap',
      change: function(value, opacity){
        self.handleChange(value);
      }
    });
  },

  componentWillUnmount: function(){
    $('#'+this.state.colorInputId).minicolors('destroy');
  },

  handleChange: function(val){
    var newVal = {};
    newVal[this.props.elem] = val;
    this.props.onChange(newVal);
  },

  render: function(){
    return (
      <div className="colorButtonWrapper">
        {this.props.name}
        <div className="colorButton">
          <input id={this.state.colorInputId} type="hidden" value={this.props.value} onChange={this.handleChange} className="form-control" />
        </div>
      </div>
    );
  }
});