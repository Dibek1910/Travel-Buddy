module.exports = {
  post: {
    tags: ["Auth"],
    parameters: [],
    summary: "register",
    requestBody: {
      required: true,
      content: {
        "application/json": {
          schema: {
            properties: {
              firstName: {
                type: "string",
              },
              lastName: {
                type: "string",
              },
              email: {
                type: "string",
              },
              password: {
                type: "string",
              },
            },
          },
        },
      },
    },
    responses: {
      200: {
        description: "Register the user",
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
                  example: "successfully created the user",
                },
              },
            },
          },
        },
      },
      400: {
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
                  example: "Invalid credentials",
                },
              },
            },
          },
        },
      },
      409: {
        description: "user already exists",
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
                  example: "user already exists",
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
                  example: "something went wrong while creating the user",
                },
              },
            },
          },
        },
      },
    },
  },
};
