const commonResponse = require("../common-response");
const userSchema = require("./user.schema");

module.exports = {
  get: {
    tags: ["User"],
    parameters: [],
    security: [
      {
        JWTAuthCookie: [],
      },
    ],
    summary: "get the user profile",
    responses: {
      200: {
        description: "Get the user profile of the logged in user",
        content: {
          "application/json": {
            schema: {
              type: "object",
              properties: {
                ...commonResponse,
                userProfile: { ...userSchema },
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
                  example: "could not fetch the user profile",
                },
              },
            },
          },
        },
      },
    },
  },
};
