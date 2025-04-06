const express = require("express");
const requestController = require("../controllers/requestController");
const { authMiddleware } = require("../middlewares/auth.middleware");

const router = express.Router();

router.get("/:rideId", authMiddleware, requestController.getRideRequests);

module.exports = router;
