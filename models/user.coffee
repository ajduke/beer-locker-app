mongoose = require('mongoose')
bcrypt = require('bcrypt-nodejs')

UserSchema = new mongoose.Schema(
  username:
    type: String
    unique: true
    required: true
  password:
    type: String
    required: true

)

UserSchema.pre('save', (callback)->
  user = this
  if (!user.isModified('password'))
    return callback()

  bcrypt.genSalt(5, (err, salt)->
    if (err)
      return callback(err)

    bcrypt.hash(user.password, salt, null, (err, hash)->
      if (err)
        return callback(err)
      user.password = hash
      callback()
    )
  )
)

UserSchema.methods.verifyPassword = (password, cb)->
  bcrypt.compare(password, this.password, (err, isMatch)->
    return cb(err) if (err)
    cb(null, isMatch)
  )

module.exports = mongoose.model('User', UserSchema)