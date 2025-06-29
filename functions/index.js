const {onDocumentUpdated} = require("firebase-functions/v2/firestore");
const {setGlobalOptions} = require("firebase-functions/v2/options");
const {initializeApp} = require("firebase-admin/app");
const {logger} = require("firebase-functions");
const {getFirestore} = require("firebase-admin/firestore");
const {getMessaging} = require("firebase-admin/messaging");

const orderStatuses = {
    0: "Is Pending...^-^",
    1: "Has Been Confirmed :D",
    2: "Is On Its Way ^u^",
    3: "Has Been Delivered ✅",
}
const statusImgs = {
    0: "https://firebasestorage.googleapis.com/v0/b/isupply-final.firebasestorage.app/o/status0.png?alt=media&token=987ce592-d15e-4cd1-b854-7f463d506cd6",
    1: "https://firebasestorage.googleapis.com/v0/b/isupply-final.firebasestorage.app/o/status1.png?alt=media&token=b8bd311b-cb6e-4c89-88c6-eee813eb851c",
    2: "https://firebasestorage.googleapis.com/v0/b/isupply-final.firebasestorage.app/o/status2.png?alt=media&token=cb5d5481-9bcd-4017-bb4a-521cbe895ca7",
    3: "https://firebasestorage.googleapis.com/v0/b/isupply-final.firebasestorage.app/o/status3.png?alt=media&token=8bab38bc-c6e7-42b5-af7e-1348d8459857",
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
                    body: `${event.params.orderID} ${orderStatuses[after.status]}`,
//                    body: `${event.params.orderID} status changed from ${orderStatuses[before.status]} to ${orderStatuses[after.status]}`,
                    type: "order_update",
                    orderID: event.params.orderID,
                    before: String(before.status),
                    after: String(after.status),
                    sellerID: before.sellerID,
                  },
                notification: {
                    title: `Order Status Update with ${sellerName}`,
                    body: `${event.params.orderID} ${orderStatuses[after.status]}`,
//                    body: `${event.params.orderID} status changed from ${orderStatuses[before.status]} to ${orderStatuses[after.status]}`,
                    image: statusImgs[after.status],
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



