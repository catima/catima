import React from 'react'


const EndnoteMark = ({ children }) => (
  <span className="endnote">
    <sup>{children}</sup>
  </span>
)

export default EndnoteMark
