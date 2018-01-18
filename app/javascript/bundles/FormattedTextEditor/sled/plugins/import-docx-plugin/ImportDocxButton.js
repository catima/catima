import React from 'react'
import classnames from 'classnames'

import { Button } from '../../components/button'
import Serializer from '../../../modules/Serializer'

// Ajax library for uploading DOCX files
import axios from 'axios';

const uuidv4 = require('uuid/v4');

class ImportDocxButton extends React.Component {
  constructor(props){
    super(props);
    this.props = props;
    this.uid = uuidv4();
    //{value, onChange, changeState, className, style, type}
    this.triggerDocxImport = this.triggerDocxImport.bind(this);
    this.handleDocxUpload = this.handleDocxUpload.bind(this);
  }

  // Function to trigger the file selection dialog based on a hidden file input
  triggerDocxImport(e){
    const self = this;
    const el = document.getElementById(`${self.uid}-fileInput`);
    el.click();
  }

  handleDocxUpload(){
    const self = this;

    const el = document.getElementById(`${this.uid}-fileInput`);
    if (el.files.length == 0) return;
    const f = el.files[0];

    const data = new FormData();
    data.append('docx', f);

    const csrfToken = document.getElementsByName('csrf-token')[0].content;

    axios.post('/s/docx2html', data, { headers: {'X-CSRF-Token': csrfToken} })
    .then(function(response){
      let html = response.data.html;
      if (html.length < 1){
        alert('Error while importing Word file. Only DOCX files are supported.');
        return;
      }

      let change = self.props.value.change();
      const input = Serializer.deserialize(html);
      const inputJson = input.toJS();
      for (let i=0; i < inputJson.document.nodes.length; i++){
        change.insertBlock(inputJson.document.nodes[i]);
      }
      self.props.onChange(change);

      el.value = '';    // Unselect the currently selected file.
    })
    .catch(function(err){
      alert('Error while importing Word file.')
      console.log('Error while importing Word file:', err)
    });
  }

  render(){
    return (
      <div style={{display: 'inline-block'}}>
        <Button
          style={this.props.style}
          type={this.props.type}
          onClick={this.triggerDocxImport}
          className={classnames(
            'slate-import-docx-plugin--button',
            this.props.className,
          )}
        >
          Import DOCX
        </Button>
        <input id={this.uid + '-fileInput'} accept="application/vnd.openxmlformats-officedocument.wordprocessingml.document" type="file" onChange={this.handleDocxUpload} style={{display: 'none'}} />
      </div>
    )
  }
}

export default ImportDocxButton
