const admin = require("firebase-admin");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { setGlobalOptions } = require("firebase-functions/v2");
const twilio = require("twilio");

admin.initializeApp();

setGlobalOptions({ region: "asia-south1" });

function phoneDocId(phone) {
  return phone.replace(/\+/g, "");
}

function generateOtp() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

exports.sendOtp = onCall(async (request) => {
  const { phone } = request.data ?? {};

  if (!phone) {
    throw new HttpsError("invalid-argument", "Phone number is required.");
  }

  const otp = generateOtp();
  const expiresAt = Date.now() + 5 * 60 * 1000; // 5 minutes

  await admin.firestore().collection("otps").doc(phoneDocId(phone)).set({
    otp,
    phone,
    expiresAt,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  const accountSid = process.env.TWILIO_ACCOUNT_SID;
  const authToken = process.env.TWILIO_AUTH_TOKEN;
  const twilioPhone = process.env.TWILIO_PHONE_NUMBER;

  if (accountSid && authToken && twilioPhone) {
    const client = twilio(accountSid, authToken);
    try {
      await client.messages.create({
        body: `Your verification code is ${otp}`,
        from: twilioPhone,
        to: phone,
      });
    } catch (e) {
      console.error("Twilio error:", e);
      console.log(`[TESTING] SMS failed, but OTP for ${phone} is ${otp}`);
      // Temporarily commented out so you can test the app without Twilio blocking you!
      // throw new HttpsError("internal", "Failed to send SMS.");
    }
  } else {
    console.warn("Twilio credentials not configured. OTP generated but SMS not sent.");
    console.log(`[TESTING] OTP for ${phone} is ${otp}`);
  }

  return { success: true };
});

exports.verifyOtp = onCall(async (request) => {
  const { phone, otp } = request.data ?? {};

  if (!phone || !otp) {
    throw new HttpsError("invalid-argument", "Phone number and OTP are required.");
  }

  const docRef = admin.firestore().collection("otps").doc(phoneDocId(phone));
  const doc = await docRef.get();

  if (!doc.exists) {
    return { success: false, message: "OTP not found. Request a new one." };
  }

  const { otp: savedOtp, expiresAt } = doc.data();

  if (Date.now() > expiresAt) {
    await docRef.delete();
    return { success: false, message: "OTP has expired." };
  }

  if (savedOtp !== otp) {
    return { success: false, message: "Invalid OTP." };
  }

  // OTP is valid! Delete it so it can't be reused.
  await docRef.delete();

  // Create a Custom Token for Firebase Authentication
  try {
    const customToken = await admin.auth().createCustomToken(phone);
    return { success: true, customToken };
  } catch (e) {
    console.error("Error creating custom token:", e);
    throw new HttpsError("internal", "Failed to create authentication token.");
  }
});
