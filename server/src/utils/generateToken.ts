import jwt from 'jsonwebtoken'
import { Response } from 'express'

export const generateTokenAndSetCookie = (userId: string, res: Response) => {
  try {
    const token = jwt.sign({ userId }, process.env.JWT_SECRET as string, {
      expiresIn: '15d'
    })

    res.cookie('jwt', token, {
      maxAge: 15 * 24 * 60 * 60 * 1000,
      httpOnly: true,
      sameSite: 'strict',
      secure: process.env.NODE_ENV !== 'development'
    })

    return token
  } catch (error: any) {
    console.error('Error generating token:', error.message)
    return null
  }
}
