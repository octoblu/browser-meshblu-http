MeshbluRequest = require './meshblu-request.coffee'

#It's dumb, but it saves ~60k!
defaults      = require 'lodash/defaults'
extend        = require 'lodash/extend'
isEmpty       = require 'lodash/isEmpty'
isString      = require 'lodash/isString'
isBoolean     = require 'lodash/isBoolean'
isNumber      = require 'lodash/isNumber'
isPlainObject = require 'lodash/isPlainObject'
transform     = require 'lodash/transform'
kebabCase     = require 'lodash/kebabCase'
_             = {defaults, extend, isEmpty, isString, isBoolean, isNumber, isPlainObject, transform, kebabCase}

class MeshbluHttp
  constructor: (meshbluConfig) ->
    throw new Error("MeshbluHttp only allows hostname: 'server' is not allowed") if meshbluConfig?.server
    throw new Error("MeshbluHttp only allows hostname: 'host' is not allowed") if meshbluConfig?.host

    options = _.extend port: 443, hostname: 'meshblu-http.octoblu.com', meshbluConfig

    {
      @uuid
      @token
      @bearerToken
      protocol
      hostname
      port
      resolveSrv
      domain
      service
      secure
      serviceName
    } = options

    protocol = null if protocol == 'websocket'
    try port = parseInt port
    protocol ?= 'https:' if port == 443
    protocol ?= 'http:'
    secure   ?= true
    domain   ?= 'octoblu.com'
    service  ?= 'meshblu'

    @request = new MeshbluRequest {protocol, hostname, port, resolveSrv, domain, service, secure, serviceName}

  authenticate: (callback) =>
    options = @_getDefaultRequestOptions()
    @request.post "/authenticate", options, callback

  claimdevice: (uuid, callback) =>
    options = @_getDefaultRequestOptions()
    @request.post "/claimdevice/#{uuid}", options, callback

  createSubscription: ({subscriberUuid, emitterUuid, type}, callback) =>
    options = @_getDefaultRequestOptions()
    @request.post "/v2/devices/#{subscriberUuid}/subscriptions/#{emitterUuid}/#{type}", options, (error, response) =>
      return callback error if error?
      return callback null if _.isEmpty response
      return callback null, response

  deleteSubscription: ({subscriberUuid, emitterUuid, type}, callback) =>
    options = @_getDefaultRequestOptions()
    @request.delete "/v2/devices/#{subscriberUuid}/subscriptions/#{emitterUuid}/#{type}", options, (error, response) =>
      return callback error if error?
      return callback null if _.isEmpty response
      return callback null, response

  device: (uuid, rest...) =>
    [callback] = rest
    [metadata, callback] = rest if _.isPlainObject callback
    metadata ?= {}
    @_device uuid, metadata, callback

  _device: (uuid, metadata, callback=->) =>
    options = @_getDefaultRequestOptions()
    options.headers = _.extend {}, @_getMetadataHeaders(metadata), options.headers
    @request.get "/v2/devices/#{uuid}", options, callback

  devices: (query, callback) =>
    options = @_getDefaultRequestOptions()
    options.query = query
    @request.get "/v2/devices", options, callback

  search: ({query, projection, as}, callback) =>
    options = @_getDefaultRequestOptions()
    options.body = query
    options.headers ?= {}
    options.headers['X-MESHBLU-PROJECTION'] = JSON.stringify projection if projection?
    options.headers['X-MESHBLU-AS'] = as if as?

    @request.post '/search/devices', options, (error, response=[]) =>
      return callback error if error?
      return callback null, response

  searchTokens: ({query, projection}, callback) =>
    options = @_getDefaultRequestOptions()
    options.body = query
    options.headers ?= {}
    options.headers['X-MESHBLU-PROJECTION'] = JSON.stringify projection if projection?

    @request.post '/search/tokens', options, (error, response=[]) =>
      return callback error if error?
      return callback null, response

  generateAndStoreToken: (uuid, query={}, callback) =>
    options = @_getDefaultRequestOptions()
    options.body = query
    @request.post "/devices/#{uuid}/tokens", options, (error, response) =>
      return callback error if error?
      return callback new Error 'Invalid Response' if _.isEmpty response
      callback null, response

  listSubscriptions: ({subscriberUuid}, callback) =>
    options = @_getDefaultRequestOptions()
    @request.get "/v2/devices/#{subscriberUuid}/subscriptions", options, callback

  message: (message, callback) =>
    options = @_getDefaultRequestOptions()
    options.body = message
    @request.post "/messages", options, callback

  register: (body, callback) =>
    options = @_getDefaultRequestOptions()
    options.body = body
    @request.post "/devices", options, (error, response) =>
      return callback error if error?
      return callback new Error 'Invalid Response' if _.isEmpty response
      callback null, response

  removeTokenByQuery: (uuid, query={}, callback) =>
    console.log 'removeTokenByQuery', uuid, query
    options = @_getDefaultRequestOptions()
    options.query = query
    @request.delete "/devices/#{uuid}/tokens", options, callback

  revokeToken: (uuid, token, callback=->) =>
    options = @_getDefaultRequestOptions()
    @request.delete "/devices/#{uuid}/tokens/#{token}", options, callback

  unregister: (uuid, callback) =>
    options = @_getDefaultRequestOptions()
    @request.delete "/devices/#{uuid}", options, callback

  update: (uuid, body, callback) =>
    options = @_getDefaultRequestOptions()
    options.body = body
    @request.patch "/v2/devices/#{uuid}", options, callback

  updateDangerously: (uuid, body, callback) =>
    options = @_getDefaultRequestOptions()
    options.body = body
    @request.put "/v2/devices/#{uuid}", options, callback

  whoami: (callback) =>
    options = @_getDefaultRequestOptions()
    @request.get "/v2/whoami", options, (error, response) =>
      return callback error if error?
      return callback new Error 'Invalid Response' if _.isEmpty response
      callback null, response

  _getDefaultRequestOptions: =>
    return { @uuid, @token, @bearerToken }

  _getMetadataHeaders: (metadata) =>
    _.transform metadata, (newMetadata, value, key) =>
      kebabKey = _.kebabCase key
      newMetadata["x-meshblu-#{kebabKey}"] = @_possiblySerializeHeaderValue value
      return true
    , {}

  # because request doesn't serialize arrays correctly for headers.
  _possiblySerializeHeaderValue: (value) =>
    return value if _.isString value
    return value if _.isBoolean value
    return value if _.isNumber value
    return JSON.stringify value

module.exports = MeshbluHttp
