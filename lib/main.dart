import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

void main() => runApp(VideoApp());

class VideoApp extends StatefulWidget {
  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  VideoPlayerController _controller;

  final List<String> codecOptions = [".m3u8", ".mp4"];
  final List<String> codecSources = [
    "https://mnmedias.api.telequebec.tv/m3u8/29880.m3u8",
//    "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_adv_example_hevc/master.m3u8",
    "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
  ];
  int currentCodecIndex = 0;

  final List<String> speedOptions = ["x1.0", "x.1.5", "x2.0"];
  final List<double> speedValues = [1.0, 1.5, 2.0];
  int currentSpeedIndex = 0;

  @override
  void initState() {
    super.initState();
    final controller = VideoPlayerController.network(
      codecSources[currentCodecIndex],
    );
    controller.addListener(handleControllerChanged);
    controller.initialize().then((_) async {
      await controller.play();
      setState(() {
        _controller = controller;
      });
    });
  }

  Future<void> stepController() async {
    final oldController = _controller;
    setState(() {
      _controller = null;
    });
    oldController.removeListener(handleControllerChanged);
    await oldController.pause();
    await oldController.dispose();

    currentCodecIndex = (currentCodecIndex + 1) % codecOptions.length;
    currentSpeedIndex = 0;
    final newController = VideoPlayerController.network(
      codecSources[currentCodecIndex],
    );
    newController.addListener(handleControllerChanged);
    await newController.initialize();
    await newController.play();
    setState(() {
      _controller = newController;
    });
  }

  void handleControllerChanged() {
    setState(() {});
  }

  Future<void> stepSpeed() async {
    // Comment this out if no speed functionality
    currentSpeedIndex = (currentSpeedIndex + 1) % speedOptions.length;
    final speedValue = speedValues[currentSpeedIndex];
    _controller.setSpeed(speedValue);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Demo',
      home: Scaffold(
        body: SafeArea(
          child: _controller == null
              ? Container()
              : Column(
                  children: [
                    Center(
                      child: _controller.value.initialized
                          ? AspectRatio(
                              aspectRatio: _controller.value.aspectRatio,
                              child: VideoPlayer(_controller),
                            )
                          : Container(),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Wrap(
                        children: [
                          FlatButton(
                            child: Text(
                              _controller.value.isPlaying ? "pause" : "play",
                            ),
                            onPressed: () {
                              if (_controller.value.isPlaying) {
                                _controller.pause();
                              } else {
                                _controller.play();
                              }
                            },
                            color: Colors.blue,
                          ),
                          SizedBox(width: 10),
                          FlatButton(
                            child: Text("<<"),
                            onPressed: () async {
                              final currentPosition = await _controller.position;
                              await _controller.seekTo(
                                currentPosition - Duration(seconds: 10),
                              );
                            },
                            color: Colors.blue,
                          ),
                          SizedBox(width: 10),
                          FlatButton(
                            child: Text(">>"),
                            onPressed: () async {
                              final currentPosition = await _controller.position;
                              await _controller.seekTo(
                                currentPosition + Duration(seconds: 10),
                              );
                            },
                            color: Colors.blue,
                          ),
                          SizedBox(width: 10),
                          FlatButton(
                            child: Text(
                              "Switch source (currently ${codecOptions[currentCodecIndex]})",
                            ),
                            onPressed: stepController,
                            color: Colors.amber,
                          ),
                          SizedBox(width: 10),
                          FlatButton(
                            child: Text(
                              "Switch speed (currently ${speedOptions[currentSpeedIndex]})",
                            ),
                            onPressed: stepSpeed,
                            color: Colors.amber,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
