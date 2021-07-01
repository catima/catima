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
      fields: [],
      isLoading: true,
      searchPlaceholder: '',
      filterPlaceholder: ''
    };
  }

  componentDidMount(){
    const csrfToken = $('meta[name="csrf-token"]').attr('content');
    let config = {
      retry: 3,
      retryDelay: 1000,
      headers: {'X-CSRF-Token': csrfToken}
    };

    axios.get(`/react/${this.props.catalog}/${this.props.locale}/${this.props.itemType}?page=1`, config)
      .then(res => {
        this.setState({ searchPlaceholder: res.data.search_placeholder });
        this.setState({ selectPlaceholder: res.data.select_placeholder });
        this.setState({ filterPlaceholder: res.data.filter_placeholder });
        this.setState({ loadingMessage: res.data.loading_message });
        this.setState({ items: res.data.items });
        this.setState({ fields: res.data.fields });
        this.setState({ isLoading: false });
      });

    // Retry failed requests
    axios.interceptors.response.use(undefined, (err) => {
      let config = err.config;

      if(!config || !config.retry) return Promise.reject(err);

      config.__retryCount = config.__retryCount || 0;

      if(config.__retryCount >= config.retry) {
        return Promise.reject(err);
      }

      config.__retryCount += 1;

      let backoff = new Promise(function(resolve) {
        setTimeout(function() {
          resolve();
        }, config.retryDelay || 1);
      });

      return backoff.then(function() {
        return axios(config);
      });
    });
  }

  _getNoOptionsMessage() {
    return () => this.props.noOptionsMessage;
  }

  renderEditor(){
    if (this.state.isLoading) return null;
    if (this.props.multiple)
      return <MultiReferenceEditor
        items={this.state.items}
        itemsUrl={`/react/${this.props.catalog}/${this.props.locale}/${this.props.itemType}`}
        fields={this.state.fields}
        searchPlaceholder={this.state.searchPlaceholder}
        filterPlaceholder={this.state.filterPlaceholder}
        selectedReferences={this.props.selectedReferences}
        srcRef={this.props.srcRef}
        srcId={this.props.srcId}
        req={this.props.req}
        noOptionsMessage={this._getNoOptionsMessage()}
      />
    else
      return <SingleReferenceEditor
        items={this.state.items}
        itemsUrl={`/react/${this.props.catalog}/${this.props.locale}/${this.props.itemType}`}
        fields={this.state.fields}
        searchPlaceholder={this.state.selectPlaceholder}
        filterPlaceholder={this.state.filterPlaceholder}
        selectedReference={this.props.selectedReferences}
        loadingMessage={this.state.loadingMessage}
        srcRef={this.props.srcRef}
        srcId={this.props.srcId}
        req={this.props.req}
        noOptionsMessage={this._getNoOptionsMessage()}
      />
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
