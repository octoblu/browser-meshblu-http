shmock      = require '@octoblu/shmock'
MeshbluHttp = require '../'

describe 'Get Device', ->
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

    describe 'when the device has multiple devices (????)', ->
      beforeEach (done) ->
        auth = new Buffer('some-uuid:some-token').toString('base64')
        @getDevice = @meshblu
          .get '/v2/devices/hello-uuid'
          .set 'Authorization', "Basic #{auth}"
          .reply 200, uuid: 'hello-uuid'

        @sut.device "hello-uuid", (error, @device) => done error

      it 'should call get device', ->
        @getDevice.done()

      it 'should device', ->
        expect(@device).to.deep.equal uuid: 'hello-uuid'

    describe 'when called with "as" ', ->
      beforeEach (done) ->
        auth = new Buffer('some-uuid:some-token').toString('base64')
        @getDevice = @meshblu
          .get '/v2/devices/hello-uuid'
          .set 'Authorization', "Basic #{auth}"
          .set 'x-meshblu-as', '5'
          .reply 200, uuid: 'hello-uuid'

        @sut.device "hello-uuid", {as: '5'}, (error, @device) => done error

      it 'should call get device', ->
        @getDevice.done()

      it 'should device', ->
        expect(@device).to.deep.equal uuid: 'hello-uuid'
