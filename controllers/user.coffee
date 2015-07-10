User = require('../models/user');

exports.postUsers = (req, res)->
  user = new User(
    username: req.body.username
    password: req.body.password
  )

  user.save((err)->
    if (err)
      res.send(err)

    res.json({ message: 'New beer drinker added to the locker room!' })
  )

exports.getUsers = (req, res) ->
  User.find((err, users)->
    if (err)
      res.send(err)

    res.json(users)
  )