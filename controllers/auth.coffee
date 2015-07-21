passport = require('passport')
BasicStrategy = require('passport-http').BasicStrategy
User = require('../models/user')
BearerStrategy = require('passport-http-bearer').Strategy
mongoose= require('mongoose')
Token = mongoose.model('tokenSchema')
Client= require('../models/client')

passport.use(
  new BasicStrategy( (username, password, callback)->
    User.findOne({ username: username }, (err, user)->
      if err
        return callback(err)

      if !user
        return callback(null, false)
      user.verifyPassword(password, (err, isMatch)->
        if err
          return callback(err)

        if (!isMatch)
          return callback(null, false)
        return callback(null, user)
      )
    )
  )
)

passport.use new BearerStrategy((accessToken, callback) ->
  Token.findOne { value: accessToken }, (err, token) ->
    if err
      return callback(err)
    # No token found
    if !token
      return callback(null, false)
    User.findOne { _id: token.userId }, (err, user) ->
      if err
        return callback(err)
      # No user found
      if !user
        return callback(null, false)
      # Simple example with no scope
      callback null, user, scope: '*'
)


# during initial auth, while fetching code 
passport.use 'client-basic', new BasicStrategy((username, password, callback) ->
  Client.findOne { id: username }, (err, client) ->
    if err
      return callback(err)
    # No client found with that id or bad password
    if !client or client.secret != password
      return callback(null, false)
    # Success
    callback null, client
)


exports.isAuthenticated = passport.authenticate(['basic', 'bearer'], { session : false })

exports.isClientAuthenticated = passport.authenticate('client-basic',{session: false})

exports.isBearerAuthenticated = passport.authenticate('bearer', {session: false})

