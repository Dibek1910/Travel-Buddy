const { connect } = require("mongoose");

exports.databaseConnection = async () => {
  try {
    await connect(process.env.DB_HOST);
    console.log(`Connected to MongoDB Atlas`);
  } catch (err) {
    console.error("MongoDB connection error:", err);
    process.exit(1);
  }
};
