import mongoose, { Schema, Document } from 'mongoose'
export interface IConversation extends Document {
  participants: mongoose.Types.ObjectId[]
  lastMessage: string
  lastMessageAt: Date
  createdAt: Date
}

const ConversationSchema: Schema = new Schema({
  participants: [
    {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true
    }
  ],
  lastMessage: {
    type: String,
    default: ''
  },
  lastMessageAt: {
    type: Date,
    default: null
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
})

ConversationSchema.virtual('messages', {
  ref: 'Message',
  localField: '_id',
  foreignField: 'conversationId'
})

const Conversation = mongoose.model<IConversation>('Conversation', ConversationSchema)
export default Conversation
