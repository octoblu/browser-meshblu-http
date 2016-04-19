shmock      = require '@octoblu/shmock'
MeshbluHttp = require '../'

describe 'List Subscriptions', ->
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
        @listSubscriptions = @meshblu
          .get '/v2/devices/hello-uuid/subscriptions'
          .set 'Authorization', "Basic #{auth}"
          .reply 204, [{subscriberUuid: 'a-uuid'}]

        @sut.listSubscriptions {subscriberUuid: 'hello-uuid', emitterUuid: 'howdy-uuid', type: 'broadcast'}, (error, @result) => done error

      it 'should call list subscription', ->
        @listSubscriptions.done()

      it 'should yield a response', ->
        expect(@result).to.exist
