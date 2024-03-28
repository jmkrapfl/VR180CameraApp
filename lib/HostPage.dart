import 'dart:async';
import 'dart:io';
//packges
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'deviceType.dart';

//pages
import 'package:vr180cameraapp/HostCamera.dart';
import 'package:vr180cameraapp/GuestCamera.dart';
import 'package:vr180cameraapp/tempGuestViewImg.dart';
import 'package:vr180cameraapp/tempGuestViewVideo.dart';

class HostPage extends StatefulWidget {
  final List<CameraDescription> cameras;
  final DeviceType deviceType;
  HostPage({required this.deviceType, required this.cameras});
  
  
  @override
  _HostPageState createState() => _HostPageState();
}

class _HostPageState extends State<HostPage>
{
  bool _isRecording = false;

  late CameraController controller;
  late Future<void> _initializeControllerFuture;

  List<Device> devices = [];
  List<Device> connectedDevices = [];
  late NearbyService nearbyService;
  late StreamSubscription subscription;
  late StreamSubscription receivedDataSubscription;


  @override
  void initState() {
  super.initState();
  initNearbyService();
  controller = CameraController(//this was added for the guest camera
      widget.cameras[0],// first camera in the list
      ResolutionPreset.veryHigh,//set resolution
    );
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
    // Next initialize the controller this returns a Future
    _initializeControllerFuture = controller.initialize();
  }

   @override
  void dispose() {
    subscription.cancel();
    receivedDataSubscription.cancel();
    //nearbyService.stopBrowsingForPeers();
    //nearbyService.stopAdvertisingPeer();
    super.dispose();
  }
 
  @override// build the page
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(// app bar contents
        title: Text('Select a guest '+ widget.deviceType.toString().substring(11).toUpperCase()),// title and it also displays what device type it is this was mainly used for testing
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if(widget.deviceType==DeviceType.browser)//show the continue button only if devivetype is a browser
          Container(
            margin: const EdgeInsets.all(10),
            child: 
              ElevatedButton(//continue button on the host screen
                onPressed: () async{
                  if(connectedDevices != connectedDevices.isEmpty && widget.deviceType==DeviceType.browser)
                  //if the list of connected devices are not empty and the device is the browser (host) then
                  //let it navigate to the camera page 
                  {
                    nearbyService.sendMessage(connectedDevices[0].deviceId,"Continue");//sends the continue message to the guest device

                      //List<CameraDescription> cameras = await availableCameras();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HostCamera(cameras: widget.cameras,connectedDevices: connectedDevices),
                        ),
                      );
                  }
                
                },
                style: ElevatedButton.styleFrom(
                primary: connectedDevices.isNotEmpty ? Colors.green : Colors.grey,//
                onPrimary: Colors.white,
                ),
                child: Text("Continue"),
              ),
          ),
        ],
      ),
      body: ListView.builder(//builds the boxes that will come up as the browser picks up more devices that are advertizing
            itemCount: getItemCount(),
            itemBuilder: (context, index) {
              final device = widget.deviceType == DeviceType.advertiser
                  ? connectedDevices[index]
                  : devices[index];
              return Container(
                margin: EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                          Expanded(
                          child: Column(
                            children: [// device name
                              Text(device.deviceName),
                              Text(
                                getStateName(device.state),
                                style: TextStyle(
                                    color: getStateColor(device.state)),
                              ),
                            ],
                            crossAxisAlignment: CrossAxisAlignment.start,
                          ),
                        ),
                        // Request connect
                        GestureDetector(
                          onTap: () => _onButtonClicked(device),//calls the connecting function
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 8.0),
                            padding: EdgeInsets.all(8.0),
                            height: 35,
                            width: 100,
                            color: getButtonColor(device.state), //gets the color of the connecting button
                            child: Center(
                              child: Text(
                                getButtonStateName(device.state),// gets the name of the connecting button
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Divider(
                      height: 1,
                      color: Colors.grey,
                    )
                  ],
      ),
      );
    }));



  String getStateName(SessionState state) {//gets the state of the device that displays under the device name
    switch (state) {
      case SessionState.notConnected:
        return "disconnected";
      case SessionState.connecting:
        return "waiting";
      default:
        return "connected";
    }
  }

  Color getStateColor(SessionState state) {//gets the state of connection and then sets the color of the text under the device name
    switch (state) {
      case SessionState.notConnected:
        return Colors.black;
      case SessionState.connecting:
        return Colors.grey;
      default:
        return Colors.green;
    }
  }

  String getButtonStateName(SessionState state) {//gets the state of the connection and this sets what the button says
    switch (state) {
      case SessionState.notConnected:
      case SessionState.connecting:
        return "Connect";
      default:
        return "Disconnect";
    }
  }


  Color getButtonColor(SessionState state) {//gets the color of the connecting button
    switch (state) {
      case SessionState.notConnected:
      case SessionState.connecting:
        return Colors.green;
      default:
        return Colors.red;
    }
  }

  int getItemCount() {
    if (widget.deviceType == DeviceType.advertiser) {//gets the number of advertizer devices
      return connectedDevices.length;
    } else {
      return devices.length;
    }
  }

  _onButtonClicked(Device device) {// connects the devices
    switch (device.state) {
      case SessionState.notConnected:
        nearbyService.invitePeer(
          deviceID: device.deviceId,
          deviceName: device.deviceName,
        );
        break;
      case SessionState.connected:
        nearbyService.disconnectPeer(deviceID: device.deviceId);
        break;
      case SessionState.connecting:
        break;
    }
  }

Future<void> navigateToGuestCamera() async { //tells the guest to navigate to the camera when this is called
    List<CameraDescription> cameras = await availableCameras();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GuestCamera(cameras: cameras,connectedDevices: connectedDevices),
      ),
    );
  }

  void initNearbyService() async { //initiallizes the nearby services for the device connections
    nearbyService = NearbyService();
    String devInfo = '';
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {//gets andriod device info
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      devInfo = androidInfo.model;
    }
    if (Platform.isIOS) {//gets ios device info
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      devInfo = iosInfo.localizedModel;
    }
    await nearbyService.init(
        serviceType: 'mpconn',
        deviceName: devInfo,
        strategy: Strategy.P2P_CLUSTER,
        callback: (isRunning) async {
          if (isRunning) {
            if (widget.deviceType == DeviceType.browser) {//handels the browser and searches for advertizers

              await nearbyService.stopBrowsingForPeers();
              await Future.delayed(Duration(microseconds: 200));
              await nearbyService.startBrowsingForPeers();
            } else {//handles the advertizer and when to start and stop advertizing
              await nearbyService.stopAdvertisingPeer();
              await nearbyService.stopBrowsingForPeers();
              await Future.delayed(Duration(microseconds: 200));
              await nearbyService.startAdvertisingPeer();
              await nearbyService.startBrowsingForPeers();
            }
          }
        });
    subscription =//prints out useful information about the state of the devices to the terminal
        nearbyService.stateChangedSubscription(callback: (devicesList) {
      devicesList.forEach((element) {
        print(
            " deviceId: ${element.deviceId} | deviceName: ${element.deviceName} | state: ${element.state}");

        if (Platform.isAndroid) {
          if (element.state == SessionState.connected) {
            nearbyService.stopBrowsingForPeers();
          } else {
            nearbyService.startBrowsingForPeers();
          }
        }
      });

      setState(() {//sets the state of the devices
        devices.clear();
        devices.addAll(devicesList);
        connectedDevices.clear();
        connectedDevices.addAll(devicesList
            .where((d) => d.state == SessionState.connected)
            .toList());
      });
    });
      //this is where the messages are received
      receivedDataSubscription =
        nearbyService.dataReceivedSubscription(callback: (data) {
        Message message = Message.fromJson(data);
        print(message.message);
        if(message.message=="Continue")
        {
          navigateToGuestCamera();
        } 
        else if(message.message=="picture")
        {
          print(message.message);
          takePic();
        } 
        else if(message.message=="video")
        {
          print(message.message);
          takeVideo();
        }
      });
  }

  takePic()async{
    print("taking a pic on guest");
    try {
      // ensure the camera is initialized.
      await _initializeControllerFuture;
        //take a picture and get the file where it was saved
        final image = await controller.takePicture();

        if (!mounted) return;
          // If the picture was taken display it on a new screen
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => tempGuestViewImage(
                // pass the generated path to the guest view image screen
                imagePath: image.path, connectedDevices: connectedDevices,
              ),
            ),
          );
          //Message("iPhone", image.path);//were attempts were made at passing images to the other phone
    } catch (e) {
      print(e);
    }
  }

  takeVideo()async{
    print("taking a video on guest");
    try {
      if (_isRecording) { //if its recording stop
        final file = await controller.stopVideoRecording();
        setState(() => _isRecording = false);
        final route = MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => TempGuestViewVideo(filePath: file.path, connectedDevices: connectedDevices,),//pass the file to the guest view video page
        );
        Navigator.push(context, route);
      } else { //its not recording start
        await controller.prepareForVideoRecording();
        await controller.startVideoRecording();
        setState(() => _isRecording = true);
      }
      } catch (e) {
      print("Error during video recording: $e");
    }
  }
}
