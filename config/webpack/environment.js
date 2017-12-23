const { environment } = require('@rails/webpacker')

const webpack = require('webpack')

environment.plugins.set('Provide',  new webpack.ProvidePlugin({
    $: 'jquery',
    jQuery: 'jquery',
    jquery: 'jquery',
  })
)

const config = environment.toWebpackConfig()

config.resolve.alias = {
  jquery: "jquery/src/jquery",
}

module.exports = environment
