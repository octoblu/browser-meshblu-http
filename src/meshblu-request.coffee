qs          = require 'qs'
SrvFailover = require 'srv-failover'
superagent  = require 'superagent'
URL         = require 'url'

_ = {
  defaults:  require 'lodash/defaults'
  dropRight: require 'lodash/dropRight'
  each:      require 'lodash/each'
  isEmpty:   require 'lodash/isEmpty'
  join:      require 'lodash/join'
  minBy:     require 'lodash/minBy'
  pick:      require 'lodash/pick'
  split:     require 'lodash/split'
  takeRight: require 'lodash/takeRight'
  toLower:   require 'lodash/toLower'
}
_ = require 'lodash'

discardReturn = require './discard-return.coffee'

class MeshbluRequest
  constructor: (options={}) ->
    {@protocol, @hostname, @port} = options
    {service, domain, secure, resolveSrv} = options
    {@dnsHttpServer} = options

    return unless resolveSrv
    protocol = 'http'
    protocol = 'https' if secure
    @srvFailover = new SrvFailover {domain, service, protocol}

  delete: (pathname, options, callback) =>
    requestOptions = _.pick(options, 'uuid', 'token', 'bearerToken', 'headers')
    requestOptions.pathname = pathname
    query = qs.stringify options.query

    @_resolveBaseUrl (error, baseUri) =>
      return callback error if error?
      @_doRequest({method: 'delete', baseUri, requestOptions, query}, callback)

  get: (pathname, options, callback) =>
    requestOptions = _.pick(options, 'uuid', 'token', 'bearerToken', 'headers')
    requestOptions.pathname = pathname
    query = qs.stringify options.query

    @_resolveBaseUrl (error, baseUri) =>
      return callback error if error?
      @_doRequest({method: 'get', baseUri, requestOptions, query}, callback)

  patch: (pathname, options, callback) =>
    requestOptions = _.pick(options, 'uuid', 'token', 'bearerToken', 'headers')
    requestOptions.pathname = pathname
    body = options.body

    @_resolveBaseUrl (error, baseUri) =>
      return callback error if error?
      @_doRequest({method: 'patch', baseUri, requestOptions, body}, callback)

  post: (pathname, options, callback) =>
    requestOptions = _.pick(options, 'uuid', 'token', 'bearerToken', 'headers')
    requestOptions.pathname = pathname
    body = options.body

    @_resolveBaseUrl (error, baseUri) =>
      return callback error if error?
      @_doRequest({method: 'post', baseUri, requestOptions, body}, callback)

  put: (pathname, options, callback) =>
    requestOptions = _.pick(options, 'uuid', 'token', 'bearerToken', 'headers')
    requestOptions.pathname = pathname
    body = options.body

    @_resolveBaseUrl (error, baseUri) =>
      return callback error if error?
      @_doRequest({method: 'put', baseUri, requestOptions, body}, callback)

  _doRequest: ({method, baseUri, requestOptions, query, body}, callback) =>
    @_request(method, baseUri, requestOptions).query(query).send(body).end (error, response)=>
      if error?.crossDomain
        return @_retrySrvRequest(error, @_doRequest, {method, baseUri, requestOptions, query, body}, callback)
      @_handleResponse(callback)(error, response)

  _handleResponse: (callback) => (error, response) =>
    return callback error if error?
    return callback null if response.notFound
    return callback new Error 'Invalid Response Code' unless response.ok
    return callback null, response.body

  _request: (method, baseUri, {pathname, uuid, token, bearerToken, headers}) =>
    method = _.toLower method
    theRequest = superagent[method](@_url baseUri, pathname)
    theRequest.auth uuid, token if uuid? && token?
    theRequest.set('Authorization', "Bearer #{bearerToken}") if bearerToken?
    theRequest.accept('application/json')
    theRequest.set('Content-Type', 'application/json')
    _.each headers, (value, key) =>
      theRequest.set key, value
    return theRequest

  _resolveBaseUrl: (cb) =>
    callback = discardReturn cb

    return callback null, URL.format {@protocol, @hostname, @port} unless @srvFailover?
    @srvFailover.resolveUrl cb

  _retrySrvRequest: (error, request, options, callback) =>
    return callback error unless @srvFailover?

    {method, baseUri, requestOptions, query, body} = options
    @srvFailover.markBadUrl baseUri, ttl: 60000
    @srvFailover.resolveUrl (error, baseUri) =>
      return callback error if error?
      return request {method, baseUri, requestOptions, query, body}, callback

  _url: (baseUri, pathname) =>
    {protocol, hostname, port} = URL.parse baseUri
    return URL.format({ hostname, protocol, port, pathname })

module.exports = MeshbluRequest
