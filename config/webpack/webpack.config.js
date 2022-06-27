// const { webpackConfig, merge } = require('@rails/webpacker');
const { webpackConfig, merge } = require('shakapacker');

const customConfig = {
  resolve: {
    extensions: ['.js', '.jsx', '.css', '.scss'],
  },
  module: {
    rules: [
      // TODO: Remove the below rule for .mjs, once the graphql and
      // graphql-tag packages versions we're using support webpack 5.
      {
        test: /\.m?js/,
        resolve: {
          fullySpecified: false,
        },
      },
    ],
  },
};

module.exports = merge(webpackConfig, customConfig);
