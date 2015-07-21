express= require('express')
mongoose= require('mongoose')
bodyParser= require('body-parser')
passport= require('passport')
session = require('express-session')
require('./models/token')

oauth2Controller = require('./controllers/oauth2');


app= express()
port = process.env.NODE_PORT || 4040
router= express.Router()
ejs= require('ejs')

beerControllers= require('./controllers/beer')
userControllers= require('./controllers/user')
authController= require('./controllers/auth')
clientController= require('./controllers/client')

# connect with mongoose here
mongoose.connect('mongodb://localhost:27017/beerlocker')

# set the view engine here
app.set('view engine', 'ejs')

# initialize middlewares
app.use(passport.initialize())
app.use(bodyParser.json())
app.use(bodyParser.urlencoded({
  extended: true
}))

# Use express session support since OAuth2orize requires it
app.use(session({
  secret: 'Super Secret Session Key',
  saveUninitialized: true,
  resave: true
}));

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

router.route('/clients')
  .post(authController.isAuthenticated, clientController.postClients)
  .get(authController.isAuthenticated, clientController.getClients)


# Create endpoint handlers for oauth2 authorize
router.route('/oauth2/authorize')
  .get(authController.isAuthenticated, oauth2Controller.authorization)
  .post(authController.isAuthenticated, oauth2Controller.decision)

# Create endpoint handlers for oauth2 token
router.route('/oauth2/token')
  .post(authController.isClientAuthenticated, oauth2Controller.token)


app.listen(port)

console.log 'Insert beer on ' + port