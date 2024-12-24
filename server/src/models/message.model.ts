import mongoose, { Schema, Document } from 'mongoose'
export interface IMessage extends Document {
  conversationId: mongoose.Types.ObjectId
  sender: mongoose.Types.ObjectId
  content: string
}

const MessageSchema: Schema = new Schema(
  {
    conversationId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Conversation',
      required: true
    },
    sender: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true
    },
    content: {
      type: String,
      required: true
    }
  },
  { timestamps: true }
)

const Message = mongoose.model<IMessage>('Message', MessageSchema)
export default Message
