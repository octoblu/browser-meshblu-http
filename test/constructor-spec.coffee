shmock      = require '@octoblu/shmock'
MeshbluHttp = require '../'

describe 'constructor', ->
  describe 'when constructed with a meshbluConfig with a "server" property but no "hostname"', ->
    beforeEach ->
      @meshbluConfig =
        server: 'not-catching-this-causes-weird-problems'
        port: 0xd00d
        uuid: 'some-uuid'
        token: 'some-token'

      try
        new MeshbluHttp @meshbluConfig
      catch error
        @error = error

    it 'should blow up and tell you why', ->
      expect(@error).to.exist
      expect(@error.message).to.equal "MeshbluHttp only allows hostname: 'server' is not allowed"

  describe 'when constructed with a meshbluConfig with a "host" property"', ->
    beforeEach ->
      @meshbluConfig =
        host: 'not-catching-this-causes-weird-problems'
        port: 0xd00d
        uuid: 'some-uuid'
        token: 'some-token'

      try
        new MeshbluHttp @meshbluConfig
      catch error
        @error = error

    it 'should blow up and tell you why', ->
      expect(@error).to.exist
      expect(@error.message).to.equal "MeshbluHttp only allows hostname: 'host' is not allowed"


  describe 'when constructed with a meshbluConfig with a "hostname" property', ->
    beforeEach ->
      @meshbluConfig =      
        hostname: 'julius-caesar'
        port: 0xd00d
        uuid: 'some-uuid'
        token: 'some-token'

      try
        new MeshbluHttp @meshbluConfig
      catch error
        @error = error

    it 'should be ok with it', ->
      expect(@error).not.to.exist
