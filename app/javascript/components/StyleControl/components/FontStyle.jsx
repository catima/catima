import 'es6-shim';
import React from 'react';

class FontStyle extends React.Component {
  constructor(props){
    super(props)
    this.state = {
      bold: (this.props.fontWeight == 'bold') || false,
      italic: (this.props.fontStyle == 'italic') || false,
      underline: (this.props.textDecoration == 'underline') || false
    };
    this.handleBoldChange = this._handleBoldChange.bind(this);
    this.handleItalicChange = this._handleItalicChange.bind(this);
    this.handleUnderlineChange = this._handleUnderlineChange.bind(this);
  }

  _handleBoldChange(e){
    let newState = !this.state.bold;
    this.setState({bold: newState});
    this.props.onChange({fontWeight: newState ? 'bold' : 'normal'});
  }

  _handleItalicChange(e){
    let newState = !this.state.italic;
    this.setState({italic: newState});
    this.props.onChange({fontStyle: newState ? 'italic' : 'normal'});
  }

  _handleUnderlineChange(e){
    let newState = !this.state.underline;
    this.setState({underline: newState});
    this.props.onChange({textDecoration: newState ? 'underline' : 'none'});
  }

  render(){
    return (
      <div className="btn-group" role="group" aria-label="Font style">
        <button type="button" onClick={this.handleBoldChange} data-active={this.state.bold} className="btn btn-sm btn-outline-secondary"><b>B</b></button>
        <button type="button" onClick={this.handleItalicChange} data-active={this.state.italic} className="btn btn-sm btn-outline-secondary"><i>I</i></button>
        <button type="button" onClick={this.handleUnderlineChange} data-active={this.state.underline} data-active={this.state.underline} className="btn btn-sm btn-outline-secondary"><u>U</u></button>
      </div>
    )
  }
};

export default FontStyle;
