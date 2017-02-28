var path    = require('path');
var webpack = require('webpack');

module.exports = {
  entry: './src/meshblu-http.coffee',
  output: {
    library: 'MeshbluHttp',
    path: path.join(__dirname, 'deploy', 'browser-meshblu-http', 'latest'),
    filename: 'meshblu-http.bundle.js'
  },
  devtool: '#source-map',
  module: {
    rules: [
      {
        test: /\.coffee$/,
        use: [ 'coffee-loader' ]
      }
    ]
  },
  plugins: [
    new webpack.IgnorePlugin(/^(buffertools)$/), // unwanted "deeper" dependency
  ]
};
