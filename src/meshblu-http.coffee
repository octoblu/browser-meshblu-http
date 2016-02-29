_       = require 'lodash'
request = require 'superagent'
url     = require 'url'
debug   = require('debug')('meshblu-http')

class MeshbluHttp
  constructor: (meshbluConfig) ->
    options = _.extend port: 443, server: 'meshblu.octoblu.com', meshbluConfig
    {@uuid, @token, @server, @port, @protocol} = options
    @protocol = null if @protocol == 'websocket'
    try @port = parseInt @port
    @protocol ?= 'http'
    @protocol = 'https' if @port == 443

  generateAndStoreToken: (uuid, options={}, callback) =>
    debug 'generateAndStoreToken'
    request
      .post @_url "/devices/#{uuid}/tokens"
      .auth @uuid, @token
      .send options
      .end (error, response) =>
        debug 'generateAndStoreToken response', response.status
        return callback new Error 'Invalid Response Code' unless response.ok
        return callback new Error 'Invalid Response' if _.isEmpty response.body
        callback null, response.body.token

  device: (uuid, callback) =>
    debug 'get device'
    request
      .get @_url "/v2/devices/#{uuid}"
      .auth @uuid, @token
      .end (error, response) =>
        debug 'get device response', response.status
        return callback null if response.notFound
        return callback new Error 'Invalid Response Code' unless response.ok
        return callback new Error 'Invalid Response' if _.isEmpty response.body
        callback null, response.body.device

  devices: (query, callback) =>
    debug 'get devices'
    request
      .get @_url "/v2/devices"
      .auth @uuid, @token
      .query query
      .end (error, response) =>
        debug 'get devices response', response.status
        return callback null if response.notFound
        return callback new Error 'Invalid Response Code' unless response.ok
        return callback new Error 'Invalid Response' if _.isEmpty response.body
        callback null, response.body ? []

  removeTokenByQuery: (uuid, options={}, callback) =>
    debug 'removeTokenByQuery'
    request
      .del @_url "/devices/#{uuid}/tokens"
      .query options
      .auth @uuid, @token
      .end (error, response) =>
        debug 'removeTokenByQuery response', response.status
        return callback new Error 'Invalid Response Code' unless response.ok
        callback null

  whoami: (callback) =>
    debug 'whoami'
    request
      .get @_url '/v2/whoami'
      .auth @uuid, @token
      .end (error, response) =>
        debug 'whoami response', response.status
        return callback new Error 'Invalid Response Code' unless response.ok
        return callback new Error 'Invalid Device' if _.isEmpty response.body
        callback null, response.body

  _url: (pathname) =>
    url.format {@protocol, hostname:@server, @port, pathname}

module.exports = MeshbluHttp
