shmock      = require '@octoblu/shmock'
MeshbluHttp = require '../'

describe 'Whoami', ->
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
        @whoami = @meshblu
          .get '/v2/whoami'
          .set 'Authorization', "Basic #{auth}"
          .reply 200,
            uuid: 'some-uuid',
            devices: [
              {uuid:'cheers-uuid'}
            ]

        @sut.whoami (error, @device) => done error

      it 'should call get device', ->
        @whoami.done()

      it 'should device', ->
        device =
          uuid: 'some-uuid',
          devices: [
            {uuid:'cheers-uuid'}
          ]
        expect(@device).to.deep.equal device

  describe 'when constructed with a bearerToken', ->
    beforeEach ->
      meshbluConfig =
        hostname: 'localhost'
        port: 0xd00d
        bearerToken: 'this-is-my-b64-encoded-token'

      @sut = new MeshbluHttp meshbluConfig

    describe 'when the device has devices', ->
      beforeEach (done) ->
        @whoami = @meshblu
          .get '/v2/whoami'
          .set 'Authorization', "Bearer this-is-my-b64-encoded-token"
          .reply 200,
            uuid: 'some-uuid',
            devices: [
              {uuid:'cheers-uuid'}
            ]

        @sut.whoami (error, @device) => done error

      it 'should call get device', ->
        @whoami.done()

      it 'should yield the device', ->
        device =
          uuid: 'some-uuid',
          devices: [
            {uuid:'cheers-uuid'}
          ]
        expect(@device).to.deep.equal device

describe 'when constructed with a url that goes nowhere', ->
  beforeEach ->
    meshbluConfig =
      hostname: 'localhost'
      port: 0xd00d
      uuid: 'some-uuid'
      token: 'some-token'

    @sut = new MeshbluHttp meshbluConfig

  describe 'when whoami is called', ->
    beforeEach (done) ->
      @sut.whoami (@error) => done()

    it "should yield an error instead of blowing up randomly someplace in the code we can't catch", ->
      expect(@error).to.exist
