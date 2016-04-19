shmock      = require '@octoblu/shmock'
MeshbluHttp = require '../'

describe 'Revoke Token', ->
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

    describe 'when the device has devices', ->
      beforeEach (done) ->
        auth = new Buffer('some-uuid:some-token').toString('base64')
        @deleteToken = @meshblu
          .delete '/devices/hello-uuid/tokens/this-token'
          .set 'Authorization', "Basic #{auth}"
          .reply 200

        @sut.revokeToken 'hello-uuid', 'this-token', (error) => done error

      it 'should call delete token', ->
        @deleteToken.done()
