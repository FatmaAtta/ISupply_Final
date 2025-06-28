import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SellerScreen extends StatelessWidget {
  final String sellerID;
  Map<int, String> status ={
    0: "Pending",
    1: "Confirmed",
    2: "Shipping",
    3: "Delivered",
  };
  Map<int, String> nextStatus ={
    0: "Pending",
    1: "Confirm",
    2: "Ship",
    3: "Deliver",
  };

  SellerScreen({required this.sellerID});

  void updateOrderStatus(String orderID, int newStatus) {
    FirebaseFirestore.instance
        .collection('Orders')
        .doc(orderID)
        .update({'status': newStatus});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${sellerID}'s Orders")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Orders')
            .where('sellerID', isEqualTo: sellerID)
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
                subtitle: Text("Status: ${status[order['status']]}"),
                trailing: (order['status']>=3) ?
                Text(
                  "Delivered",
                   style: TextStyle(color: Color(0xff79c7c0)),
                ) :
                    SizedBox(
                      width: 150,
                      child: ElevatedButton(
                        onPressed: () {
                          int newStatus = (order['status'] ?? 0) + 1;
                          updateOrderStatus(orders[index].id, newStatus);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff2bd1ff), // Button background
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8), // Decrease for less curve
                          ),
                          // Text/icon color
                        ),
                        child: Text("${nextStatus[order['status']+1]}"),
                      ),
                    )
              );
            },
          );
        },
      ),
    );
  }
}
