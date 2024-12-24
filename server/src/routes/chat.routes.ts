import express from 'express'
import { chats, createChat, getRecentMessages } from '../controllers/chat.controller'
import { protectRoute } from '../middlewares/protectRoute'

const router = express.Router()

router.get('/all', protectRoute, chats)
router.post('/create_chat', protectRoute, createChat)
router.get('/recent_messages', protectRoute, getRecentMessages)

export default router
