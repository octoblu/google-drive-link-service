http        = require 'http'
request     = require 'request'
MeshbluHttp = require 'meshblu-http'
shmock      = require '@octoblu/shmock'
Server      = require '../../src/server'

describe 'Generate', ->
  before ->
    @timeout 20000
    meshbluHttp = new MeshbluHttp({})
    {@privateKey, publicKey} = meshbluHttp.generateKeyPair()

    @privateKeyObj = meshbluHttp.setPrivateKey @privateKey

  beforeEach (done) ->
    @meshblu = shmock 0xd00d

    serverOptions =
      port: undefined,
      disableLogging: true

    meshbluConfig =
      server: 'localhost'
      port: 0xd00d
      privateKey: @privateKey

    @server = new Server serverOptions, {meshbluConfig}

    @server.run =>
      @serverPort = @server.address().port
      done()

  afterEach (done) ->
    @server.stop done

  afterEach (done) ->
    @meshblu.close done

  describe 'On POST /google-drive/links', ->
    describe 'when bearer method is used', ->
      beforeEach (done) ->
        @registerDevice = @meshblu
          .post '/devices'
          .reply 201,
            uuid: 'one-time-device-uuid'
            token: 'one-time-device-token'

        options =
          uri: '/google-drive/links'
          baseUrl: "http://localhost:#{@serverPort}"
          auth:
            bearer: 'oh-this-is-my-bearer-token'
          json:
            fileName: 'File Name'
            downloadUrl: 'http://some-crazy-url'

        request.post options, (error, @response, @body) =>
          done error

      it 'should return a 201', ->
        expect(@response.statusCode).to.equal 201

      it 'should register the device', ->
        @registerDevice.done()

      it 'should respond with the link', ->
        expect(@body.link).to.equal 'https://one-time-device-uuid:one-time-device-token@google-drive-link.octoblu.com/meshblu/links'
        expect(@body.fileName).to.equal 'File Name'


    describe 'when access_token_query method is used',->
      beforeEach (done) ->
        @registerDevice = @meshblu
          .post '/devices'
          .reply 201,
            uuid: 'one-time-device-uuid'
            token: 'one-time-device-token'

        options =
          uri: '/google-drive/links'
          baseUrl: "http://localhost:#{@serverPort}"
          qs:
            access_token: 'oh-this-is-my-bearer-token'
          json:
            fileName: 'File Name'
            downloadUrl: 'http://some-crazy-url'

        request.post options, (error, @response, @body) =>
          done error

      it 'should return a 201', ->
        expect(@response.statusCode).to.equal 201

      it 'should register the device', ->
        @registerDevice.done()

      it 'should respond with the link', ->
        expect(@body.link).to.equal 'https://one-time-device-uuid:one-time-device-token@google-drive-link.octoblu.com/meshblu/links'
        expect(@body.fileName).to.equal 'File Name'
