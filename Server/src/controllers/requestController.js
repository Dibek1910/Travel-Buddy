const Request = require("../models/request.model");
const Ride = require("../models/ride.model");

module.exports = {
  // Get all requests for a specific ride
  async getRideRequests(req, res) {
    const { rideId } = req.params;

    if (!rideId) {
      return res.status(400).json({
        success: false,
        message: "rideId is required",
      });
    }

    try {
      // Find the ride first to verify it exists and the user is the host
      const ride = await Ride.findById(rideId);

      if (!ride) {
        return res.status(404).json({
          success: false,
          message: "Ride not found",
        });
      }

      // Check if the current user is the host of the ride
      if (ride.host.toString() !== req.user.id) {
        return res.status(403).json({
          success: false,
          message: "You can only view requests for rides you created",
        });
      }

      // Find all requests for this ride
      const requests = await Request.find({ ride: rideId })
        .populate({
          path: "passenger",
          select: "-password -__v -verifiedEmail -createdAt -updatedAt",
        })
        .select("-__v -updatedAt");

      return res.json({
        success: true,
        message: "Requests for the ride",
        requests,
      });
    } catch (err) {
      console.error(err);
      return res.status(500).json({
        success: false,
        message: "Could not fetch requests for the ride",
        error: err.message,
      });
    }
  },
};
