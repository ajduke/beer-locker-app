mongoose= require('mongoose')


tokenSchema= new mongoose.Schema(
    value:
      type: String
      required: true
    userId:
      type: String
      required: true
    clientId:
      type: String
      required: true
  )


exports.module=-mongoose.model('tokenSchema', tokenSchema )