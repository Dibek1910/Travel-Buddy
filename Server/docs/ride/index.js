const getRideById = require("./getRideById");
const cancelRideRequest = require("./cancelRideRequest");
const createRide = require("./createRide");
const joinRequestRide = require("./joinRequestRide");
const searchRides = require("./searchRides");
const updateRequestStatus = require("./updateRequestStatus");
const updateRideDetails = require("./updateRideDetails");
const userRideHistory = require("./userRideHistory");
const userCreatedRides = require("./userCreatedRides");
const getUserRideRequests = require("./getUserRideRequests");

module.exports = {
  "/rides/get/{rideId}": {
    ...getRideById,
  },
  "/rides/cancel": {
    ...cancelRideRequest,
  },
  "/rides/create": {
    ...createRide,
  },
  "/rides/request": {
    ...joinRequestRide,
  },
  "/rides/search": {
    ...searchRides,
  },
  "/rides/update-status": {
    ...updateRequestStatus,
  },
  "/rides/update": {
    ...updateRideDetails,
  },
  "/rides/user-ride-history": {
    ...userRideHistory,
  },
  "/rides/user-created": {
    ...userCreatedRides,
  },
  "/rides/user-requests": {
    ...getUserRideRequests,
  },
};
