import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:gallery_saver/gallery_saver.dart';

class HostViewImage extends StatefulWidget{
  final String imgPath;
  final List<Device> connectedDevices;
  const HostViewImage({required this.imgPath ,required this.connectedDevices}); 
  
  @override 
  _HostViewImageState createState() => _HostViewImageState();
}

class _HostViewImageState extends State<HostViewImage>{
  late NearbyService nearbyService;

  @override
  void initState() {
    nearbyService=NearbyService();
    super.initState();
  }

  Widget build(BuildContext context) { //builds the host view image page
    return Scaffold( 
      appBar: AppBar(
        title: const Text('View image screen'),
        actions: [
          Icon(widget.connectedDevices.isNotEmpty //connection status icon
            ? Icons.check_circle_rounded
            : Icons.cancel_rounded,
            color: widget.connectedDevices.isNotEmpty
            ? Colors.green
            : Colors.red,
        ),
        IconButton(//save to camera roll icon button
          onPressed: ()
          {
            print(widget.imgPath);
            GallerySaver.saveImage(widget.imgPath);
          }, 
          icon: const Icon(Icons.save_alt_rounded)
        ),
        
        ]), 
      body: Image.file(File(widget.imgPath)),
    ); 
  } 

}