

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:isupply_final/buyer.dart';
import 'package:isupply_final/seller.dart';

class OrderList extends StatefulWidget{
  @override
  State<OrderList> createState() => _OrderListState();
}

class OrderListController {
  static late _OrderListState _state;

  static void setInstance(_OrderListState state) {
    _state = state;
  }

  static void navigateToBuyer() {
    _state.navigateToBuyer();
  }
}

class _OrderListState extends State<OrderList>{
  int _currentIndex =0;
  final List<Widget> _screens = [
    BuyerScreen(buyerID: 'Buyer1',),
    SellerScreen(sellerID: 'Seller1',),
  ];
  @override
  void initState() {
    super.initState();
    OrderListController.setInstance(this);
  }
  void navigateToBuyer() {
    setState(() {
      _currentIndex = 0;
    });
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF234796),
        centerTitle: true,
        title: Image.asset(
            'assets/logo_light.png',
          height: 150,
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: SizedBox.shrink(),
            label: 'Buyer',
          ),
          BottomNavigationBarItem(
            icon: SizedBox.shrink(),
            label: 'Seller',
          ),
        ],
      ),
    );
  }
}


