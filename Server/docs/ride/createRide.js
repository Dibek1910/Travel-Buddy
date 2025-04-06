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
    summary: "create a new ride",
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
              capacity: {
                type: "number",
                example: 8,
              },
              price: {
                type: "string",
                example: "Rs. 900",
              },
              description: {
                type: "string",
              },
            },
          },
        },
      },
    },
    responses: {
      200: {
        description: "Create a new Ride",
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
                  example: "successfully created the ride",
                },
                ride: {
                  ...rideSchema,
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
                  example: "failed to create a ride",
                },
              },
            },
          },
        },
      },
    },
  },
};
