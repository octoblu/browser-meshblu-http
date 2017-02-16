{afterEach, beforeEach, describe, it} = global
{expect}    = require 'chai'
shmock      = require '@octoblu/shmock'
MeshbluHttp = require '../'

describe 'Authenticate', ->
  beforeEach ->
    @meshblu = shmock()

  afterEach (done) ->
    @meshblu.close => done()

  describe 'when constructed with valid meshbluConfig', ->
    beforeEach ->
      meshbluConfig =
        hostname: 'localhost'
        port: @meshblu.address().port
        uuid: 'some-uuid'
        token: 'some-token'

      @sut = new MeshbluHttp meshbluConfig

    describe 'when authenticate succeeds', ->
      beforeEach (done) ->
        auth = new Buffer('some-uuid:some-token').toString('base64')
        @authenticate = @meshblu
          .post '/authenticate'
          .set 'Authorization', "Basic #{auth}"
          .reply 204

        @sut.authenticate done

      it 'should not error', ->
        # Getting here is good enough

      it 'should call /authenticate', ->
        @authenticate.done()

    describe 'when authenticate fails', ->
      beforeEach (done) ->
        auth = new Buffer('some-uuid:some-token').toString('base64')
        @authenticate = @meshblu
          .post '/authenticate'
          .set 'Authorization', "Basic #{auth}"
          .reply 403, 'Forbidden'

        @sut.authenticate (@error) => done()

      it 'should yield an error', ->
        expect(=> throw @error).to.throw 'Forbidden'

      it 'should call /authenticate', ->
        @authenticate.done()
