import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:vr180cameraapp/HostPage.dart';
import 'deviceType.dart';
import 'package:rename_app/rename_app.dart';
//To run on both phones: open 2 terminals in t1 run:          flutter run -d 00008020-001D51302621002E    for iphone xr
//and on t2 run:                                              flutter run -d 00008110-000E24AE3CC0A01E    for iphone 14                                         
//note these are the device IDs just for the phones used every phone has a different one

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])//locks the orientation of the screen
      .then((value) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VR 180 Camera app',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'VR 180 Camera app'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {//builds the main page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(//app bar contents
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column( //body contents
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          //text explaining what to do
          Text(
            "Press the host button on the device you want to use to connect and take the pictures or videos from.",
            style: TextStyle(fontSize: 16),
          ),
          Text(
            "Press the guest button on the device you want to connect to.",
            style: TextStyle(fontSize: 16),
          ),
          Wrap(
            direction: Axis.vertical,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.all(10),
                child: FloatingActionButton(
                  onPressed: () async {
                    List<CameraDescription> cameras = await availableCameras();//creates the list of available cameras
                    //navigates to the Host Page and passes over the device type and the cameras since it is a browser it will use the host page layout
                    Navigator.push(context,MaterialPageRoute(builder: (context) => HostPage(deviceType: DeviceType.browser, cameras: cameras,),),);
                  },
                  child: const Text("Host"),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(10),
                child: FloatingActionButton(
                  onPressed: () async {
                    List<CameraDescription> cameras = await availableCameras();// create the list of cameras
                    //navigates to the Host Page and passes over the device type and the cameras since it is an advertiser it will use the guests page layout
                    Navigator.push(context,MaterialPageRoute(builder: (context) => HostPage(deviceType: DeviceType.advertiser,cameras: cameras,),),);
                  },
                  backgroundColor: Colors.deepPurpleAccent,
                  child: const Text("Guest"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
