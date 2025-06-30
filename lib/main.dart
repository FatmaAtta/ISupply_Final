import 'package:flutter/material.dart';
import 'package:isupply_final/firebase_options.dart';
import 'package:isupply_final/notifications/firebase_api.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:isupply_final/order_list.dart';

void main() async {
  //need to ensure flutter is initialized first
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final firebaseAPI = FirebaseAPI();
  await firebaseAPI.initNotifications();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home: OrderList(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }
  void _decrementCounter(){
    setState(() {
      _counter--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Stepper(
          type: StepperType.horizontal,
          currentStep: 2,
          steps: const [
            Step(title: Text('Pending'), content: SizedBox.shrink()),
            Step(title: Text('Confirmed'), content: SizedBox.shrink()),
            Step(title: Text('On its Way'), content: SizedBox.shrink()),
            Step(title: Text('Delivered'), content: SizedBox.shrink()),
          ],
          controlsBuilder: (context, _) => SizedBox.shrink(), // Hide Next/Back buttons
        )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
