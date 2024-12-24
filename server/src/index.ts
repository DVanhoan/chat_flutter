import cookieParser from 'cookie-parser'
import dotenv from 'dotenv'
import express from 'express'
import cors from 'cors'
import http from 'http'
import authRoutes from './routes/auth.routes'
import chatRoutes from './routes/chat.routes'
import connectMongoDB from './db/connectMongoDB'
import { Server, WebSocket } from 'ws'
import jwt, { JwtPayload } from 'jsonwebtoken'
import Message from './models/message.model'

dotenv.config()

const app = express()
const server = http.createServer(app)
const wss = new Server({ noServer: true })

interface CustomWebSocket extends WebSocket {
  userId?: string
}

server.on('upgrade', (request, socket, head) => {
  try {
    const url = new URL(request.url || '', `http://${request.headers.host}`)
    const token = url.searchParams.get('token')

    if (!token) {
      socket.write('HTTP/1.1 401 Unauthorized\r\n\r\n')
      socket.destroy()
      return
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET as string) as JwtPayload
    wss.handleUpgrade(request, socket, head, (ws) => {
      const customWs = ws as unknown as CustomWebSocket
      customWs.userId = decoded.userId

      wss.emit('connection', customWs, request)
      console.log(`User ${decoded.userId} connected via WebSocket`)
    })
  } catch (err) {
    console.error('WebSocket upgrade error:', err)
    socket.write('HTTP/1.1 401 Unauthorized\r\n\r\n')
    socket.destroy()
  }
})

wss.on('connection', (ws: CustomWebSocket) => {
  console.log(`WebSocket connection established for user: ${ws.userId}`)

  ws.on('message', async (rawMessage) => {
    try {
      const messageData = JSON.parse(rawMessage.toString())
      const { conversationId, sender, content } = messageData

      const newMessage = await Message.create({ conversationId, sender, content })

      wss.clients.forEach((client: CustomWebSocket) => {
        if (client.readyState === WebSocket.OPEN && client.userId && conversationId.includes(client.userId)) {
          client.send(JSON.stringify(newMessage))
        }
      })
    } catch (err) {
      console.error('Error handling message:', err)
    }
  })

  ws.on('close', () => {
    console.log(`WebSocket connection closed for user: ${ws.userId}`)
  })
})

const PORT = process.env.PORT || 5000

app.use(
  cors({
    origin: process.env.CORS_ORIGIN || '*',
    methods: ['GET', 'POST', 'PUT', 'DELETE'],
    allowedHeaders: ['Content-Type', 'Authorization'],
    credentials: true
  })
)
app.use(express.json({ limit: '5mb' }))
app.use(express.urlencoded({ extended: true }))
app.use(cookieParser())

app.use('/api/auth', authRoutes)
app.use('/api/chat', chatRoutes)

server.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`)
  connectMongoDB()
})
