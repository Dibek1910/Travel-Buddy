const { startSession } = require("mongoose");
const Request = require("../models/request.model");
const Ride = require("../models/ride.model");

module.exports = {
  getRideById: async (req, res) => {
    const { rideId: id } = req.params;
    console.log("Fetching ride details for ID:", id);

    try {
      const rideDetails = await Ride.findById(id)
        .populate("host", "-password -__v -verifiedEmail -createdAt -updatedAt")
        .populate({
          path: "requests",
          select: "-__v -updatedAt",
          populate: {
            path: "passenger",
            select: "-password -__v -verifiedEmail -createdAt -updatedAt",
          },
        })
        .select("-__v");

      if (!rideDetails) {
        return res.status(404).json({
          success: false,
          message: "Ride not found",
        });
      }

      return res.json({
        success: true,
        message: "These are the ride details",
        rideDetails,
      });
    } catch (err) {
      console.log(err);
      return res.status(500).json({
        success: false,
        message: "could not fetch the ride details",
        error: err.message,
      });
    }
  },
  async createRide(req, res) {
    try {
      const { from, to, date, capacity, price, description } = req.body;

      if (!from || !to || !date || !capacity) {
        return res.status(400).json({
          success: false,
          message:
            "Missing required fields: from, to, date, and capacity are required",
        });
      }

      const ride = new Ride({
        host: req.user.id,
        from,
        to,
        date,
        capacity,
        price,
        description,
      });
      const result = await ride.save();

      res.status(201).json({
        success: true,
        message: "successfully created the ride",
        ride: result,
      });
    } catch (err) {
      res.status(500).json({
        success: false,
        message: "failed to create a ride",
        error: err.message,
      });
    }
  },
  async requestRide(req, res) {
    const session = await startSession();
    session.startTransaction();
    try {
      const { rideId } = req.body;

      if (!rideId) {
        return res.status(400).json({
          success: false,
          message: "rideId is required",
        });
      }

      const ride = await Ride.findById(rideId);

      if (!ride) {
        throw new Error(`Ride with ID: ${rideId} does not exist`);
      }

      // Check if user is the host
      if (ride.host.toString() === req.user.id) {
        throw new Error("You cannot request to join your own ride");
      }

      const existingRide = await Request.findOne({
        ride: rideId,
        passenger: req.user.id,
      });

      if (existingRide) {
        throw new Error("Request to the same ride already exists");
      }

      const request = new Request({
        ride: rideId,
        passenger: req.user.id,
      });
      const savedRequest = await request.save({ session });

      ride.requests.addToSet(request._id);
      await ride.save({ session });

      const populatedRequest = await savedRequest.populate({
        path: "ride",
        select: "-requests",
      });

      await session.commitTransaction();

      res.status(201).json({
        success: true,
        message: "successfully sent request to join",
        requestTicket: populatedRequest,
      });
    } catch (err) {
      await session.abortTransaction();

      res.status(500).json({
        success: false,
        message: "Could not send the request to join",
        error: err.message,
      });
    } finally {
      await session.endSession();
    }
  },
  async cancelRequest(req, res) {
    const { requestId } = req.body;

    if (!requestId) {
      return res.status(400).json({
        success: false,
        message: "requestId is required",
      });
    }

    const session = await startSession();
    session.startTransaction();

    try {
      const existingRequest =
        await Request.findById(requestId).session(session);
      if (!existingRequest) {
        throw new Error(
          `Request with the given requestId: ${requestId} does not exist`
        );
      }

      // Verify the user is the passenger who made the request
      if (existingRequest.passenger.toString() !== req.user.id) {
        throw new Error("You can only cancel your own requests");
      }

      const existingRide = await Ride.findById(existingRequest.ride);
      if (!existingRide) {
        throw new Error("Ride not found");
      }

      existingRide.requests = existingRide.requests.filter(
        (request) => request.toString() !== requestId
      );
      await existingRide.save({ session });
      await existingRequest.deleteOne({ session });
      await session.commitTransaction();

      return res.json({
        success: true,
        message: "Successfully cancelled the request",
      });
    } catch (e) {
      await session.abortTransaction();
      console.log(e);
      return res.status(500).json({
        success: false,
        message: "something went wrong while cancelling the request",
        error: e.message,
      });
    } finally {
      await session.endSession();
    }
  },
  async updateStatus(req, res) {
    const { requestId, status } = req.body;

    if (!requestId || !status) {
      return res.status(400).json({
        success: false,
        message: "need to provide both requestId and status",
      });
    }

    if (!["pending", "approved", "rejected"].includes(status)) {
      return res.status(400).json({
        success: false,
        message: "invalid status - must be pending, approved, or rejected",
      });
    }

    const session = await startSession();
    session.startTransaction();

    try {
      const requestDocument = await Request.findById(requestId).populate({
        path: "ride",
        select: { host: 1 },
      });

      if (!requestDocument) {
        throw new Error("No request with the given id");
      }

      if (req.user.id !== requestDocument.ride.host.toString()) {
        throw new Error("Only host of the ride can update the status");
      }

      if (status === "approved") {
        const ride = await Ride.findById(
          requestDocument.ride._id,
          {
            requests: 1,
            capacity: 1,
            _id: 0,
          },
          { session }
        );

        // Count approved requests
        const approvedRequests = await Request.countDocuments({
          ride: requestDocument.ride._id,
          status: "approved",
        });

        if (approvedRequests >= ride.capacity) {
          throw new Error("ride is full, cannot add more passengers");
        }
      }

      requestDocument.status = status;
      await requestDocument.save({ session });

      await session.commitTransaction();
      res.json({
        success: true,
        message: `successfully updated the status of the request to ${status}`,
      });
    } catch (err) {
      await session.abortTransaction();
      res.status(500).json({
        success: false,
        message: "could not update status of the request",
        error: err.message,
      });
    } finally {
      await session.endSession();
    }
  },
  async getUserRideRequests(req, res) {
    const userId = req.user.id;
    try {
      const requests = await Request.find({ passenger: userId })
        .populate({
          path: "ride",
          select: "-requests -__v",
          options: { distinct: true },
          populate: {
            path: "host",
            select: "-__v -_id -verifiedEmail -password -createdAt -updatedAt",
          },
        })
        .select({ _id: 1, ride: 1, status: 1 });

      return res.json({
        success: true,
        message: "these are the rides user has requested to be in",
        user: {
          userId: req.user.id,
          email: req.user.email,
        },
        requests: requests,
      });
    } catch (err) {
      return res.status(500).json({
        success: false,
        message: `could not fetch requests made by the userid: ${userId}`,
        error: err.message,
      });
    }
  },
  async searchRides(req, res) {
    const { from, to, date } = req.body;

    try {
      // Create a query object for filtering
      const query = {};

      // Only add filters if they are provided and not empty
      if (from && from.trim() !== "") {
        query.from = { $regex: from, $options: "i" };
      }

      if (to && to.trim() !== "") {
        query.to = { $regex: to, $options: "i" };
      }

      if (date && date.trim() !== "") {
        // For date, we want to match rides on the same day
        // Convert the date string to a Date object
        const searchDate = new Date(date);

        // Create a date range for the entire day
        const startOfDay = new Date(searchDate);
        startOfDay.setHours(0, 0, 0, 0);

        const endOfDay = new Date(searchDate);
        endOfDay.setHours(23, 59, 59, 999);

        // Use the date range in the query
        query.date = {
          $gte: startOfDay.toISOString(),
          $lte: endOfDay.toISOString(),
        };
      }

      // Add filter to exclude rides created by the current user
      query.host = { $ne: req.user.id };

      // Add filter to only show rides with available capacity
      query.capacity = { $gt: 0 };

      // Get current date to filter out past rides
      const currentDate = new Date();
      currentDate.setHours(0, 0, 0, 0);

      // Only show rides that are today or in the future
      query.date = {
        ...query.date,
        $gte: currentDate.toISOString(),
      };

      console.log("Search query:", query);

      const rides = await Ride.find(query)
        .populate({
          path: "host",
          select: "-password -verifiedEmail -__v",
        })
        .sort({ date: 1, createdAt: -1 });

      res.json({
        success: true,
        message: "these are the rides that match the given parameters",
        rides,
      });
    } catch (err) {
      console.log(err);
      res.status(500).json({
        success: false,
        message: "error in fetching rides with the given parameters",
        error: err.message,
      });
    }
  },
  async getUserRideHistory(req, res) {
    try {
      const { id: user_id } = req.user;

      const passengerRequests = await Request.find({
        passenger: user_id,
        status: "approved",
      })
        .select("ride")
        .populate({
          path: "ride",
          populate: {
            path: "host",
            select: "-password -verifiedEmail",
          },
        });

      const passengerRides = passengerRequests.map((request) => request.ride);

      const hostRides = await Ride.find({ host: user_id }).populate({
        path: "host",
        select: "-password -verifiedEmail",
      });

      return res.status(200).json({
        success: true,
        message: "This is the ride history of the user",
        rides: {
          asPassenger: passengerRides,
          asHost: hostRides,
        },
      });
    } catch (err) {
      console.error(err);
      return res.status(500).json({
        success: false,
        message: "Could not fetch the ride history for the user",
        error: err.message,
      });
    }
  },
  async getCreatedRidesByUser(req, res) {
    const { id } = req.user;
    try {
      const rides = await Ride.find({ host: id })
        .populate({
          path: "host",
          select: "-password -verifiedEmail",
        })
        .populate({
          path: "requests",
          populate: {
            path: "passenger",
            select: "-password -verifiedEmail",
          },
        })
        .sort({ createdAt: -1 });

      return res.json({
        success: true,
        message: "These are the rides created by the given user",
        rides,
      });
    } catch (err) {
      console.log(err);
      res.status(500).json({
        success: false,
        message: "Could not get the rides created by the user",
        error: err.message,
      });
    }
  },
  async updateRideDetails(req, res) {
    try {
      const { rideId, ...updatedRideDetails } = req.body;

      if (!rideId) {
        return res.status(400).json({
          success: false,
          message: "rideId is required",
        });
      }

      // Verify the user is the host of the ride
      const ride = await Ride.findById(rideId);
      if (!ride) {
        return res.status(404).json({
          success: false,
          message: `The ride with the given ID: ${rideId} does not exist`,
        });
      }

      if (ride.host.toString() !== req.user.id) {
        return res.status(403).json({
          success: false,
          message: "You can only update rides that you created",
        });
      }

      const updatedRide = await Ride.findByIdAndUpdate(
        rideId,
        { $set: updatedRideDetails },
        { new: true }
      );

      return res.status(200).json({
        success: true,
        message: "ride details have been updated",
        ride: updatedRide,
      });
    } catch (error) {
      console.error(error);
      return res.status(500).json({
        success: false,
        message: "could not update the ride details",
        error: error.message,
      });
    }
  },
};
