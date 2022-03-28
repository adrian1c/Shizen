const functions = require("firebase-functions");

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

const admin = require("firebase-admin");
const { firestore } = require("firebase-admin");
admin.initializeApp();

exports.removeExpiredDocuments = functions.pubsub.schedule("every 1 hours").onRun(async (context) => {
  const db = admin.firestore();
  const now = firestore.Timestamp.now();
  const ts = firestore.Timestamp.fromMillis(now.toMillis() - 259200000); // 24 hours in milliseconds = 86400000

  const snap = await db.collection("docs").where("dateCreated", "<", ts).get();
  let promises = [];
  snap.forEach((snap) => {
    promises.push(snap.ref.delete());
  });
  return Promise.all(promises);
});