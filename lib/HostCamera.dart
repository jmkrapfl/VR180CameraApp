import 'dart:async';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:vr180cameraapp/HostViewImage.dart';
import 'package:vr180cameraapp/HostViewVideo.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';

class HostCamera extends StatefulWidget {
  final List<CameraDescription> cameras;
  final List<Device> connectedDevices;

  const HostCamera({required this.cameras, required this.connectedDevices});

  @override
  _HostCameraState createState() => _HostCameraState();
}

class _HostCameraState extends State<HostCamera> {
  late CameraController controller;
  late Future<void> _initializeControllerFuture;
  bool _isRecording = false;

  late NearbyService nearbyService;
  late Image imgASimage;
  

  @override
  void initState() {
    super.initState();
    nearbyService = NearbyService();
    if (widget.cameras.isEmpty) {
      // No cameras available
      return;
    }

    controller = CameraController(
      widget.cameras[0],//selects the first camera in the list
      ResolutionPreset.veryHigh,//sets the resolution
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = controller.initialize().then((_) {
      controller.lockCaptureOrientation(DeviceOrientation.portraitUp);// locks the orientation
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
  controller.dispose();
  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    if (widget.cameras.isEmpty) {//if there are no cameras
      return Scaffold(
        appBar: AppBar(title: const Text('No Camera Available')),
        body: const Center(child: Text('No camera available on this device.')),
      );
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Take a picture or video'),
          actions: [
            Icon(widget.connectedDevices.isNotEmpty 
              ? Icons.check_circle_rounded
              : Icons.cancel_rounded,
              color: widget.connectedDevices.isNotEmpty
              ? Colors.green
              : Colors.red,
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: FutureBuilder<void>(
                future: _initializeControllerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    // f the Future is complete display the camera preview
                    return CameraPreview(controller);
                  } else {
                    //otherwise display a loading indicator
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(//shutter button
                  child: const Icon(Icons.camera_alt),
                  onPressed: () => _takePic(),//call the take picture function
                ),
                FloatingActionButton(//record video button
                  backgroundColor: Colors.red,
                  child: Icon(_isRecording ? Icons.stop : Icons.circle),
                  onPressed: () => _recordVideo(),// call the record video function
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }



// Record video code:
  _recordVideo() async {
    nearbyService.sendMessage(widget.connectedDevices[0].deviceId,"video");//send a message to the host page to start recording on the guest
    try {
      if (_isRecording) {//if recording stop
        final file = await controller.stopVideoRecording();
        setState(() => _isRecording = false);
        final route = MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => HostViewVideo(filePath: file.path, connectedDevices: widget.connectedDevices,),//navigate to the host view video page
        );
        Navigator.push(context, route);
      } else {//else start recording
        await controller.prepareForVideoRecording();
        await controller.startVideoRecording();
        setState(() => _isRecording = true);
      }
      } catch (e) {
      print("Error during video recording: $e");
    }
  }

  _takePic()async{
    print("taking pic");
    nearbyService.sendMessage(widget.connectedDevices[0].deviceId,"picture");//send a message to the host page to take a picture on the guest
    try {
      //ensure the camera is initialized
      await _initializeControllerFuture;
      //take a picture and get the file image where it was saved
      final image = await controller.takePicture();

      if (!mounted) return;

      //if the picture was taken display it on a new screen
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => HostViewImage(imgPath: image.path, connectedDevices: widget.connectedDevices,),//navigate to the host view image page
        ),
      );
    } catch (e) {
      print(e);
    }
  }

}


