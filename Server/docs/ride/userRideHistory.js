module.exports = {
  get: {
    tags: ["Rides"],
    parameters: [],
    security: [
      {
        JWTAuthCookie: [],
      },
    ],
    summary: "get the user ride history",
    responses: {
      200: {
        description: "Get user's ride history",
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
                  example: "This is the Ride History of the user",
                },
                rides: {
                  $ref: "#/components/schemas/Ride",
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
                  example: "Could not fetch the ride history of the user",
                },
              },
            },
          },
        },
      },
    },
  },
};
