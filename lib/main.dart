import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MusicPlayerPage(),
    );
  }
}

class MusicPlayerPage extends StatefulWidget {
  const MusicPlayerPage({super.key});

  @override
  State<MusicPlayerPage> createState() => _MusicPlayerPageState();
}

class _MusicPlayerPageState extends State<MusicPlayerPage>
    with SingleTickerProviderStateMixin {
  final AudioPlayer audioPlayer = AudioPlayer();

  late AnimationController rotationController;

  List<Map<String, String>> songs = [
    {
      'title': 'Melancholy Lull',
      'file': 'songs/bensound-melancholylull.mp3',
      'image': 'assets/images/firstsong.jpg',
    },

    {
      'title': 'Dawn Of Change',
      'file': 'songs/bensound-dawnofchange.mp3',
      'image': 'assets/images/secondsong.jpg',
    },

    {
      'title': 'Cozy Coffeehouse',
      'file': 'songs/bensound-cozycoffeehouse.mp3',
      'image': 'assets/images/thirdsong.jpg',
    },
  ];

  int currentSongIndex = 0;

  Duration currentPosition = Duration.zero;
  Duration totalDuration = Duration.zero;

  bool isPlaying = false;
  bool isRepeat = false;

  double volume = 1.0;

  @override
  void initState() {
    super.initState();

    rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );

    audioPlayer.onPositionChanged.listen((Duration position) {
      setState(() {
        currentPosition = position;
      });
    });

    audioPlayer.onDurationChanged.listen((Duration duration) {
      setState(() {
        totalDuration = duration;
      });
    });

    audioPlayer.onPlayerComplete.listen((event) {
      if (isRepeat) {
        playSong();
      } else {
        nextSong();
      }
    });
  }

  Future<void> playSong() async {
    await audioPlayer.play(AssetSource(songs[currentSongIndex]['file']!));

    rotationController.repeat();

    setState(() {
      isPlaying = true;
    });
  }

  Future<void> pauseSong() async {
    await audioPlayer.pause();

    rotationController.stop();

    setState(() {
      isPlaying = false;
    });
  }

  Future<void> nextSong() async {
    if (currentSongIndex < songs.length - 1) {
      currentSongIndex++;
    } else {
      currentSongIndex = 0;
    }

    playSong();

    setState(() {});
  }

  Future<void> previousSong() async {
    if (currentSongIndex > 0) {
      currentSongIndex--;
    } else {
      currentSongIndex = songs.length - 1;
    }

    playSong();

    setState(() {});
  }

  Future<void> shuffleSong() async {
    final random = Random();

    currentSongIndex = random.nextInt(songs.length);

    playSong();

    setState(() {});
  }

  String formatTime(Duration duration) {
    String minutes = duration.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');

    String seconds = duration.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');

    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    rotationController.dispose();
    audioPlayer.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF120000),
              Color(0xFF3B0000),
              Color(0xFF6A1B00),
              Color(0xFF120000),
            ],

            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),

              child: Column(
                children: [
                  const SizedBox(height: 10),

                  const Text(
                    "My Music Player",

                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(height: 35),

                  RotationTransition(
                    turns: rotationController,

                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,

                        boxShadow: [
                          BoxShadow(
                            color: Colors.redAccent.withOpacity(0.5),
                            blurRadius: 35,
                            spreadRadius: 10,
                          ),
                        ],
                      ),

                      child: ClipOval(
                        child: Image.asset(
                          songs[currentSongIndex]['image']!,

                          width: 250,
                          height: 250,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 35),

                  Text(
                    songs[currentSongIndex]['title']!,

                    textAlign: TextAlign.center,

                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Relax • Focus • Enjoy",

                    style: TextStyle(color: Colors.white70, fontSize: 15),
                  ),

                  const SizedBox(height: 35),

                  Slider(
                    value: currentPosition.inSeconds.toDouble(),

                    min: 0,

                    max: totalDuration.inSeconds.toDouble() > 0
                        ? totalDuration.inSeconds.toDouble()
                        : 1,

                    activeColor: Colors.amber,
                    inactiveColor: Colors.white24,

                    onChanged: (value) async {
                      await audioPlayer.seek(Duration(seconds: value.toInt()));
                    },
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        Text(
                          formatTime(currentPosition),

                          style: const TextStyle(color: Colors.white),
                        ),

                        Text(
                          formatTime(totalDuration),

                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      IconButton(
                        onPressed: shuffleSong,

                        icon: const Icon(
                          Icons.shuffle,
                          color: Colors.amber,
                          size: 28,
                        ),
                      ),

                      const SizedBox(width: 5),

                      CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.redAccent,

                        child: IconButton(
                          onPressed: previousSong,

                          icon: const Icon(
                            Icons.skip_previous,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),

                      const SizedBox(width: 18),

                      CircleAvatar(
                        radius: 38,
                        backgroundColor: Colors.amber,

                        child: IconButton(
                          onPressed: () {
                            if (isPlaying) {
                              pauseSong();
                            } else {
                              playSong();
                            }
                          },

                          icon: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,

                            color: Colors.black,
                            size: 42,
                          ),
                        ),
                      ),

                      const SizedBox(width: 18),

                      CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.redAccent,

                        child: IconButton(
                          onPressed: nextSong,

                          icon: const Icon(
                            Icons.skip_next,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),

                      const SizedBox(width: 5),

                      IconButton(
                        onPressed: () {
                          setState(() {
                            isRepeat = !isRepeat;
                          });
                        },

                        icon: Icon(
                          Icons.repeat,

                          color: isRepeat ? Colors.amber : Colors.white54,

                          size: 28,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 35),

                  Container(
                    padding: const EdgeInsets.all(20),

                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),

                      borderRadius: BorderRadius.circular(25),

                      border: Border.all(color: Colors.white12),
                    ),

                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,

                          children: [
                            const Text(
                              "Volume",

                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),

                            Icon(Icons.volume_up, color: Colors.amber.shade300),
                          ],
                        ),

                        Slider(
                          value: volume,

                          min: 0,
                          max: 1,

                          activeColor: Colors.redAccent,

                          onChanged: (value) async {
                            setState(() {
                              volume = value;
                            });

                            await audioPlayer.setVolume(value);
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 35),

                  const Align(
                    alignment: Alignment.centerLeft,

                    child: Text(
                      "Playlist",

                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    height: 170,

                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,

                      itemCount: songs.length,

                      itemBuilder: (context, index) {
                        bool isSelected = currentSongIndex == index;

                        return GestureDetector(
                          onTap: () {
                            currentSongIndex = index;

                            playSong();

                            setState(() {});
                          },

                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),

                            width: 140,

                            margin: const EdgeInsets.only(right: 18),

                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? const LinearGradient(
                                      colors: [Colors.amber, Colors.orange],
                                    )
                                  : LinearGradient(
                                      colors: [
                                        Colors.red.shade400,
                                        Colors.red.shade900,
                                      ],
                                    ),

                              borderRadius: BorderRadius.circular(28),

                              boxShadow: [
                                BoxShadow(
                                  color: isSelected
                                      ? Colors.amber.withOpacity(0.5)
                                      : Colors.black54,

                                  blurRadius: 15,
                                ),
                              ],
                            ),

                            child: Padding(
                              padding: const EdgeInsets.all(12),

                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,

                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(18),

                                    child: Image.asset(
                                      songs[index]['image']!,

                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  Text(
                                    songs[index]['title']!,

                                    textAlign: TextAlign.center,

                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.black
                                          : Colors.white,

                                      fontWeight: FontWeight.bold,

                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
