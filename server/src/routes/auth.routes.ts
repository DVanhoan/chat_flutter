import express from 'express'
import { getMe, login, logout, signup, getAll } from '../controllers/auth.controller'
import { protectRoute } from '../middlewares/protectRoute'

const router = express.Router()

router.get('/me', protectRoute, getMe)
router.post('/signup', signup)
router.post('/login', login)
router.post('/logout', logout)
router.get('/users', getAll)

export default router
