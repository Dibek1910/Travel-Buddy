module.exports = {
  post: {
    tags: ["Rides"],
    parameters: [],
    security: [
      {
        JWTAuthCookie: [],
      },
    ],
    summary: "cancel request by id",
    requestBody: {
      required: true,
      content: {
        "application/json": {
          schema: {
            properties: {
              requestId: {
                type: "string",
              },
            },
          },
        },
      },
    },
    responses: {
      200: {
        description: "Cancel Request to Ride by requestId",
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
                  example: "Successfully cancelled the request",
                },
              },
            },
          },
        },
      },
      401: {
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
                  example: "Request with the given requestId does not exist",
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
                  example: "something went wrong while cancelling the request",
                },
              },
            },
          },
        },
      },
    },
  },
};
