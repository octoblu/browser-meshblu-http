{afterEach, beforeEach, describe, it} = global
shmock        = require '@octoblu/shmock'
enableDestroy = require 'server-destroy'
MeshbluHttp   = require '../'

describe 'Remove Token by Query', ->
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

    describe 'when the device has devices', ->
      beforeEach (done) ->
        auth = new Buffer('some-uuid:some-token').toString('base64')
        @deleteToken = @meshblu
          .delete '/devices/hello-uuid/tokens'
          .query tag: 'remove-this-tag'
          .set 'Authorization', "Basic #{auth}"
          .reply 200

        @sut.removeTokenByQuery 'hello-uuid', tag: 'remove-this-tag', (error) => done error

      it 'should call delete token', ->
        @deleteToken.done()
