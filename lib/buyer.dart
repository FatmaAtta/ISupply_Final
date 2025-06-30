import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:isupply_final/firestore_api.dart';

class BuyerScreen extends StatelessWidget {
  final String buyerID;
  Map<int, String> status ={
    0: "Pending",
    1: "Confirmed",
    2: "Shipping",
    3: "Delivered",
  };
  BuyerScreen({required this.buyerID});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${buyerID}'s Orders")),
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
                title: Text("${orders[index].id}"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Status: ${status[order['status']]}"),
                    SizedBox(
                      width: double.infinity,
                      child: Image.asset('assets/status${order['status']}.png'),
                    )
                  ],
                )

              );
            },
          );
        },
      ),
    );
  }
}