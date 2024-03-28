import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:gallery_saver/gallery_saver.dart';



class TempGuestViewVideo extends StatefulWidget{
  final String filePath;
  final List<Device> connectedDevices;
  const TempGuestViewVideo({required this.filePath, required this.connectedDevices});
  @override
  _HostViewVideoState createState() => _HostViewVideoState();
}

class _HostViewVideoState extends State<TempGuestViewVideo> {
  late VideoPlayerController _videoPlayerController;
  late NearbyService nearbyService;
  String albumName = 'Media';
  @override
  void initState() {
    nearbyService=NearbyService();
    super.initState();
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  Future _initVideoPlayer() async {//initalize the video player
    _videoPlayerController = VideoPlayerController.file(File(widget.filePath));
    await _videoPlayerController.initialize();
    await _videoPlayerController.setLooping(true);
    await _videoPlayerController.play();
  }

  @override
  Widget build(BuildContext context) {// builds the guest view video page
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview'),
        actions: [//connection status
          Icon(widget.connectedDevices.isNotEmpty 
            ? Icons.check_circle_rounded
            : Icons.cancel_rounded,
            color: widget.connectedDevices.isNotEmpty
            ? Colors.green
            : Colors.red,
        ),
        IconButton(//save to camera roll icon button
          onPressed: ()async
          {
            print(widget.filePath);
            await GallerySaver.saveVideo(widget.filePath, albumName: albumName);
          }, 
          icon: const Icon(Icons.save_alt_rounded)
        ),
        ],
        
      ),
      extendBodyBehindAppBar: true,
      body: FutureBuilder(
        future: _initVideoPlayer(),
        builder: (context, state) {
          if (state.connectionState == ConnectionState.waiting) {//if the video is not loaded display a progress indicator
            return const Center(child: CircularProgressIndicator());
          } else {//else display the video
            return VideoPlayer(_videoPlayerController);
          }
        },
      ),
    );
  }
}