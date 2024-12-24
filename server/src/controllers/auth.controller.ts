import { generateTokenAndSetCookie } from '../utils/generateToken'
import User from '../models/user.model.js'
import bcrypt from 'bcryptjs'
import { Request, Response } from 'express'

export const signup = async (req: Request, res: Response) => {
  try {
    const { username, email, password } = req.body

    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    if (!emailRegex.test(email)) {
      return res.status(400).json({ error: 'Invalid email format' })
    }

    const existingUser = await User.findOne({ username })
    if (existingUser) {
      return res.status(400).json({ error: 'Username is already taken' })
    }

    const existingEmail = await User.findOne({ email })
    if (existingEmail) {
      return res.status(400).json({ error: 'Email is already taken' })
    }

    if (password.length < 6) {
      return res.status(400).json({ error: 'Password must be at least 6 characters long' })
    }

    const salt = await bcrypt.genSalt(10)
    const hashedPassword = await bcrypt.hash(password, salt)

    const newUser = new User({
      username,
      email,
      password: hashedPassword
    })

    if (newUser) {
      const token = generateTokenAndSetCookie(newUser._id as string, res)
      await newUser.save()

      res.status(201).json({
        _id: newUser._id,
        username: newUser.username,
        email: newUser.email,
        token: token
      })
    } else {
      res.status(400).json({ error: 'Invalid user data' })
    }
  } catch (error: any) {
    console.log('Error in signup controller', error.message)
    res.status(500).json({ error: 'Internal Server Error' })
  }
}

export const login = async (req: Request, res: Response) => {
  try {
    const { email, password } = req.body
    const user = await User.findOne({ email })

    const isPasswordCorrect = await bcrypt.compare(password, user?.password || '')

    if (!user || !isPasswordCorrect) {
      return res.status(400).json({ error: 'Invalid email or password' })
    }
    const token = generateTokenAndSetCookie(user._id as string, res)

    res.status(200).json({
      user: user,
      token: token
    })
  } catch (error: any) {
    console.log('Error in login controller', error.message)
    res.status(500).json({ error: 'Internal Server Error' })
  }
}

export const logout = async (req: Request, res: Response) => {
  try {
    res.cookie('jwt', '', { maxAge: 0 })
    res.status(200).json({ message: 'Logged out successfully' })
  } catch (error: any) {
    console.log('Error in logout controller', error.message)
    res.status(500).json({ error: 'Internal Server Error' })
  }
}

export const getMe = async (req: Request, res: Response) => {
  try {
    const user = await User.findById(req.user._id).select('-password')
    console.log(user)
    res.status(200).json(user)
  } catch (error: any) {
    console.log('Error in getMe controller', error.message)
    res.status(500).json({ error: 'Internal Server Error' })
  }
}

export const getAll = async (req: Request, res: Response) => {
  try {
    const users = await User.find().select('-password')
    res.status(200).json(users)
  } catch (error: any) {
    console.log('Error in getAll controller', error.message)
    res.status(500).json({ error: 'Internal Server Error' })
  }
}
