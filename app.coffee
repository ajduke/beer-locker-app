express= require('express')
mongoose= require('mongoose')
Beer= require('./models/beer')
bodyParser= require('body-parser')

app= express()
port = process.env.NODE_PORT || 4040
router= express.Router()


# connect with mongoose here
mongoose.connect('mongodb://localhost:27017/beerlocker')

# routes goes here
router.get('/', (req, res)->
  res.send({message:"You running low on beer..."})
)

app.use(bodyParser.json())
app.use(bodyParser.urlencoded({
  extended: true
}))
app.use('/api',router)


# beer routes
beersRoutes = router.route('/beer')

beersRoutes.post((req, res)->
  beer= new Beer()
  console.log 'posting beer '
  beer.name= req.body.name
  beer.type= req.body.type
  beer.quantity= req.body.quantity

  beer.save((err)->
    if err
      res.send(err)
      console.log 'some err here '
      return
    console.log 'esucess sage'
    res.send({message:"Beer added to locker ", data: beer})
  )
)

beersRoutes.get((req, res)->
  Beer.find((err, beers)->
    if err?
      res.send(err)

    res.json(beers)
  )
)


beerRoute = router.route('/beer/:beer_id')

beerRoute.get((req, res)->
  Beer.findById(req.params.beer_id, (err, beer)->
    if err?
      res.send(err)
    res.json(beer)
  )
)



beerRoute.put((req, res)->
  Beer.findById(req.params.beer_id, (err, beer)->
    if err?
      res.send(err)

    beer.quantity= req.body.quantity

    beer.save((err)->
      if err?
        res.send(err)
      res.json(beer)
    )
  )
)

beerRoute.delete((req,res)->

  Beer.findByIdAndRemove(req.params.beer_id, (err)->
    if err?
      res.send(err)
    res.json({message:"Beer removed from locker"})
  )
)

app.listen(port)

console.log 'Insert beer on ' + port