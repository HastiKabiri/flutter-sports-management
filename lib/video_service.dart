import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';

class VideoService {
  final Uri base;
  VideoService({required this.base});

  // Request the backend to create/clip a highlight; returns clip id or URL
  Future<String> requestClip(
    String matchId, {
    int start = 0,
    int end = 10,
  }) async {
    final uri = base.replace(path: '${base.path}/api/request-clip');
    final res = await http.post(
      uri,
      body: jsonEncode({'matchId': matchId, 'start': start, 'end': end}),
      headers: {'Content-Type': 'application/json'},
    );
    if (res.statusCode == 200) {
      final js = jsonDecode(res.body);
      return js['clipUrl'] as String? ?? '';
    }
    throw Exception('Clip request failed: ${res.statusCode}');
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String url;
  const VideoPlayerWidget({super.key, required this.url});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        setState(() => _initialized = true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) return const Center(child: CircularProgressIndicator());
    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: Stack(
        children: [
          VideoPlayer(_controller),
          Positioned(
            bottom: 8,
            left: 8,
            child: FloatingActionButton(
              mini: true,
              onPressed: () => setState(
                () => _controller.value.isPlaying
                    ? _controller.pause()
                    : _controller.play(),
              ),
              child: Icon(
                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
