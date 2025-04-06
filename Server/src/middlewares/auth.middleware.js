const { verify } = require("jsonwebtoken");
const User = require("../models/user.model");

exports.authMiddleware = async (req, res, next) => {
  const authHeader = req.headers["authorization"];
  if (!authHeader) {
    return res.status(401).json({
      success: false,
      message: "authorization header not present",
    });
  }

  const loginToken = authHeader.split(" ")[1];
  console.log(loginToken);

  if (!loginToken) {
    return res.status(401).json({
      success: false,
      message: "Unauthorized, user not authenticated",
    });
  }
  try {
    const userFromToken = verify(loginToken, process.env.SECRET_KEY);
    const dbUsr = await User.findById(userFromToken.id);
    if (!dbUsr) {
      return res.status(401).json({
        success: false,
        message: "Valid token but user does not exists ",
      });
    }
    req.user = userFromToken;
    next();
  } catch (err) {
    return res.status(401).json({
      success: false,
      message: "you are not authorized",
    });
  }
};
