const userSchema = require("../user/user.schema");
const status = require("../status-enum");

module.exports = {
  type: "object",
  properties: {
    _id: {
      type: "string",
      example: "65df19cccbf70ed1d138a9f3",
    },
    host: {
      ...userSchema,
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
    price: {
      type: "string",
      example: "Rs. 900",
    },
    date: {
      type: "string",
      example: "2024-02-28T11:29:48.299Z",
    },
    description: {
      type: "string",
    },
    requests: {
      type: "array",
      items: {
        type: "object",
        properties: {
          passenger: {
            ...userSchema,
          },
          ride: {
            type: "string",
            example: "65df19cccbf70ed1d138a9f3",
          },
          ...status,
        },
      },
    },
    createdAt: {
      type: "string",
      example: "2024-02-28T11:29:48.299Z",
    },
  },
};
