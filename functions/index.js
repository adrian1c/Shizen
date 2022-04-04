// const functions = require("firebase-functions");

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

// const admin = require("firebase-admin");
// const { firestore } = require("firebase-admin");
// admin.initializeApp();


const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.sendNotification = functions.firestore
    .document("chats/{chatId}/messages/{message}")
    .onCreate((snap, context) => {
      const doc = snap.data();
      const idFrom = doc.idFrom;
      const idTo = doc.idTo;
      const contentMessage = doc.message;

      // Get push token user to (receive)
      admin
          .firestore()
          .collection("users")
          .where(admin.firestore.FieldPath.documentId(), "==", idTo)
          .get()
          .then((querySnapshot) => {
            querySnapshot.forEach((userTo) => {
              if (userTo.data().pushToken &&
              userTo.data().chattingWith !== idFrom) {
                // Get info user from (sent)
                admin
                    .firestore()
                    .collection("users")
                    .where(admin.firestore.FieldPath.documentId(), "==", idFrom)
                    .get()
                    .then((querySnapshot2) => {
                      querySnapshot2.forEach((userFrom) => {
                        const payload = {
                          notification: {
                            title:
                            `You have a message from ${userFrom.data().name}`,
                            body: contentMessage,
                            badge: "1",
                            sound: "default",
                          },
                        };
                        // Let push to the target device
                        admin
                            .messaging()
                            .sendToDevice(userTo.data().pushToken, payload)
                            .then((response) => {
                              console.log("Successfully sent message:",
                                  response);
                            })
                            .catch((error) => {
                              console.log("Error sending message:", error);
                            });
                      });
                    });
              } else {
                console.log("Can not find pushToken target user");
              }
            });
          }).catch((error) => {
            console.log("Error: ", error);
          });
      return null;
    });
