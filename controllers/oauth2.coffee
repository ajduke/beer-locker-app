mongoose= require('mongoose')
oauth2orize= require('oauth2orize')
User = require('../models/user')
Client= require('../models/client')
Code = require('../models/code')


# create Oauth 2.0 server
server = oauth2orize.createServer()

# register serialization function
server.serializeClient(( client, callback)->
    callback(null, client._id)
)


server.deserializeClient((id, callback)->
  Client.find({ _id: id }, (err, client)->
    if err
      callback(err)
    callback(null, client)
  )
)



# Register authorization code grant type
server.grant oauth2orize.grant.code((client, redirectUri, user, ares, callback) ->
# Create a new authorization code
  code = new Code(
    value: uid(16)
    clientId: client[0]._id
    redirectUri: redirectUri
    userId: user._id)
  # Save the auth code and check for errors
  code.save (err) ->
    if err
      return callback(err)
    callback null, code.value
)


server.exchange oauth2orize.exchange.code((client, code, redirectUri, callback) ->
  Code.findOne { value: code }, (err, authCode) ->
    if err
      return callback(err)
    if authCode == undefined
      return callback(null, false)
    if client._id.toString() != authCode.clientId
      return callback(null, false)
    if redirectUri != authCode.redirectUri
      return callback(null, false)
    # Delete auth code now that it has been used
    authCode.remove (err) ->
      if err
        return callback(err)
      # Create a new access tokenf
      Token = mongoose.model('tokenSchema')
      token = new Token({
          value: uid(256)
          clientId: authCode.clientId
          userId: authCode.userId
        })
      # Save the access token and check for errors
      token.save (err) ->
        if err
          return callback(err)
        callback null, token
)


exports.authorization = [
  server.authorization((clientId, redirectUri, callback) ->
    Client.findOne { id: clientId }, (err, client) ->
      if err
        return callback(err)
      callback null, client, redirectUri
    return
  )
  (req, res) ->
    res.render 'dialog',
      transactionID: req.oauth2.transactionID
      user: req.user
      client: req.oauth2.client
    return
]



exports.decision = [
  server.decision()
]

exports.token = [
  server.token(),
  server.errorHandler()
]


uid = (len) ->
  buf = []
  chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
  charlen = chars.length
  i = 0
  while i < len
    buf.push chars[getRandomInt(0, charlen - 1)]
    ++i
  buf.join ''

getRandomInt = (min, max) ->
  Math.floor(Math.random() * (max - min + 1)) + min
