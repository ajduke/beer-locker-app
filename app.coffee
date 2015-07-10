express= require('express')
mongoose= require('mongoose')
bodyParser= require('body-parser')
passport= require('passport')

app= express()
port = process.env.NODE_PORT || 4040
router= express.Router()

beerControllers= require('./controllers/beer')
userControllers= require('./controllers/user')
authController= require('./controllers/auth')

# connect with mongoose here
mongoose.connect('mongodb://localhost:27017/beerlocker')

# initialize middlewares
app.use(passport.initialize())
app.use(bodyParser.json())
app.use(bodyParser.urlencoded({
  extended: true
}))

app.use('/api',router)

# beer routes
router.route('/beer')
  .post(authController.isAuthenticated, beerControllers.postBeers)
  .get(authController.isAuthenticated, beerControllers.getBeers)

router.route('/beer/:beer_id')
  .get(authController.isAuthenticated, beerControllers.getBeer)
  .put(authController.isAuthenticated, beerControllers.putBeer)
  .delete(authController.isAuthenticated, beerControllers.deleteBeer)

router.route('/users')
  .post(userControllers.postUsers)
  .get(authController.isAuthenticated, userControllers.getUsers)

app.listen(port)

console.log 'Insert beer on ' + port