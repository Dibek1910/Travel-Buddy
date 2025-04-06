module.exports = {
  // add better PAGE NOT FOUND message
  defaultHandler(req, res) {
    return res.status(404).json({
      status: "Not Found",
      statusCode: 404,
      requestedMethod: req.baseUrl,
      message: "Requested endpoint or method is not supported by the server",
    });
  },
};
