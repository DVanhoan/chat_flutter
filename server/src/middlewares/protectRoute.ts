import { Request, Response, NextFunction } from 'express'
import User, { IUser } from '../models/user.model'
import jwt, { JwtPayload } from 'jsonwebtoken'

interface CustomRequest extends Request {
  user?: IUser | undefined
}

export const protectRoute = async (req: CustomRequest, res: Response, next: NextFunction): Promise<Response | void> => {
  try {
    const token = req.cookies.jwt || req.headers.authorization?.split(' ')[1]

    if (!token) {
      return res.status(401).json({ error: 'Unauthorized: No Token Provided' })
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET as string) as JwtPayload

    if (!decoded) {
      return res.status(401).json({ error: 'Unauthorized: Invalid Token' })
    }

    const user = await User.findById(decoded.userId).select('-password')
    if (!user) {
      return res.status(404).json({ error: 'User not found' })
    }

    req.user = user
    next()
  } catch (err) {
    console.log('Error in protectRoute middleware', (err as Error).message)
    return res.status(500).json({ error: 'Internal Server Error' })
  }
}
