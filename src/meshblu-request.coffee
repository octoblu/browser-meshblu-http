dns        = require 'http-dns'
qs         = require 'qs'
superagent = require 'superagent'
url        = require 'url'

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
}

discardReturn = require './discard-return.coffee'

class MeshbluRequest
  constructor: (options={}) ->
    {@protocol, @hostname, @port} = options
    {@service, @domain, @secure, @resolveSrv} = options
    {@dnsHttpServer} = options

  delete: (pathname, options, callback) =>
    requestOptions = _.pick(options, 'uuid', 'token', 'bearerToken', 'headers')
    requestOptions.pathname = pathname
    query = qs.stringify options.query

    @_resolveBaseUrl (error, baseUri) =>
      return callback error if error?
      @_request('delete', baseUri, requestOptions).query(query).end @_handleResponse(callback)

  get: (pathname, options, callback) =>
    requestOptions = _.pick(options, 'uuid', 'token', 'bearerToken', 'headers')
    requestOptions.pathname = pathname
    query = qs.stringify options.query

    @_resolveBaseUrl (error, baseUri) =>
      return callback error if error?
      @_request('get', baseUri, requestOptions).query(query).end @_handleResponse(callback)

  patch: (pathname, options, callback) =>
    requestOptions = _.pick(options, 'uuid', 'token', 'bearerToken', 'headers')
    requestOptions.pathname = pathname
    body = options.body

    @_resolveBaseUrl (error, baseUri) =>
      return callback error if error?
      @_request('patch', baseUri, requestOptions).send(body).end @_handleResponse(callback)

  post: (pathname, options, callback) =>
    requestOptions = _.pick(options, 'uuid', 'token', 'bearerToken', 'headers')
    requestOptions.pathname = pathname
    body = options.body

    @_resolveBaseUrl (error, baseUri) =>
      return callback error if error?
      @_request('post', baseUri, requestOptions).send(body).end @_handleResponse(callback)

  put: (pathname, options, callback) =>
    requestOptions = _.pick(options, 'uuid', 'token', 'bearerToken', 'headers')
    requestOptions.pathname = pathname
    body = options.body

    @_resolveBaseUrl (error, baseUri) =>
      return callback error if error?
      @_request('put', baseUri, requestOptions).send(body).end @_handleResponse(callback)

  _getDomain: =>
    parts       = _.split @hostname, '.'
    domainParts = _.takeRight parts, 2
    return _.join domainParts, '.'

  _getSrvAddress: =>
    return "_#{@service}._#{@_getSrvProtocol()}.#{@domain}"

  _getSrvProtocol: =>
    return 'https' if @secure
    return 'http'

  _getSubdomain: =>
    parts          = _.split @hostname, '.'
    subdomainParts = _.dropRight parts, 2
    return _.join subdomainParts, '.'

  _handleResponse: (callback) => (error, response) =>
    return callback error if error?
    return callback null if response.notFound
    return callback new Error 'Invalid Response Code' unless response.ok
    return callback null, response.body

  _request: (method, baseUri, {pathname, uuid, token, bearerToken, headers}) =>
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

    return callback null, url.format {@protocol, @hostname, @port} unless @resolveSrv

    dns.resolveSrv @_getSrvAddress(), (error, addresses) =>
      return callback error if error?
      return callback new Error('SRV record found, but contained no valid addresses') if _.isEmpty addresses
      return callback null, @_resolveUrlFromAddresses(addresses)

  _resolveUrlFromAddresses: (addresses) =>
    address = _.minBy addresses, 'priority'
    return url.format {
      protocol: @_getSrvProtocol()
      hostname: address.name
      port: address.port
    }

  _url: (baseUri, pathname) =>
    {protocol, hostname, port} = url.parse baseUri
    return url.format({ hostname, protocol, port, pathname })

module.exports = MeshbluRequest
