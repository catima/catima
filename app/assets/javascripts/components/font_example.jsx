var FontExample = React.createClass({

  render: function(){
    return (
      <div className="example">
        <b>Example: </b>
        <span style={this.props}>Lorem ipsum dolor sit amet, consectetur adipiscing elit.</span>
      </div>
    );
  }
})