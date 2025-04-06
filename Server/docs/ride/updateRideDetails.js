const rideSchema = require("./ride.schema");

module.exports = {
  patch: {
    summary: "Update ride details",
    tags: ["Rides"],
    security: [
      {
        JWTAuthCookie: [],
      },
    ],
    summary: "update ride details by id",
    requestBody: {
      description: "Updated ride details",
      required: true,
      content: {
        "application/json": {
          schema: {
            type: "object",
            properties: {
              rideId: {
                type: "string",
                example: "65df19cccbf70ed1d138a9f3",
              },
              from: {
                type: "string",
                example: "Delhi, India",
              },
              to: {
                type: "string",
                example: "Jaipur, Rajasthan, India",
              },
              capacity: {
                type: "number",
                example: 8,
              },
              date: {
                type: "string",
                example: "2024-02-28T11:29:48.299Z",
              },
              price: {
                type: "string",
                example: "Rs. 950",
              },
              description: {
                type: "string",
                example:
                  "Hopefully an updated description, only the rideId is requried, rest atleast 1 field is required. It is a PATCH Method",
              },
            },
          },
        },
      },
    },
    responses: {
      200: {
        description: "Ride details have been successfully updated",
        content: {
          "application/json": {
            schema: {
              type: "object",
              properties: {
                success: {
                  type: "boolean",
                },
                message: {
                  type: "string",
                  example: "ride details have been updated",
                },
                ride: {
                  $ref: "#/components/schemas/Ride",
                },
              },
            },
          },
        },
      },
      404: {
        description: "The ride with the given ID does not exist",
        content: {
          "application/json": {
            schema: {
              type: "object",
              properties: {
                success: {
                  type: "boolean",
                },
                message: {
                  type: "string",
                },
              },
            },
          },
        },
      },
      500: {
        description: "Could not update the ride details",
        content: {
          "application/json": {
            schema: {
              type: "object",
              properties: {
                success: {
                  type: "boolean",
                },
                message: {
                  type: "string",
                },
                error: {
                  type: "string",
                },
              },
            },
          },
        },
      },
    },
  },
};
