const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.sendChatNotification = functions.firestore
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
                    .doc(idTo)
                    .collection("chats")
                    .doc(idFrom)
                    .update({unreadCount:
                        admin.firestore.FieldValue.increment(1)});
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

exports.sendFriendRequestNotification = functions.firestore
    .document("users/{userId}/friends/{friendId}")
    .onCreate((snap, context) => {
      const doc = snap.data();
      const idTo = context.params.userId;
      const senderName = doc.name;
      const senderEmail = doc.email;

      if (doc.status != 0) {
        return null;
      }

      admin
          .firestore()
          .collection("users")
          .where(admin.firestore.FieldPath.documentId(), "==", idTo)
          .get()
          .then((querySnapshot) => {
            querySnapshot.forEach((userTo) => {
              if (userTo.data().pushToken) {
                const payload = {
                  notification: {
                    title:
                    "You have a new friend request",
                    body: `${senderName} (${senderEmail}})`,
                    badge: "1",
                    sound: "default",
                  },
                };
                admin
                    .messaging()
                    .sendToDevice(userTo.data().pushToken, payload)
                    .then((response) => {
                      console.log("Successfully sent notification:", response);
                    }).catch((error) => {
                      console.log("Error sending message:", error);
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

exports.sendCommentNotification = functions.firestore
    .document("posts/{postId}/comments/{commentId}")
    .onCreate((snap, context) => {
      const doc = snap.data();
      const idTo = doc.posterUid;
      const senderName = doc.name;
      const commentMessage = doc.comment;

      if (idTo == doc.idFrom) {
        return null;
      }

      admin
          .firestore()
          .collection("users")
          .where(admin.firestore.FieldPath.documentId(), "==", idTo)
          .get()
          .then((querySnapshot) => {
            querySnapshot.forEach((userTo) => {
              if (userTo.data().pushToken) {
                const payload = {
                  notification: {
                    title:
                    `${senderName} commented on your post`,
                    body: commentMessage,
                    badge: "1",
                    sound: "default",
                  },
                };
                admin
                    .messaging()
                    .sendToDevice(userTo.data().pushToken, payload)
                    .then((response) => {
                      console.log("Successfully sent notification:", response);
                    }).catch((error) => {
                      console.log("Error sending message:", error);
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
