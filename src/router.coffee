GoogleDriveLinkController = require './controllers/google-drive-link-controller'
bearerToken           = require 'express-bearer-token'
meshbluAuth           = require 'express-meshblu-auth'
class Router
  constructor: ({@googleDriveLinkService, @meshbluConfig}) ->
  route: (app) =>
    googleDriveLinkController = new GoogleDriveLinkController {@googleDriveLinkService}
    app.use '/google-drive', bearerToken()
    app.use '/meshblu', meshbluAuth(@meshbluConfig)

    app.post '/google-drive/links', googleDriveLinkController.generate
    app.get '/meshblu/links', googleDriveLinkController.download
    # e.g. app.put '/resource/:id', someController.update

module.exports = Router
