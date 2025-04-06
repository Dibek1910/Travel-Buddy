const rideSchema = require("./ride.schema");

module.exports = {
  get: {
    tags: ["Rides"],
    parameters: [],
    security: [
      {
        JWTAuthCookie: [],
      },
    ],
    summary: "get ride details by ID",
    responses: {
      200: {
        description: "Gets the Ride Details by its ID",
        content: {
          "application/json": {
            schema: {
              type: "object",
              properties: {
                success: {
                  type: "boolean",
                  example: true,
                },
                message: {
                  type: "string",
                  example: "These are the ride details",
                },
                rideDetails: { ...rideSchema },
              },
            },
          },
        },
      },
      500: {
        description: "Server could not process the request",
        content: {
          "application/json": {
            schema: {
              type: "object",
              properties: {
                success: {
                  type: "boolean",
                  example: false,
                },
                message: {
                  type: "string",
                  example: "could not fetch the ride details",
                },
              },
            },
          },
        },
      },
    },
  },
};
