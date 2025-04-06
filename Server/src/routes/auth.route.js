const { Router } = require("express")
const authController = require("../controllers/auth.controller")
const { authMiddleware } = require("../middlewares/auth.middleware")

const router = Router()

router
  .post("/login", authController.loginHandler)
  .post("/register", authController.registerUser)
  .get("/logout", authMiddleware, authController.logoutHandler)
  .get("/test-auth", authMiddleware, authController.testController)

module.exports = router

