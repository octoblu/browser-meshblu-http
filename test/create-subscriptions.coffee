shmock      = require '@octoblu/shmock'
MeshbluHttp = require '../'

describe 'Create Subscriptions', ->
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
        @createSubscription = @meshblu
          .post '/v2/devices/hello-uuid/subscriptions/howdy-uuid/broadcast'
          .set 'Authorization', "Basic #{auth}"
          .reply 204

        @sut.createSubscription {subscriberUuid: 'hello-uuid', emitterUuid: 'howdy-uuid', type: 'broadcast'}, (error, @result) => done error

      it 'should call create subscription', ->
        @createSubscription.done()

      it 'should yield an empty response', ->
        expect(@result).to.not.exist
