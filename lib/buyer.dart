import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:isupply_final/firestore_api.dart';

class BuyerScreen extends StatelessWidget {
  final String buyerID;

  BuyerScreen({required this.buyerID});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Buyer Orders")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Orders')
            .where('buyerID', isEqualTo: buyerID)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text("Order ${orders[index].id}"),
                subtitle: Text("Status: ${order['status']}"),
              );
            },
          );
        },
      ),
    );
  }
}




















// final firestoreData = FirestoreData();
// List<Map<String, dynamic>> buyerOrders = [];
// void loadBuyerOrders() async {
//   buyerOrders = await firestoreData.getBuyerOrders();
// }
//
// class BuyerOrderList extends StatefulWidget{
//
//   @override
//   State<BuyerOrderList> createState() => _BuyerState();
// }
//
// class _BuyerState extends State<BuyerOrderList>{
//   List<Map<String, dynamic>> buyerOrders = [];
//   @override
//   void initState() {
//     super.initState();
//     loadBuyerOrders();
//   }
//   void loadBuyerOrders() async {
//     final orders = await firestoreData.getBuyerOrders();
//     setState(() {
//       buyerOrders = orders;
//     });
//   }
//   @override
//   Widget build(BuildContext context){
//     return Text("HELLO");
//   }
// }