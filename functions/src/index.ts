import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
admin.initializeApp();

const db = admin.firestore();
const fcm = admin.messaging();


export const getTokens = functions.https.onCall((data, context) => {
  const myTokens = db.collection("myTokens");
  
    
  return myTokens.doc(data["uid"]).set({ tokens: data["tokens"] });

});

export const sendToDevice = functions.firestore
  .document('stat/{statId}')
  .onUpdate(async change => {

   const order = change.after.data();

   const currentUser = await db 
      .collection("profile")   
      .doc(order.uid)         
      .get();

   const name = currentUser.get("name");
   const number = currentUser.get("phoneNumber");

   const documentSnapshot = await db
      .collection('myTokens')
      .doc(order.uid)
      .get();

   const tokens = documentSnapshot.get("tokens");
   
  
    const payload: admin.messaging.MessagingPayload = {
      notification: {
        title: name,
        priority: "high",
        body: order.stat,
        number: number,
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
      },
      data: {
         click_action: 'FLUTTER_NOTIFICATION_CLICK',
         title: name,
         priority: "high",
         number: number,
         body: order.stat
      }
    };

    return fcm.sendToDevice(tokens, payload);
  });







