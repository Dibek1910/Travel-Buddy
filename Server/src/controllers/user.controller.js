const User = require("../models/user.model");

module.exports = {
  async getUserProfile(req, res) {
    const { id: userId } = req.user;

    try {
      const userProfile = await User.findById(userId)
        .select("-password -__v -verifiedEmail -updatedAt")
        .lean();
      if (!userProfile) {
        return res.status(404).json({
          success: false,
          message: "user profile not found",
        });
      }
      res.json({
        success: true,
        message: "Done fetching user profile",
        userProfile,
      });
    } catch (err) {
      console.error(err);
      res.status(500).json({
        success: false,
        message: "Could not fetch user profile",
        error: err.message,
      });
    }
  },

  async updateUserProfile(req, res) {
    const { id: userId } = req.user;
    const { firstName, lastName } = req.body;

    try {
      if (!firstName && !lastName) {
        return res.status(400).json({
          success: false,
          message:
            "At least one field (firstName or lastName) is required for update",
        });
      }

      const updateData = {};
      if (firstName) updateData.firstName = firstName;
      if (lastName) updateData.lastName = lastName;

      const updatedUser = await User.findByIdAndUpdate(
        userId,
        { $set: updateData },
        { new: true }
      ).select("-password -__v -verifiedEmail");

      if (!updatedUser) {
        return res.status(404).json({
          success: false,
          message: "User not found",
        });
      }

      return res.json({
        success: true,
        message: "Profile updated successfully",
        userProfile: updatedUser,
      });
    } catch (err) {
      console.error(err);
      return res.status(500).json({
        success: false,
        message: "Could not update user profile",
        error: err.message,
      });
    }
  },
};
