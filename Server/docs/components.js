module.exports = {
  components: {
    securitySchemes: {
      JWTAuthCookie: {
        type: "apiKey",
        in: "header",
        name: "Authorization",
        description: "Bearer token authentication",
      },
    },
    schemas: {
      Ride: {
        type: "object",
        properties: {
          _id: {
            type: "string",
            example: "65df19cccbf70ed1d138a9f3",
          },
          host: {
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
            example: 10,
          },
          date: {
            type: "string",
            example: "2024-02-28T11:29:48.299Z",
          },
          price: {
            type: "string",
            example: "Rs. 1000",
          },
          description: {
            type: "string",
            example: "Some description about the Ride",
          },
          requests: {
            type: "array",
            items: {
              type: "string",
              example: "65df19cccbf70ed1d138a9f3",
            },
          },
          createdAt: {
            type: "string",
            example: "2024-02-28T11:29:48.299Z",
          },
        },
      },
    },
  },
};
