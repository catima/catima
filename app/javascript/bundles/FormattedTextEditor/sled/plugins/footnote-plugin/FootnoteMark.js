import React from 'react'


const FootnoteMark = ({ children }) => (
  <span className="footnote">
    <sup>{children}</sup>
  </span>
)

export default FootnoteMark
