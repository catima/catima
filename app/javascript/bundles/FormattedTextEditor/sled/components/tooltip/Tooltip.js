import React from 'react'

if (require('exenv').canUseDOM) require('./Tooltip.css')

const Tooltip = ({ children, className, ...props }) => (
  <div
    {...props}
    className="tooltip--container"
    contentEditable={false}
  >
    {children}
  </div>
)

Tooltip.Item = ({ children, ...props }) => (
  <div {...props} className="tooltip--item">
    {children}
  </div>
)

export default Tooltip
