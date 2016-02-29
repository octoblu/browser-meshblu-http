shmock      = require '@octoblu/shmock'
MeshbluHttp = require '../'

describe 'Remove Token', ->
  beforeEach ->
    @meshblu = shmock 0xd00d

  afterEach (done) ->
    @meshblu.close => done()

  describe 'when constructed with valid meshbluConfig', ->
    beforeEach ->
      meshbluConfig =
        server: 'localhost'
        port: 0xd00d
        uuid: 'some-uuid'
        token: 'some-token'

      @sut = new MeshbluHttp meshbluConfig

    describe 'when the device has devices', ->
      beforeEach (done) ->
        auth = new Buffer('some-uuid:some-token').toString('base64')
        @deleteToken = @meshblu
          .delete '/devices/hello-uuid/tokens'
          .query tag: 'remove-this-tag'
          .set 'Authorization', "Basic #{auth}"
          .reply 200

        @sut.removeTokenByQuery 'hello-uuid', tag: 'remove-this-tag', (error) => done error

      it 'should call delete token', ->
        @deleteToken.done()
