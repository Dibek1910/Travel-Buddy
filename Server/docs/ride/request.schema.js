const userSchema = require("../user/user.schema");
const rideSchema = require("./ride.schema");
const status = require("../status-enum");

module.exports = {
  type: "object",
  properties: {
    _id: {
      type: "string",
      example: "65df19cccbf70ed1d138a9f3",
    },
    passenger: {
      ...userSchema,
    },
    ride: {
      ...rideSchema,
    },
    status: {
      ...status,
    },
  },
};
