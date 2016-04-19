shmock      = require '@octoblu/shmock'
MeshbluHttp = require '../'

describe 'Message', ->
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

    describe 'when sending a message', ->
      beforeEach (done) ->
        auth = new Buffer('some-uuid:some-token').toString('base64')
        @messages = @meshblu
          .post '/messages'
          .set 'Authorization', "Basic #{auth}"
          .reply 204

        @sut.message devices: ['*'], (error, @devices) => done error

      it 'should call message', ->
        @messages.done()
