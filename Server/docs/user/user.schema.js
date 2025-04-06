module.exports = {
  type: "object",
  properties: {
    _id: {
      type: "string",
      example: "65df19cccbf70ed1d138a9f3",
    },
    firstName: {
      type: "string",
    },
    lastName: {
      type: "string",
    },
    email: {
      type: "string",
      example: "john.doe@example.com",
    },
    ratingStats: {
      type: "object",
      properties: {
        averageRating: {
          type: "number",
          example: 4.5,
        },
        totalRatings: {
          type: "number",
          example: 56,
        },
      },
    },
  },
};
