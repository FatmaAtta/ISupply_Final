import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreData {
  List<Map<String, dynamic>> _seller1 = [];
  List<Map<String, dynamic>> _buyer1 = [];
  String sellerName = "";

  Future<Map<String, dynamic>?> fetchOrderDetails(String orderID) async{
    final doc = await FirebaseFirestore.instance.collection('Orders').doc(orderID).get();
    return doc.data();
  }

  Future<List<Map<String, dynamic>>?> fetchBuyerOrders(String buyerID) async{
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Orders')
        .where('buyerID', isEqualTo: buyerID)
        .get();
    return querySnapshot.docs.map((doc)=>doc.data()).toList();
  }

  Future<List<Map<String, dynamic>>?> fetchSellerOrders(String sellerID) async{
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Orders')
        .where('sellerID', isEqualTo: sellerID)
        .get();
    return querySnapshot.docs.map((doc)=>doc.data()).toList();
  }

  Future<void> loadOrders() async {
    _seller1 = await fetchSellerOrders('Seller1') ?? [];
    _buyer1 = await fetchBuyerOrders('Buyer1') ?? [];
  }

  Future<List<Map<String, dynamic>>> getSellerOrders() async {
    if (_seller1.isEmpty) await loadOrders();
    return _seller1;
  }

  Future<List<Map<String, dynamic>>> getBuyerOrders() async {
    if (_buyer1.isEmpty) await loadOrders();
    return _buyer1;
  }

  Future<String> fetchSellerName(String sellerID) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Sellers')
        .where('sellerID', isEqualTo: sellerID)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final data = querySnapshot.docs.first.data();
      return data['name'] ?? 'Unknown Seller';
    } else {
      return 'Seller Not Found';
    }
  }

  Future<String> getSellerName(String sellerID) async {
    return await fetchSellerName(sellerID);
  }
}
