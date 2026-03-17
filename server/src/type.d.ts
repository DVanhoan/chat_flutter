import { Request } from 'express'
import { IUser } from './models/user.model'

declare global {
  namespace Express {
    interface Request {
      user?: IUser
    }
  }
}

export interface CustomRequest extends Request {
  user?: IUser
}
