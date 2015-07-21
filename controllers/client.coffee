Client= require('../models/client')

exports.postClients= (req, res)->
  client = new Client()

  client.name= req.body.name
  client.id= req.body.id
  client.secret= req.body.secret
  client.userId= req.user._id

  client.save((err)->
    if err?
      res.send(err)
      return

    res.json(
      message: "Client added to locker"
      data: client
    )
  )


exports.getClients= (req, res)->
  Client.find({userId: req.user._id}, (err,clients)->
    if err?
      res.send(err)
      return

    res.json(clients)
  )

