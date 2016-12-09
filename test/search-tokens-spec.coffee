{afterEach, beforeEach, describe, it} = global
{expect} = require 'chai'

shmock        = require '@octoblu/shmock'
enableDestroy = require 'server-destroy'
MeshbluHttp   = require '../'

describe 'Search Tokens', ->
  beforeEach ->
    @meshblu = shmock()
    enableDestroy @meshblu

  afterEach (done) ->
    @meshblu.destroy done

  describe 'when constructed with valid meshbluConfig', ->
    beforeEach ->
      meshbluConfig =
        hostname: 'localhost'
        port: @meshblu.address().port
        uuid: 'some-uuid'
        token: 'some-token'

      @sut = new MeshbluHttp meshbluConfig

    describe 'when the token has multiple tokens', ->
      beforeEach (done) ->
        auth = new Buffer('some-uuid:some-token').toString('base64')
        @getTokens = @meshblu
          .post '/search/tokens'
          .set 'Authorization', "Basic #{auth}"
          .reply 200, [
            uuid: 'howdy-uuid', metadata: tag: 'test'
          ]

        query = 'metadata.tag': 'test'
        @sut.searchTokens {query}, (error, @tokens) => done error

      it 'should call get token', ->
        @getTokens.done()

      it 'should have tokens', ->
        expect(@tokens).to.deep.equal [
          uuid: 'howdy-uuid', metadata: tag: 'test'
        ]
