const rideSchema = require("./ride.schema");

module.exports = {
  post: {
    tags: ["Rides"],
    summary: "update user request status",
    parameters: [],
    security: [
      {
        JWTAuthCookie: [],
      },
    ],
    requestBody: {
      required: true,
      content: {
        "application/json": {
          schema: {
            properties: {
              requestId: {
                type: "string",
                example: "65df19cccbf70ed1d138a9f3",
              },
              status: {
                type: "string",
                enum: ["pending", "approved", "rejected"],
                example: "approved",
              },
            },
          },
        },
      },
    },
    responses: {
      200: {
        description: "Update the Request status of a user",
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
                    "successfully updated the status of the request to [STATUS]",
                },
              },
            },
          },
        },
      },
      400: {
        description: "Bad Request, any or both of the field(s) are missing",
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
                  example: "need to provide both requestId and status",
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
                  example: "could not update the status of the requets",
                },
                error: {
                  type: "string",
                  example: "Error details",
                },
              },
            },
          },
        },
      },
    },
  },
};
