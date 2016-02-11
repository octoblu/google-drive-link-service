MeshbluHttp = require 'meshblu-http'
request     = require 'request'
moment      = require 'moment'

class googleDriveLinkService
  constructor: ({@meshbluConfig}) ->

  generate: ({token,downloadUrl,fileName}, callback) =>
    meshbluHttp = new MeshbluHttp @meshbluConfig
    privateKey = meshbluHttp.setPrivateKey @meshbluConfig.privateKey
    encryptedToken = privateKey.encrypt token, 'base64'
    encryptedDownloadUrl = privateKey.encrypt downloadUrl, 'base64'
    meshbluHttp.register googleDrive: {encryptedToken,encryptedDownloadUrl}, (error, device) =>
      return callback @_createError 500, error.message if error?
      link = "https://#{device.uuid}:#{device.token}@google-drive-link.octoblu.com/meshblu/links"
      callback null, {link,fileName}

  download: ({meshbluAuth}, callback) =>
    {device} = meshbluAuth
    {encryptedToken,encryptedDownloadUrl} = device.googleDrive
    return callback @_createError 422, 'Invalid Device' unless encryptedDownloadUrl?
    return callback @_createError 422, 'Invalid Device' unless encryptedToken?
    meshbluHttp = new MeshbluHttp @meshbluConfig
    privateKey = meshbluHttp.setPrivateKey @meshbluConfig.privateKey
    downloadUrl = privateKey.decrypt(encryptedDownloadUrl).toString()
    token = privateKey.decrypt(encryptedToken).toString()

    meshbluHttp = new MeshbluHttp meshbluAuth
    meshbluHttp.unregister uuid: meshbluAuth.uuid, (error) =>
      return callback @_createError 500, error.message if error?
      options =
        url: downloadUrl
        auth:
          bearer: token
      callback null, request.get options

  _createError: (code, message) =>
    error = new Error message
    error.code = code if code?
    return error

module.exports = googleDriveLinkService
