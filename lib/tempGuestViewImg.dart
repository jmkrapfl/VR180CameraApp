import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:gallery_saver/gallery_saver.dart';


class tempGuestViewImage extends StatelessWidget{
  final String imagePath;
  final List<Device> connectedDevices;
  const tempGuestViewImage({required this.imagePath, required this.connectedDevices}); 
  
  @override 
  Widget build(BuildContext context) { //builds the guest view camera button
    return Scaffold( 
      appBar: AppBar(
        title: const Text('View image screen'),
        actions: [
          Icon(connectedDevices.isNotEmpty //connection status icon
            ? Icons.check_circle_rounded
            : Icons.cancel_rounded,
            color: connectedDevices.isNotEmpty
            ? Colors.green
            : Colors.red,
        ),
        IconButton(//save to camera roll icon button
          onPressed: ()
          {
            print(imagePath);
            GallerySaver.saveImage(imagePath);
          }, 
          icon: const Icon(Icons.save_alt_rounded))
        ]
        ), 
      body: Image.file(File(imagePath)),
    ); 
  } 
}