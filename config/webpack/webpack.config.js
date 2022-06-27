// const { webpackConfig, merge } = require('@rails/webpacker');
const { webpackConfig, merge } = require('shakapacker');

// const MiniCssExtractPlugin = require('mini-css-extract-plugin');

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
      // // Add CSS/SASS/SCSS rule with loaders
      // {
      //   test: /\.s[ac]ss$/i,
      //   use: [MiniCssExtractPlugin.loader, 'css-loader', 'sass-loader'],
      // },
    ],
  },
};

module.exports = merge(webpackConfig, customConfig);
