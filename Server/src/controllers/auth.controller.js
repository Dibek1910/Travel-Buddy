const { resolve } = require("path")
const { sign, verify } = require("jsonwebtoken")
const User = require("../models/user.model")
const { sendMail } = require("../services/mailer.service")

const SERVER_URL = `http://localhost:${process.env.SERVER_PORT || 8080}`

const validDomains = ["muj.manipal.edu", "jaipur.manipal.edu", "gmail.com"] // Added gmail.com for testing

function validEmail(email) {
  if (!email.includes("@")) {
    return false
  }
  const emailDomain = email.split("@")[1]
  return validDomains.includes(emailDomain)
}

module.exports = {
  async loginHandler(req, res) {
    const { email, password } = req.body
    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: "Email or Password fields are empty. Please fill both of them.",
      })
    }

    try {
      const existingUser = await User.findOne({ email })
      if (!existingUser) {
        throw new Error("user does not exist")
      }

      const isPasswordValid = await existingUser.validUser(password)
      if (!isPasswordValid) {
        throw new Error("user does not exist")
      }

      // Removed email verification check
      const token = sign({ id: existingUser._id, email }, process.env.SECRET_KEY)

      return res.json({
        success: true,
        message: "successfully logged in",
        token,
        user: {
          id: existingUser._id,
          firstName: existingUser.firstName,
          lastName: existingUser.lastName,
          email: existingUser.email,
        },
      })
    } catch (err) {
      return res.status(500).json({
        success: false,
        message: "internal server error while validating user",
        error: err.message,
      })
    }
  },

  async registerUser(req, res) {
    const { firstName, lastName, email, password } = req.body
    console.log(req.body)

    console.log(validEmail(email))

    if (!firstName || !lastName || !email || !password || !validEmail(email)) {
      return res.status(400).json({
        success: false,
        message: "Invalid credentials",
      })
    }

    try {
      const userExists = await User.findOne({ email })
      if (userExists) {
        return res.status(409).json({
          success: false,
          message: "user already exists",
        })
      }

      // Create new user with email already verified
      const newUser = new User({
        firstName,
        lastName,
        email,
        password,
        verifiedEmail: true, // Set to true by default
      })

      const savedUser = await newUser.save()
      const { password: _, ...rest } = savedUser.toObject()

      return res.json({
        success: true,
        message: "successfully created the user",
        user: rest,
      })
    } catch (err) {
      console.log(err)
      return res.status(500).json({
        success: false,
        message: "something went wrong when creating the user",
      })
    }
  },

  async logoutHandler(req, res) {
    res.json({
      success: true,
      message: "logged out",
    })
  },

  async testController(req, res) {
    return res.json({
      success: true,
      message: "you are authorized",
      email: req.user?.email,
    })
  },
}

