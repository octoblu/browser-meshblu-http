shmock      = require '@octoblu/shmock'
MeshbluHttp = require '../'

describe 'Search Tokens', ->
  beforeEach ->
    @meshblu = shmock 0xd00d

  afterEach (done) ->
    @meshblu.close => done()

  describe 'when constructed with valid meshbluConfig', ->
    beforeEach ->
      meshbluConfig =
        hostname: 'localhost'
        port: 0xd00d
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
