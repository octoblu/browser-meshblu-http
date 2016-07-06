request  = require 'superagent'
ParseUrl = require 'url-parse'
qs       = require 'qs'


#It's dumb, but it saves ~60k!
extend        = require 'lodash/extend'
isEmpty       = require 'lodash/isEmpty'
_ = {extend, isEmpty}

class MeshbluHttp
  constructor: (meshbluConfig) ->
    throw new Error("MeshbluHttp only allows hostname: 'server' is not allowed") if meshbluConfig?.server
    throw new Error("MeshbluHttp only allows hostname: 'host' is not allowed") if meshbluConfig?.host

    options = _.extend port: 443, hostname: 'meshblu.octoblu.com', meshbluConfig
    {@uuid, @token, @hostname, @port, @protocol} = options
    @protocol = null if @protocol == 'websocket'
    try @port = parseInt @port
    @protocol ?= 'https:' if @port == 443
    @protocol ?= 'http:'

  claimdevice: (uuid, callback) =>
    @_request('post', "/claimdevice/#{uuid}")
      .end (error, response) =>
        return callback error if error?
        return callback new Error 'Invalid Response Code' unless response.ok
        callback null, response.body

  createSubscription: ({subscriberUuid, emitterUuid, type}, callback) =>
    @_request('post', "/v2/devices/#{subscriberUuid}/subscriptions/#{emitterUuid}/#{type}")
      .end (error, response) =>
        return callback error if error?
        return callback new Error 'Invalid Response Code' unless response.ok
        callback null

  deleteSubscription: ({subscriberUuid, emitterUuid, type}, callback) =>
    @_request('delete', "/v2/devices/#{subscriberUuid}/subscriptions/#{emitterUuid}/#{type}")
      .end (error, response) =>
        return callback error if error?
        return callback new Error 'Invalid Response Code' unless response.ok
        callback null

  device: (uuid, callback) =>
    @_request('get', "/v2/devices/#{uuid}")
      .end (error, response) =>
        return callback error if error?
        return callback null if response.notFound
        return callback new Error 'Invalid Response Code' unless response.ok
        return callback new Error 'Invalid Response' if _.isEmpty response.body
        callback null, response.body

  devices: (query, callback) =>
    @_request('get', '/v2/devices')
      .query qs.stringify query
      .end (error, response) =>
        return callback error if error?
        return callback null if response.notFound
        return callback new Error 'Invalid Response Code' unless response.ok
        callback null, response.body ? []

  search: ({query, projection}, callback) =>
    projection ?= {}
    @_request('post', '/search/devices')
      .set 'X-MESHBLU-PROJECTION', JSON.stringify projection
      .send query
      .end (error, response) =>
        return callback error if error?
        return callback null if response.notFound
        return callback new Error 'Invalid Response Code' unless response.ok
        callback null, response.body ? []

  generateAndStoreToken: (uuid, options={}, callback) =>
    @_request('post', "/devices/#{uuid}/tokens")
      .send options
      .end (error, response) =>
        return callback error if error?
        return callback new Error 'Invalid Response Code' unless response.ok
        return callback new Error 'Invalid Response' if _.isEmpty response.body
        callback null, response.body

  listSubscriptions: ({subscriberUuid}, callback) =>
    @_request('get', "/v2/devices/#{subscriberUuid}/subscriptions")
      .end (error, response) =>
        return callback error if error?
        return callback new Error 'Invalid Response Code' unless response.ok
        callback null, response.body

  message: (message, callback) =>
   @_request('post', '/messages')
    .send message
    .end (error, response) =>
        return callback error if error?
        return callback new Error 'Invalid Message' unless response.ok
        callback null

  register: (body, callback) =>
    @_request('post', '/devices')
      .send body
      .end (error, response) =>
        return callback error if error?
        return callback null if response.notFound
        return callback new Error 'Invalid Response Code' unless response.ok
        return callback new Error 'Invalid Response' if _.isEmpty response.body
        callback null, response.body

  removeTokenByQuery: (uuid, options={}, callback) =>
    @_request('del', "/devices/#{uuid}/tokens")
      .query options
      .end (error, response) =>
        return callback error if error?
        return callback new Error 'Invalid Response Code' unless response.ok
        callback null

  revokeToken: (uuid, token, callback=->) =>
    @_request('del', "/devices/#{uuid}/tokens/#{token}")
      .end (error, response) =>
        return callback error if error?
        return callback new Error 'Invalid Response Code' unless response.ok
        callback null

  unregister: (uuid, callback) =>
    @_request('del', "/devices/#{uuid}")
      .end (error, response) =>
        return callback error if error?
        return callback new Error 'Invalid Response Code' unless response.ok
        callback null, response.body

  update: (uuid, body, callback) =>
    @_request('patch', "/v2/devices/#{uuid}")
      .send body
      .end (error, response) =>
        return callback error if error?
        return callback new Error 'Invalid Response Code' unless response.ok
        callback null, response.body

  updateDangerously: (uuid, body, callback) =>
    @_request('put', "/v2/devices/#{uuid}")
      .send body
      .end (error, response) =>
        return callback error if error?
        return callback new Error 'Invalid Response Code' unless response.ok
        callback null, response.body

  whoami: (callback) =>
    @_request('get', '/v2/whoami')
      .end (error, response) =>
        return callback error if error?
        return callback new Error 'Invalid Response Code' unless response.ok
        return callback new Error 'Invalid Device' if _.isEmpty response.body
        callback null, response.body

  _url: (pathname) =>
    theUrl = new ParseUrl('')
    theUrl.set 'hostname', @hostname
    theUrl.set 'protocol', @protocol
    theUrl.set 'port', @port
    theUrl.set 'pathname', pathname
    return theUrl.toString()

  _request: (method, uri) =>
    theRequest = request[method](@_url uri)
    if @uuid? && @token?
      theRequest.auth @uuid, @token
    theRequest.accept('application/json')
    theRequest.set('Content-Type', 'application/json')
    return theRequest

module.exports = MeshbluHttp
