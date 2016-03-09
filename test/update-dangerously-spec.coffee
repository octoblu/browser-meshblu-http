shmock      = require '@octoblu/shmock'
MeshbluHttp = require '../'

describe 'Update Dangerously', ->
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
        query = {$set: type: 'flow', owner: 'hello-uuid'}
        @update = @meshblu
          .put '/v2/devices/howdy-uuid'
          .set 'Authorization', "Basic #{auth}"
          .send query
          .reply 200, uuid: 'howdy-uuid', owner: 'hello-uuid', type: 'flow'

        @sut.updateDangerously 'howdy-uuid', query, (error, @device) => done error

      it 'should call get device', ->
        @update.done()

      it 'should have devices', ->
        expect(@device).to.deep.equal uuid: 'howdy-uuid', owner: 'hello-uuid', type: 'flow'
