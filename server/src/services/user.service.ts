import User, { IUser } from '../models/user.model'
import bcrypt from 'bcryptjs'

export const createUser = async (userData: Partial<IUser>): Promise<IUser> => {
  const { username, email, password } = userData
  const hashedPassword = await bcrypt.hash(password, 10)
  const newUser = new User({ username, email, password: hashedPassword })
  return await newUser.save()
}

export const getUserById = async (userId: string): Promise<IUser | null> => {
  return await User.findById(userId).select('-password')
}

export const getAllUsers = async (): Promise<IUser[]> => {
  return await User.find().select('-password')
}

export const updateUser = async (userId: string, updateData: Partial<IUser>): Promise<IUser | null> => {
  if (updateData.password) {
    updateData.password = await bcrypt.hash(updateData.password, 10)
  }
  return await User.findByIdAndUpdate(userId, updateData, { new: true, runValidators: true }).select('-password')
}

export const deleteUser = async (userId: string): Promise<IUser | null> => {
  return await User.findByIdAndDelete(userId)
}
