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

                // trailing: buildOrderProgress(order['status']),

// Widget buildOrderProgress(int status) {
//   final stages = ["Pending", "Confirmed", "On the Way", "Delivered"];
//   return Row(
//     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//     children: List.generate(4, (index) {
//       bool isCompleted = index <= status;
//       return Column(
//         children: [
//           Container(
//             width: 24,
//             height: 24,
//             decoration: BoxDecoration(
//               color: isCompleted ? Colors.green : Colors.grey[300],
//               shape: BoxShape.circle,
//             ),
//             child: isCompleted
//                 ? Icon(Icons.check, size: 16, color: Colors.white)
//                 : null,
//           ),
//           SizedBox(height: 4),
//           Text(stages[index], style: TextStyle(fontSize: 10)),
//         ],
//       );
//     }),
//   );
//
// }

// Widget buildOrderProgress(int status) {
//   final stages = ["Pending", "Confirmed", "On the Way", "Delivered"];
//   return Row(
//     children: List.generate(stages.length * 2 - 1, (index) {
//       if (index % 2 == 0) {
//         int step = index ~/ 2;
//         bool isComplete = step <= status;
//         return Column(
//           children: [
//             Icon(
//               isComplete ? Icons.check_circle : Icons.radio_button_unchecked,
//               color: isComplete ? Colors.green : Colors.grey,
//             ),
//             SizedBox(height: 4),
//             Text(
//               stages[step],
//               style: TextStyle(fontSize: 12),
//             )
//           ],
//         );
//       } else {
//         return Expanded(
//           child: Divider(
//             color: status >= (index ~/ 2) ? Colors.green : Colors.grey,
//             thickness: 2,
//           ),
//         );
//       }
//     }),
//   );
// }
