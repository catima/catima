const { environment } = require('@rails/webpacker')

const webpack = require('webpack')

const config = environment.toWebpackConfig()

module.exports = environment
