_        = require 'lodash'
request  = require 'superagent'
ParseUrl = require 'url-parse'
qs       = require 'qs'

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
    request
      .post @_url "/claimdevice/#{uuid}"
      .auth @uuid, @token
      .end (error, response) =>
        return callback error if error?
        return callback new Error 'Invalid Response Code' unless response.ok
        callback null, response.body

  createSubscription: ({subscriberUuid, emitterUuid, type}, callback) =>
    request
      .post @_url "/v2/devices/#{subscriberUuid}/subscriptions/#{emitterUuid}/#{type}"
      .auth @uuid, @token
      .end (error, response) =>
        return callback error if error?
        return callback new Error 'Invalid Response Code' unless response.ok
        callback null

  device: (uuid, callback) =>
    request
      .get @_url "/v2/devices/#{uuid}"
      .auth @uuid, @token
      .end (error, response) =>
        return callback error if error?
        return callback null if response.notFound
        return callback new Error 'Invalid Response Code' unless response.ok
        return callback new Error 'Invalid Response' if _.isEmpty response.body
        callback null, response.body

  devices: (query, callback) =>
    request
      .get @_url "/v2/devices"
      .auth @uuid, @token
      .query qs.stringify query
      .end (error, response) =>
        return callback error if error?
        return callback null if response.notFound
        return callback new Error 'Invalid Response Code' unless response.ok
        callback null, response.body ? []

  search: ({query, projection}, callback) =>
    projection ?= {}
    request
      .post @_url "/search/devices"
      .auth @uuid, @token
      .set 'X-MESHBLU-PROJECTION', JSON.stringify projection
      .send query
      .end (error, response) =>
        return callback error if error?
        return callback null if response.notFound
        return callback new Error 'Invalid Response Code' unless response.ok
        callback null, response.body ? []

  generateAndStoreToken: (uuid, options={}, callback) =>
    request
      .post @_url "/devices/#{uuid}/tokens"
      .auth @uuid, @token
      .send options
      .end (error, response) =>
        return callback error if error?
        return callback new Error 'Invalid Response Code' unless response.ok
        return callback new Error 'Invalid Response' if _.isEmpty response.body
        callback null, response.body

  listSubscriptions: ({subscriberUuid}, callback) =>
    request
      .get @_url "/v2/devices/#{subscriberUuid}/subscriptions"
      .auth @uuid, @token
      .end (error, response) =>
        return callback error if error?
        return callback new Error 'Invalid Response Code' unless response.ok
        callback null, response.body

  message: (message, callback) =>
   request
    .post @_url "/messages"
    .auth @uuid, @token
    .send message
    .end (error, response) =>
        return callback error if error?
        return callback new Error 'Invalid Message' unless response.ok
        callback null

  register: (body, callback) =>
    request
      .post @_url "/devices"
      .send body
      .end (error, response) =>
        return callback error if error?
        return callback null if response.notFound
        return callback new Error 'Invalid Response Code' unless response.ok
        return callback new Error 'Invalid Response' if _.isEmpty response.body
        callback null, response.body

  removeTokenByQuery: (uuid, options={}, callback) =>
    request
      .del @_url "/devices/#{uuid}/tokens"
      .query options
      .auth @uuid, @token
      .end (error, response) =>
        return callback error if error?
        return callback new Error 'Invalid Response Code' unless response.ok
        callback null

  revokeToken: (uuid, token, callback=->) =>
    request
      .del @_url "/devices/#{uuid}/tokens/#{token}"
      .auth @uuid, @token
      .end (error, response) =>
        return callback error if error?
        return callback new Error 'Invalid Response Code' unless response.ok
        callback null

  unregister: (uuid, callback) =>
    request
      .del @_url "/devices/#{uuid}"
      .auth @uuid, @token
      .end (error, response) =>
        return callback error if error?
        return callback new Error 'Invalid Response Code' unless response.ok
        callback null, response.body

  update: (uuid, body, callback) =>
    request
      .patch @_url "/v2/devices/#{uuid}"
      .auth @uuid, @token
      .send body
      .end (error, response) =>
        return callback error if error?
        return callback new Error 'Invalid Response Code' unless response.ok
        callback null, response.body

  updateDangerously: (uuid, body, callback) =>
    request
      .put @_url "/v2/devices/#{uuid}"
      .auth @uuid, @token
      .send body
      .end (error, response) =>
        return callback error if error?
        return callback new Error 'Invalid Response Code' unless response.ok
        callback null, response.body

  whoami: (callback) =>
    request
      .get @_url '/v2/whoami'
      .auth @uuid, @token
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

module.exports = MeshbluHttp
