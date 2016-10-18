octobluExpress         = require 'express-octoblu'
enableDestroy          = require 'server-destroy'
MeshbluConfig          = require 'meshblu-config'
Router                 = require './router'
GoogleDriveLinkService = require './services/google-drive-link-service'
debug                  = require('debug')('google-drive-link-service:server')

class Server
  constructor: ({@disableLogging, @port}, {@meshbluConfig})->
    @meshbluConfig ?= new MeshbluConfig().toJSON()

  address: =>
    @server.address()

  run: (callback) =>
    app = octobluExpress()

    googleDriveLinkService = new GoogleDriveLinkService {@meshbluConfig}

    router = new Router {googleDriveLinkService,@meshbluConfig}

    router.route app

    @server = app.listen @port, callback
    enableDestroy @server

  stop: (callback) =>
    @server.close callback

  destroy: =>
    @server.destroy()

module.exports = Server
