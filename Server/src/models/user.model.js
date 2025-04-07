const { Schema, model } = require("mongoose");
const { genSalt, hash, compare } = require("bcrypt");

const userSchema = Schema(
  {
    firstName: {
      type: String,
      required: true,
    },
    lastName: {
      type: String,
      required: true,
    },
    password: {
      type: String,
      required: true,
    },
    email: {
      type: String,
      required: true,
      unique: true,
    },
    ratingStats: {
      totalRatings: { type: Number, default: 0 },
      averageRating: { type: Number, default: 0, min: 0, max: 5 },
    },
    verifiedEmail: {
      type: Boolean,
      default: true, // Changed default to true
    },
  },
  { timestamps: true }
);

userSchema.pre("save", async function (next) {
  try {
    if (!this.isModified("password")) {
      return next();
    }
    const salt = await genSalt(11);
    this.password = await hash(this.password, salt);
    next();
  } catch (err) {
    next(err);
  }
});

userSchema.methods.validUser = async function (password) {
  return await compare(password, this.password);
};

const User = model("User", userSchema);
module.exports = User;
