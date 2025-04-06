const rideSchema = require("./ride.schema");

module.exports = {
  post: {
    tags: ["Rides"],
    parameters: [],
    security: [
      {
        JWTAuthCookie: [],
      },
    ],
    summary: "search for rides",
    requestBody: {
      required: true,
      content: {
        "application/json": {
          schema: {
            properties: {
              from: {
                type: "string",
                example: "Delhi, India",
              },
              to: {
                type: "string",
                example: "Jaipur, Rajasthan, India",
              },
              date: {
                type: "string",
              },
            },
          },
        },
      },
    },
    responses: {
      200: {
        description: "Search for Rides",
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
                  example:
                    "these are the rides that match the given parameters",
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
                  example: "error fetching rides with the given parameters",
                },
              },
            },
          },
        },
      },
    },
  },
};
