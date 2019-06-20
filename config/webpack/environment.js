const { environment } = require('@rails/webpacker')
const webpack = require('webpack')
const eslint = require('./loaders/eslint')

environment.plugins.prepend(
  'Provide',
  new webpack.ProvidePlugin({
    $: 'jquery',
    jQuery: 'jquery',
    jquery: 'jquery'
  })
)
environment.loaders.append('eslint', eslint)
module.exports = environment