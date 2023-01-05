import 'package:example/Const/env.dart';
import 'package:flutter/material.dart';
import 'package:galli360viewer/galli360viewer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Galli 360 Viewer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Galli 360 Viewer'),
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
  Galli360 galli = Galli360(token);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Viewer(
          controller: galli,
          onSaved: ((x, y) => {print("$x,$y")}),
          pinX: 10.189151195944662,
          pinY: 66.2590812683003,
          coordinate:
              LatLng(latitude: 27.68443083270, longitude: 85.30315578664)),
    );
  }
}
