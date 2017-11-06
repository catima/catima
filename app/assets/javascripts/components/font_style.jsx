var FontStyle = React.createClass({
  getInitialState: function(){
    return {
      bold: this.props.bold || false,
      italic: this.props.italic || false,
      underline: this.props.underline || false
    };
  },

  handleBoldChange: function(e){
    var newState = !this.state.bold;
    this.setState({bold: newState});
    this.props.onChange({bold: newState});
  },

  handleItalicChange: function(e){
    var newState = !this.state.italic;
    this.setState({italic: newState});
    this.props.onChange({italic: newState});
  },

  handleUnderlineChange: function(e){
    var newState = !this.state.underline;
    this.setState({underline: newState});
    this.props.onChange({underline: newState});
  },

  render: function(){
    return (
      <div className="btn-group" role="group" aria-label="Font style">
        <button type="button" onClick={this.handleBoldChange} data-active={this.state.bold} className="btn btn-sm btn-default"><b>B</b></button>
        <button type="button" onClick={this.handleItalicChange} data-active={this.state.italic} className="btn btn-sm btn-default"><i>I</i></button>
        <button type="button" onClick={this.handleUnderlineChange} data-active={this.state.underline} data-active={this.state.underline} className="btn btn-sm btn-default"><u>U</u></button>
      </div>
    )
  }
});
