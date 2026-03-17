import { Request, Response, NextFunction } from 'express'
import User from '../models/user.model'
import jwt, { JwtPayload } from 'jsonwebtoken'
import type { CustomRequest } from '../type'

export const protectRoute = async (req: CustomRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const token = req.cookies.jwt || req.headers.authorization?.split(' ')[1]

    if (!token) {
      res.status(401).json({ error: 'Unauthorized: No Token Provided' })
      return
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET as string) as JwtPayload

    if (!decoded) {
      res.status(401).json({ error: 'Unauthorized: Invalid Token' })
      return
    }

    const user = await User.findById(decoded.userId).select('-password')
    if (!user) {
      res.status(404).json({ error: 'User not found' })
      return
    }

    req.user = user
    next()
  } catch (err) {
    console.log('Error in protectRoute middleware', (err as Error).message)
    res.status(500).json({ error: 'Internal Server Error' })
  }
}
