shmock      = require '@octoblu/shmock'
MeshbluHttp = require '../'

describe 'Get Devices', ->
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
        @getDevices = @meshblu
          .get '/v2/devices'
          .query type: 'flow', owner: 'hello-uuid'
          .set 'Authorization', "Basic #{auth}"
          .reply 200, [
            uuid: 'howdy-uuid', owner: 'hello-uuid', type: 'flow'
          ]

        @sut.devices type: 'flow', owner: 'hello-uuid', (error, @devices) => done error

      it 'should call get device', ->
        @getDevices.done()

      it 'should have devices', ->
        expect(@devices).to.deep.equal [
          uuid: 'howdy-uuid', owner: 'hello-uuid', type: 'flow'
        ]

    describe 'when performing a complex query', ->
      beforeEach (done) ->
        auth = new Buffer('some-uuid:some-token').toString('base64')
        @getDevices = @meshblu
          .get '/v2/devices'
          .query {uuid: {$in: ['howdy-uuid']}}
          .set 'Authorization', "Basic #{auth}"
          .reply 200, [
            uuid: 'howdy-uuid', owner: 'hello-uuid', type: 'flow'
          ]

        @sut.devices {uuid: {$in: ['howdy-uuid']}}, (error, @devices) => done error

      it 'should call get device', ->
        @getDevices.done()

      it 'should have devices', ->
        expect(@devices).to.deep.equal [
          uuid: 'howdy-uuid', owner: 'hello-uuid', type: 'flow'
        ]
