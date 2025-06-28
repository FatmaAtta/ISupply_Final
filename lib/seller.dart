import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SellerScreen extends StatelessWidget {
  final String sellerID;

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
      appBar: AppBar(title: Text("Seller Orders")),
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
                subtitle: Text("Status: ${order['status']}"),
                trailing: ElevatedButton(
                  onPressed: () {
                    int newStatus = (order['status'] ?? 0) + 1;
                    updateOrderStatus(orders[index].id, newStatus);
                  },
                  child: Text("Next Status"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
