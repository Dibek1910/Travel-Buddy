const requestSchema = require("./request.schema");

module.exports = {
  get: {
    tags: ["Rides"],
    parameters: [],
    security: [
      {
        JWTAuthCookie: [],
      },
    ],
    summary: "get list of user ride requests",
    responses: {
      200: {
        description: "Get user ride requests",
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
                  example: "these are the rides user has requested to be in",
                },
                user: {
                  userId: {
                    type: "string",
                    example: "65df19cccbf70ed1d138a9f3",
                  },
                  email: {
                    type: "string",
                    example: "john.doe@example.com",
                  },
                },
                requests: {
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
