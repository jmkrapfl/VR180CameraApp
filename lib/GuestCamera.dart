import 'dart:async';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';

class GuestCamera extends StatefulWidget {
  final List<CameraDescription> cameras;
  final List<Device> connectedDevices;

  const GuestCamera({required this.cameras, required this.connectedDevices});

  @override
  _GuestCameraState createState() => _GuestCameraState();
}

class _GuestCameraState extends State<GuestCamera> {
  late CameraController controller;
  late Future<void> _initializeControllerFuture;
  late StreamSubscription subscription;
  late StreamSubscription receivedDataSubscription;
  late NearbyService nearbyService;
  List<Device> devices = [];

  @override
  void initState() {
    nearbyService = NearbyService();
    super.initState();
    //scan();
    controller = CameraController(
      widget.cameras[0],
      ResolutionPreset.veryHigh,
    );
    controller.initialize().then((_) {
       controller.lockCaptureOrientation(DeviceOrientation.portraitUp);
      if (!mounted) {
        return;
      }
      setState(() {});
    });
    _initializeControllerFuture = controller.initialize();
  }

  @override
void dispose() {
  controller.dispose();
  subscription.cancel();
  receivedDataSubscription.cancel();
  super.dispose();
}

  @override
  Widget build(BuildContext context) {//builds the guest camera page
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('waiting for host'),
          actions: [
            Icon(widget.connectedDevices.isNotEmpty 
              ? Icons.check_circle_rounded
              : Icons.cancel_rounded,
              color: widget.connectedDevices.isNotEmpty
              ? Colors.green
              : Colors.red,
        )],
          ),
      
        body: FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              // If the Future is complete, display the preview.
              return CameraPreview(controller);
            } else {
              // Otherwise, display a loading indicator.
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}