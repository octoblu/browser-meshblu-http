{afterEach, beforeEach, describe, it} = global
{expect}      = require 'chai'
shmock        = require '@octoblu/shmock'
enableDestroy = require 'server-destroy'
MeshbluHttp = require '../'

describe 'Search Devices', ->
  beforeEach ->
    @meshblu = shmock()
    enableDestroy @meshblu

  afterEach (done) ->
    @meshblu.destroy done

  describe 'when constructed with valid meshbluConfig', ->
    beforeEach ->
      meshbluConfig =
        hostname: 'localhost'
        port: @meshblu.address().port
        uuid: 'some-uuid'
        token: 'some-token'

      @sut = new MeshbluHttp meshbluConfig

    describe 'when the device has multiple devices', ->
      beforeEach (done) ->
        auth = new Buffer('some-uuid:some-token').toString('base64')
        @getDevices = @meshblu
          .post '/search/devices'
          .set 'Authorization', "Basic #{auth}"
          .reply 200, [
            uuid: 'howdy-uuid', owner: 'hello-uuid', type: 'flow'
          ]

        query = type: 'flow', owner: 'hello-uuid'
        @sut.search {query}, (error, @devices) => done error

      it 'should call get device', ->
        @getDevices.done()

      it 'should have devices', ->
        expect(@devices).to.deep.equal [
          uuid: 'howdy-uuid', owner: 'hello-uuid', type: 'flow'
        ]
