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
