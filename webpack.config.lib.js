var path              = require('path');
var webpack           = require('webpack');

module.exports = {
  devtool: 'cheap-module-source-map',
  entry: [
    './index.coffee'
  ],
  output: {
    libraryTarget: 'commonjs2',
    library: 'MeshbluHttp',
    path: path.join(__dirname, 'dist'),
    filename: 'bundle.js'
  },
  module: {
    loaders: [
      { test: /\.coffee$/, loader: "coffee" }
    ]
  },
  plugins: [
     new webpack.optimize.OccurenceOrderPlugin(),
     new webpack.optimize.UglifyJsPlugin({
      compress: {
        warnings: false
      }
    })
   ]
};
