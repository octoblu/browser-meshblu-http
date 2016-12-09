{afterEach, beforeEach, describe, it} = global
{expect} = require 'chai'

shmock      = require '@octoblu/shmock'
MeshbluHttp = require '../'

describe 'Generate Token', ->
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
        @generateToken = @meshblu
          .post '/devices/hello-uuid/tokens'
          .set 'Authorization', "Basic #{auth}"
          .send tag: 'remove-this-tag'
          .reply 200, token: 'generated-token', uuid: 'some-uuid'

        @sut.generateAndStoreToken 'hello-uuid', tag: 'remove-this-tag', (error, @result) => done error

      it 'should call generate token', ->
        @generateToken.done()

      it 'should yield the generated token', ->
        expect(@result).to.deep.equal token: 'generated-token', uuid: 'some-uuid'
