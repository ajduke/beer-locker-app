Beer= require('../models/beer')

exports.postBeers= (req, res)->
  beer= new Beer()
  beer.name= req.body.name
  beer.type= req.body.type
  beer.quantity= req.body.quantity
  beer.userId= req.user._id

  beer.save((err)->
    if err
      res.send(err)
      console.log 'some err here '
      return
    res.send({message:"Beer added to locker ", data: beer})
  )

exports.getBeers = (req, res)->
  Beer.find({userId: req.user._id},(err, beers)->
    if err?
      res.send(err)

    res.json(beers)
  )

exports.getBeer= (req, res)->
  Beer.findById({_id:req.params.beer_id, userId: req.user._id}, (err, beer)->
    if err?
      res.send(err)
    res.json(beer)
  )

exports.putBeer= (req, res)->
  Beer.findById({_id:req.params.beer_id, userId: req.user._id}, (err, beer)->
    if err?
      res.send(err)

    beer.quantity= req.body.quantity

    beer.save((err)->
      if err?
        res.send(err)
      res.json(beer)
    )
  )

exports.deleteBeer =(req,res)->
  Beer.findByIdAndRemove({_id:req.params.beer_id, userId: req.user._id}, (err)->
    if err?
      res.send(err)
    res.json({message:"Beer removed from locker"})
  )

