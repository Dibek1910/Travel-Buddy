const { Schema, model } = require("mongoose");

const rideSchema = Schema(
  {
    host: {
      type: Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    from: {
      type: String,
      required: true,
    },
    to: {
      type: String,
      required: true,
    },
    capacity: {
      type: Number,
      required: true,
      min: [1, "Capacity must be atleast 1"],
      max: [50, "Capacity cannot exceed 50"],
    },
    price: {
      type: Number,
      default: null,
    },
    date: {
      type: String,
      required: true,
    },
    description: {
      type: String,
      required: true,
    },
    requests: [
      {
        type: Schema.Types.ObjectId,
        ref: "Request",
      },
    ],
  },
  { timestamps: true }
);

const Ride = model("Ride", rideSchema);
module.exports = Ride;
