shmock      = require '@octoblu/shmock'
MeshbluHttp = require '../'

describe 'Unregister', ->
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

    describe 'when the device has multiple devices', ->
      beforeEach (done) ->
        auth = new Buffer('some-uuid:some-token').toString('base64')
        @unregister = @meshblu
          .delete '/devices/howdy-uuid'
          .set 'Authorization', "Basic #{auth}"
          .reply 204

        @sut.unregister 'howdy-uuid', (error) => done error

      it 'should call get device', ->
        @unregister.done()
