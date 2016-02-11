class googleDriveLinkController
  constructor: ({@googleDriveLinkService}) ->

  generate: (request, response) =>
    {token} = request
    {fileId} = request.params
    {fileName} = request.body
    return response.sendStatus(422) unless fileId?
    token ?= request.query.access_token
    return response.sendStatus(422) unless token?

    @googleDriveLinkService.generate {token, fileId, fileName}, (error, body) =>
      return response.status(error.code || 500).send(error: error.message) if error?
      response.status(201).send body

  download: (request, response) =>
    {meshbluAuth} = request
    @googleDriveLinkService.download {meshbluAuth}, (error, requestStream) =>
      return response.status(error.code || 500).send(error: error.message) if error?
      requestStream.pipe response

module.exports = googleDriveLinkController
