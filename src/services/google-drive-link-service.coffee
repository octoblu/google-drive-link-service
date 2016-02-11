MeshbluHttp = require 'meshblu-http'
request     = require 'request'
moment      = require 'moment'

class googleDriveLinkService
  constructor: ({@meshbluConfig,@googleDriveServiceUri}) ->

  generate: ({token,fileId,fileName}, callback) =>
    meshbluHttp = new MeshbluHttp @meshbluConfig
    privateKey = meshbluHttp.setPrivateKey @meshbluConfig.privateKey
    encryptedToken = privateKey.encrypt token, 'base64'
    encryptedFileId = privateKey.encrypt fileId, 'base64'
    meshbluHttp.register googleDrive: {encryptedToken,encryptedFileId}, (error, device) =>
      return callback @_createError 500, error.message if error?
      link = "https://#{device.uuid}:#{device.token}@google-drive-link.octoblu.com/meshblu/links"
      callback null, {link,fileName}

  download: ({meshbluAuth}, callback) =>
    {device} = meshbluAuth
    {encryptedToken,encryptedFileId} = device.googleDrive
    return callback @_createError 422, 'Invalid Device' unless encryptedFileId?
    return callback @_createError 422, 'Invalid Device' unless encryptedToken?
    meshbluHttp = new MeshbluHttp @meshbluConfig
    privateKey = meshbluHttp.setPrivateKey @meshbluConfig.privateKey
    fileId = privateKey.decrypt(encryptedFileId).toString()
    token = privateKey.decrypt(encryptedToken).toString()

    meshbluHttp = new MeshbluHttp meshbluAuth
    meshbluHttp.unregister uuid: meshbluAuth.uuid, (error) =>
      return callback @_createError 500, error.message if error?
      options =
        baseUrl: @googleDriveServiceUri
        uri: "/files/#{fileId}"
        auth:
          bearer: token
      callback null, request.get options

  _createError: (code, message) =>
    error = new Error message
    error.code = code if code?
    return error

module.exports = googleDriveLinkService
