const login = require("./login");
const register = require("./register");

module.exports = {
  "/auth/login": {
    ...login,
  },
  "/auth/register": {
    ...register,
  },
};
