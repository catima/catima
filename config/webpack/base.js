const { webpackConfig, merge } = require('shakapacker')

const options = {
  resolve: {
    extensions: [ '.coffee', '.erb', '.jsx', '.mjs', '.js', '.sass', '.scss', '.css', '.module.sass', '.module.scss', '.module.css', '.png', '.svg', '.gif', '.jpeg', '.jpg' ]
  }
}

// TODO: Should be removed when upgrading to react 18
// https://github.com/reactjs/react-rails#getting-warning-for-cant-resolve-react-domclient-in-react--18
const ignoreWarningsConfig = {
  ignoreWarnings: [/Module not found: Error: Can't resolve 'react-dom\/client'/],
};

module.exports = merge({}, webpackConfig, options, ignoreWarningsConfig)
