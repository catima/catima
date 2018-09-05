import React, { Component } from 'react';
import ReactDOM from 'react-dom';
import axios from 'axios';
import SingleReferenceEditor from './SingleReferenceEditor';
import MultiReferenceEditor from './MultiReferenceEditor';

class ReferenceEditor extends Component {
  constructor(props){
    super(props);

    this.state = {
      items: [],
      isLoading: true
    };
  }

  componentDidMount(){
    axios.get(`/api/v2/${this.props.catalog}/${this.props.locale}/${this.props.itemType}`)
      .then(res => {
        this.setState({ items: res.data.items });
        this.setState({ isLoading: false });
      });
  }

  renderEditor(){
    if (this.state.isLoading) return null;
    if (this.props.multiple)
      return <MultiReferenceEditor
                items={this.state.items}
                srcRef={this.props.srcRef}
                srcId={this.props.srcId}
                req={this.props.req} />
    else
      return <SingleReferenceEditor
                items={this.state.items}
                srcRef={this.props.srcRef}
                srcId={this.props.srcId}
                req={this.props.req} />
  }

  render() {
    return (
      <div id={this.editorId} className="referenceEditor">
        { this.state.isLoading && <div className="loader"></div> }
        { this.renderEditor() }
      </div>
    );
  }
}

export default ReferenceEditor;
