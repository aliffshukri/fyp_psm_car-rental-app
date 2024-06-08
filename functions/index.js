/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
admin.initializeApp();

exports.disableUser = functions.https.onCall(async (data, context) => {
  if (!context.auth || !context.auth.token.admin) {
    throw new functions.https.HttpsError('permission-denied', 'Must be an administrative user to disable users.');
  }

  const uid = data.uid;
  try {
    await admin.auth().updateUser(uid, { disabled: true });
    return { message: 'User disabled successfully' };
  } catch (error) {
    throw new functions.https.HttpsError('unknown', error.message, error);
  }
});

exports.enableUser = functions.https.onCall(async (data, context) => {
  if (!context.auth || !context.auth.token.admin) {
    throw new functions.https.HttpsError('permission-denied', 'Must be an administrative user to enable users.');
  }

  const uid = data.uid;
  try {
    await admin.auth().updateUser(uid, { disabled: false });
    return { message: 'User enabled successfully' };
  } catch (error) {
    throw new functions.https.HttpsError('unknown', error.message, error);
  }
});

exports.deleteUser = functions.https.onCall(async (data, context) => {
  if (!context.auth || !context.auth.token.admin) {
    throw new functions.https.HttpsError('permission-denied', 'Must be an administrative user to delete users.');
  }

  const uid = data.uid;
  try {
    await admin.auth().deleteUser(uid);
    return { message: 'User deleted successfully' };
  } catch (error) {
    throw new functions.https.HttpsError('unknown', error.message, error);
  }
});

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
