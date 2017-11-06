var FontExample = React.createClass({

  render: function(){
    var stl = {
      fontFamily: this.props.font,
      fontSize: this.props.fontSize,
      fontWeight: this.props.bold ? "bold" : "normal",
      fontStyle: this.props.italic ? "italic" : "normal",
      textDecoration: this.props.underline ? "underline" : "none",
      color: this.props.color,
      backgroundColor: this.props.backgroundColor
    };
    return (
      <div className="example">
        <b>Example: </b>
        <span style={stl}>Lorem ipsum dolor sit amet, consectetur adipiscing elit.</span>
      </div>
    );
  }
})