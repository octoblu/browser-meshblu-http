shmock      = require '@octoblu/shmock'
MeshbluHttp = require '../'

describe 'Update', ->
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

    describe 'when the device has multiple devices', ->
      beforeEach (done) ->
        auth = new Buffer('some-uuid:some-token').toString('base64')
        @update = @meshblu
          .patch '/v2/devices/howdy-uuid'
          .set 'Authorization', "Basic #{auth}"
          .send type: 'flow', owner: 'hello-uuid'
          .reply 200, uuid: 'howdy-uuid', owner: 'hello-uuid', type: 'flow'

        @sut.update 'howdy-uuid', type: 'flow', owner: 'hello-uuid', (error, @device) => done error

      it 'should call get device', ->
        @update.done()

      it 'should have devices', ->
        expect(@device).to.deep.equal uuid: 'howdy-uuid', owner: 'hello-uuid', type: 'flow'
