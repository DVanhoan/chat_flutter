import mongoose, { Schema, Document } from 'mongoose'

export interface IUser extends Document {
  username: string
  email: string
  bio: string
  password: string
  profileImg: string
  coverImg: string
}

const userSchema: Schema = new Schema({
  username: { type: String, required: true, unique: true },
  email: { type: String, required: true, unique: true },
  bio: { type: String },
  password: { type: String, required: true },
  profileImg: { type: String, default: '' },
  coverImg: { type: String, default: '' }
})

userSchema.virtual('conversations', {
  ref: 'Conversation',
  localField: '_id',
  foreignField: 'participants'
})

const User = mongoose.model<IUser>('User', userSchema)
export default User
