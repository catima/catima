const { generateWebpackConfig, merge } = require("shakapacker");
const webpackConfig = generateWebpackConfig();

const options = {
  resolve: {
    extensions: [
      ".coffee",
      ".erb",
      ".jsx",
      ".mjs",
      ".js",
      ".sass",
      ".scss",
      ".css",
      ".module.sass",
      ".module.scss",
      ".module.css",
      ".png",
      ".svg",
      ".gif",
      ".jpeg",
      ".jpg",
    ],
  },
};

module.exports = merge({}, webpackConfig, options);
