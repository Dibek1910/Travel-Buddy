const nodemailer = require("nodemailer");
const { mailerConfig } = require("../configs/mailer.config");

const transporter = nodemailer.createTransport({
  host: mailerConfig.host,
  port: mailerConfig.port,
  secure: mailerConfig.port === 465,
  auth: {
    user: mailerConfig.user,
    pass: mailerConfig.password,
  },
});

exports.sendMail = async (receiver, subject, markup) => {
  try {
    return await transporter.sendMail({
      from: mailerConfig.user,
      to: receiver,
      subject,
      html: markup,
    });
  } catch (err) {
    console.log("MAILER ERROR", err);
    throw err;
  }
};
