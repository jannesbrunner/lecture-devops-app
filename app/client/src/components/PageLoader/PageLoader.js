import React from 'react'
import Loader from 'react-loader-spinner'
/* eslint-disable */
require('./PageLoader.css')
/* eslint-enable */

export default function PageLoader () {
  return (
    <Loader
      type='Watch'
      height={100}
      width={100}
      className='pageLoader-main'
    />
  )
}
