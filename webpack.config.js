var path          = require('path');
var webpack       = require('webpack');

module.exports = {
  entry: [
    './src/meshblu-http.coffee'
  ],
  output: {
    path: path.join(__dirname, 'deploy', 'browser-meshblu-http', 'latest'),
    filename: 'meshblu-http.bundle.js'
  },
  module: {
    loaders: [
      { test: /\.coffee$/, loader: "coffee" }
    ]
  }
};
