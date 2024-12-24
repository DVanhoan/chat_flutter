import Conversation from '~/models/convensation.model'
import { Request, Response } from 'express'
import Message from '~/models/message.model'

export const chats = async (req: Request, res: Response) => {
  try {
    const conversations = await Conversation.find()
      .populate({
        path: 'participants',
        select: 'username profileImg'
      })
      .populate({
        path: 'messages',
        select: 'content createdAt sender',
        populate: {
          path: 'sender',
          select: 'username profileImg'
        }
      })

    res.status(200).json(conversations)
  } catch (error) {
    res.status(500).json({ message: 'Server Error', error })
  }
}

export const chat = async (req: Request, res: Response) => {
  try {
    const { conversationId } = req.params
    const conversation = await Conversation.findById(conversationId)
      .populate({
        path: 'participants',
        select: 'username profileImg'
      })
      .populate({
        path: 'messages',
        select: 'content createdAt sender'
      })

    if (!conversation) {
      return res.status(404).json({ message: 'Conversation not found' })
    }

    res.status(200).json(conversation)
  } catch (error) {
    res.status(500).json({ message: 'Server Error', error })
  }
}

export const createChat = async (req: Request, res: Response) => {
  try {
    const { participants } = req.body
    const conversation = await Conversation.create({ participants })

    res.status(201).json(conversation)
  } catch (error) {
    res.status(500).json({ message: 'Server Error', error })
  }
}

export const getRecentMessages = async (req: Request, res: Response) => {
  try {
    const { conversationId } = req.query

    if (!conversationId) {
      return res.status(400).json({ message: 'conversationId is required' })
    }

    const messages = await Message.find({ conversationId })
      .sort({ createdAt: 1 })
      .select('content createdAt sender')
      .populate({
        path: 'sender',
        select: 'username profileImg'
      })
      .lean()
    console.log('messages:', messages)
    res.status(200).json(messages)
  } catch (error) {
    res.status(500).json({ message: 'Server Error', error })
  }
}
