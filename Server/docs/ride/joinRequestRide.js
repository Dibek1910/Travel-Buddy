const requestSchema = require("./request.schema");

module.exports = {
  post: {
    tags: ["Rides"],
    parameters: [],
    security: [
      {
        JWTAuthCookie: [],
      },
    ],
    summary: "request to join a ride by id",
    requestBody: {
      required: true,
      content: {
        "application/json": {
          schema: {
            properties: {
              rideId: {
                type: "string",
                example: "65df19cccbf70ed1d138a9f3",
              },
            },
          },
        },
      },
    },
    responses: {
      201: {
        description: "successfully sent request to join",
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
                  example: "successfully sent request to join",
                },
                requestTicket: {
                  ...requestSchema,
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
                  example: "could not send the request to join",
                },
              },
            },
          },
        },
      },
    },
  },
};
