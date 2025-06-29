const {onDocumentUpdated} = require("firebase-functions/v2/firestore");
const {setGlobalOptions} = require("firebase-functions/v2/options");
const {initializeApp} = require("firebase-admin/app");
const {logger} = require("firebase-functions");
const {getFirestore} = require("firebase-admin/firestore");
const {getMessaging} = require("firebase-admin/messaging");

const orderStatuses = {
    0: "Is Pending...",
    1: "Has Been Confirmed",
    2: "Is On Its Way",
    3: "Has Been Delivered",
}


initializeApp();
setGlobalOptions({ region: "europe-west1", maxInstances: 10 });
const db = getFirestore();

exports.notifyUserOnOrderUpdate = onDocumentUpdated("Orders/{orderID}", async (event) => {
    const before = event.data.before.data();
    const after = event.data.after.data();
    logger.log(`Orderrrrr ${event.params.orderID} status changed from ${before.status} to ${after.status}`);
    logger.log("BEFORE data:", JSON.stringify(before)); // Add this
    logger.log("AFTER data:", JSON.stringify(after));
    if (before.status != after.status) {
        logger.log(`Order ${event.params.orderID} status changed from ${before.status} to ${after.status}`);
        const buyerID = after.buyerID
        try{
            const buyerDoc = await db.collection("Buyers").doc(buyerID).get();
            const buyerData = buyerDoc.data();
            const fcmToken = buyerData.fcmToken;
            let sellerName = await db.collection("Sellers").doc(after.sellerID).get();
            sellerName = sellerName.exists ? sellerName.data().name : "Unknown Seller";
            if(!fcmToken){
                logger.warn(`${buyerID} has no FCM Token`);
                return;
            }
            await getMessaging().send({
                token: fcmToken,
                  data: {
                    title: `Order Status Update with ${sellerName}`,
                    body: `${event.params.orderID} status changed from ${orderStatuses[before.status]} to ${orderStatuses[after.status]}`,
                    type: "order_update",
                    orderID: event.params.orderID,
                    before: String(before.status),
                    after: String(after.status),
                    sellerID: before.sellerID,
                  },
                notification: {
                    title: "Order Status Updated",
                    body: `Order ${event.params.orderID} ${orderStatuses[after.status]} `,
                },
                android:{
//                    notification: {
                    priority: "high",
//                    channelId: "channel_id",
//                    },
                },
            });
            logger.log(`Notification sent to ${buyerID}`);
        } catch(error){
            logger.error("Error sending notification: ", error);
        }
      }
});



