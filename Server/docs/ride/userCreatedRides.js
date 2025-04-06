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
    summary: "get the list of rides created by the user",
    responses: {
      200: {
        description: "Get user rides created by the user",
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
                  example: "These are the rides created by the given user",
                },
                rides: {
                  type: "array",
                  items: {
                    ...rideSchema,
                  },
                },
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
                  example: "could not fetch the user ride requests",
                },
              },
            },
          },
        },
      },
    },
  },
};
