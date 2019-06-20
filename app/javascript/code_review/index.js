import React from 'react'
import ReactDOM from 'react-dom'
import CodeReview from './code-review'
document.addEventListener('DOMContentLoaded', () => {
  const container = document.body.appendChild(document.createElement('div'))
  ReactDOM.render(<CodeReview />, container)
})
