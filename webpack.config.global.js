var path              = require('path');
var webpack           = require('webpack');

module.exports = {
  entry: [
    './src/meshblu-http.coffee'
  ],
  output: {
    library: 'MeshbluHttp',
    path: path.join(__dirname, 'deploy', 'browser-meshblu-http', 'latest'),
    filename: 'meshblu-http.bundle.js'
  },
  module: {
    loaders: [
      {
        test: /\.coffee$/, loader: 'coffee-loader', include: /src/
      }
    ]
  },
  plugins: [
    new webpack.IgnorePlugin(/^(buffertools)$/), // unwanted "deeper" dependency
    new webpack.NoEmitOnErrorsPlugin(),
    new webpack.optimize.OccurrenceOrderPlugin(),
    new webpack.DefinePlugin({
      'process.env': {
        'NODE_ENV': JSON.stringify('production')
      }
    }),
    new webpack.optimize.UglifyJsPlugin({
      compressor: {
        screw_ie8: true,
        warnings: false
      }
    })
   ]
};
