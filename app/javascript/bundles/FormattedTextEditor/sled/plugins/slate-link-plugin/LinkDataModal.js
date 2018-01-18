import React, { Component } from 'react'
import { updateLinkStrategy, unlink } from './LinkUtils'
import { Modal, ModalButton, ModalContent, ModalForm } from '../../components/modal'

class LinkDataModal extends Component {
  constructor(props) {
    super(props)

    const { node } = this.props

    this.state = {
      imageAttributes: {
        title: node.data.get('title'),
        href: node.data.get('href'),
        text: node.data.get('text') || this.props.presetData.text,
        target: node.data.get('target'),
      },
    }
  }

  hasNodeText(props) {
    return props.node.data.get('text')
  }

  componentWillUpdate(props) {
    const hasDiffText = this.props.presetData.text !== props.presetData.text

    if (!this.hasNodeText(this.props) && hasDiffText) {
      this.setLinkAttribute(
        { target: { name: 'text' } },
        props.presetData.text
      )
    }
  }

  componentWillMount() {
    const hasDiffText = this.props.presetData.text !== this.state.imageAttributes.text

    // update the text input value according to text that
    // have modified inline outside of the modal.
    if (this.hasNodeText(this.props) && hasDiffText) {
      this.setLinkAttribute(
        { target: { name: 'text' } },
        this.props.presetData.text
      )
    }
  }

  componentDidMount() {
    this.inputHref.focus()
  }

  setLinkAttribute(event, value) {
    this.setState({
      imageAttributes: {
        ...this.state.imageAttributes,
        [event.target.name]: value,
      }
    })
  }

  isValidHref(href) {
    // allow http://, https:// (secure) and non-protocol (default http://)
    // eslint-disable-next-line
    return /^(https?:\/\/)?[\w]{2,}\.[\w\.]{2,}$/.test(href)
  }

  render() {
    const { node, value, onChange, changeModalState } = this.props

    return (
      <Modal>
        <Modal.Header
          closeButtonAction={() => {
            if (!node.data.get('href')) onChange(unlink(value.change()))
            changeModalState(false)
          }}
        />

        <ModalContent>
          <ModalContent.Right>
            <ModalForm onSubmit={e => {
              e.preventDefault()

              const { imageAttributes } = this.state

              if (!imageAttributes.href) {
                onChange(unlink(value.change()))
              } else {
                onChange(updateLinkStrategy({ change: value.change(), data: imageAttributes }))
              }

              changeModalState(false)
            }}>

              <ModalForm.Group>
                <label htmlFor="image-plugin--edit-href">URL</label>
                <input
                  id="image-plugin--edit-href"
                  type="text"
                  name="href"
                  onClick={e => e.stopPropagation()}
                  onChange={e => this.setLinkAttribute(e, e.target.value)}
                  value={this.state.imageAttributes.href || ''}
                  placeholder="Ex: http://example.com"
                  ref={input => this.inputHref = input}
                />
              </ModalForm.Group>

              <ModalButton.Container>
                <ModalButton.Primary
                  type="submit"
                  text="Ok"
                />
                <ModalButton.Opaque
                  text="Cancel"
                  onClick={() => {
                    if (!node.data.get('href')) onChange(unlink(value.change()))
                    changeModalState(false)
                  }}
                />
              </ModalButton.Container>
            </ModalForm>
          </ModalContent.Right>
        </ModalContent>
      </Modal>
    )
  }
}

export default LinkDataModal
