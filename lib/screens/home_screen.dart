import 'package:flutter/material.dart';
import 'dart:math';
import 'package:voiceapp/services/audio_player_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const Color primaryColor = Color(0xFFD4E157);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTabIndex = 0;
  int _selectedNavIndex = 0;

  final List<AudioPost> audioPostsMockData = [
    AudioPost(
      id: '1',
      username: '@sarah_sounds',
      displayName: 'Sarah',
      avatar:
          'https://ui-avatars.com/api/?name=Sarah&background=D4E157&color=000',
      timeAgo: '2 mins ago',
      duration: '0:45',
      title: 'Storytime: That one time I got lost in Berlin after a concert... 🎵',
      waveformImage:
          'https://via.placeholder.com/400x80/1a1a1a/D4E157?text=Waveform1',
      tags: ['#travel', '#storytime'],
      likes: 1200,
      comments: 850,
      shares: 420,
      audioUrl: 'https://pixabay.com/sound-effects/film-special-effects-thud-sound-effect-405470/#:~:text=99%20kB-,Download,-1.1K',
    ),
    AudioPost(
      id: '2',
      username: '@alex_vibes',
      displayName: 'Alex',
      avatar:
          'https://ui-avatars.com/api/?name=Alex&background=D4E157&color=000',
      timeAgo: '15 mins ago',
      duration: '0:12',
      title: 'New synth loop I recorded this morning. Thoughts? 🎹',
      waveformImage:
          'https://via.placeholder.com/400x80/1a1a1a/D4E157?text=Waveform2',
      tags: ['#music', '#production'],
      likes: 450,
      comments: 170,
      shares: 89,
      audioUrl: 'assets/audio/sample2.mp3',
    ),
    AudioPost(
      id: '3',
      username: '@luna_voice',
      displayName: 'Luna',
      avatar:
          'https://ui-avatars.com/api/?name=Luna&background=D4E157&color=000',
      timeAgo: '45 mins ago',
      duration: '2:30',
      title: 'Deep dive into podcast production tips for beginners',
      waveformImage:
          'https://via.placeholder.com/400x80/1a1a1a/D4E157?text=Waveform3',
      tags: ['#podcast', '#education'],
      likes: 2100,
      comments: 340,
      shares: 560,
      audioUrl: 'assets/audio/sample3.mp3',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const _Header(),
                const SizedBox(height: 16),
                _TabBar(
                  selectedIndex: _selectedTabIndex,
                  onTabSelected: (index) {
                    setState(() {
                      _selectedTabIndex = index;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: audioPostsMockData.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _AudioCard(post: audioPostsMockData[index]),
                      );
                    },
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 80,
              right: 20,
              child: _FloatingMicButton(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _BottomNavBar(
        selectedIndex: _selectedNavIndex,
        onNavSelected: (index) {
          setState(() {
            _selectedNavIndex = index;
          });
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: HomeScreen.primaryColor.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: const Center(
              child: Icon(Icons.person, color: HomeScreen.primaryColor),
            ),
          ),
          const Text(
            'Home Feed',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.search, color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;

  const _TabBar({
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = ['For You', 'Following', 'Trending'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(
          tabs.length,
          (index) => Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => onTabSelected(index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: selectedIndex == index
                      ? HomeScreen.primaryColor
                      : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: selectedIndex != index
                      ? Border.all(color: Colors.white10)
                      : null,
                ),
                child: Text(
                  tabs[index],
                  style: TextStyle(
                    color: selectedIndex == index ? Colors.black : Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AudioCard extends StatefulWidget {
  final AudioPost post;

  const _AudioCard({required this.post});

  @override
  State<_AudioCard> createState() => _AudioCardState();
}

class _AudioCardState extends State<_AudioCard> with TickerProviderStateMixin {
  bool _isPlaying = false;
  late AnimationController _waveformController;

  @override
  void initState() {
    super.initState();
    _waveformController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _waveformController.dispose();
    super.dispose();
  }

 void _togglePlayback() {
  final audioService = AudioPlayerService();
  setState(() {
    _isPlaying = !_isPlaying;
    if (_isPlaying) {
      _waveformController.repeat();
      audioService.playAudio(widget.post.audioUrl);
    } else {
      _waveformController.stop();
      audioService.pauseAudio();
    }
  });
}

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage:
                          NetworkImage(widget.post.avatar),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.post.username,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${widget.post.timeAgo} • ${widget.post.duration}',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Icon(Icons.more_vert, color: Colors.white30, size: 20),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            height: 200,
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                _Waveform(
                  isPlaying: _isPlaying,
                  animationController: _waveformController,
                ),
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _togglePlayback,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: HomeScreen.primaryColor,
                    ),
                    child: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.black,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.post.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: List.generate(
                    widget.post.tags.length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: HomeScreen.primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.post.tags[index],
                          style: const TextStyle(
                            color: HomeScreen.primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _EngagementButton(
                      icon: Icons.favorite_outline,
                      count: widget.post.likes,
                      color: HomeScreen.primaryColor,
                    ),
                    _EngagementButton(
                      icon: Icons.chat_bubble_outline,
                      count: widget.post.comments,
                    ),
                    _EngagementButton(
                      icon: Icons.emoji_emotions_outlined,
                      count: widget.post.shares,
                    ),
                    const Icon(Icons.share, color: Colors.white30),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EngagementButton extends StatelessWidget {
  final IconData icon;
  final int count;
  final Color color;

  const _EngagementButton({
    required this.icon,
    required this.count,
    this.color = Colors.white30,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            count.toString(),
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _FloatingMicButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Implement microphone recording
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: HomeScreen.primaryColor,
          boxShadow: [
            BoxShadow(
              color: HomeScreen.primaryColor.withOpacity(0.4),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(
          Icons.mic,
          color: Colors.black,
          size: 24,
        ),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onNavSelected;

  const _BottomNavBar({
    required this.selectedIndex,
    required this.onNavSelected,
  });

  @override
  Widget build(BuildContext context) {
    final navItems = [
      {'icon': Icons.home, 'label': 'Home'},
      {'icon': Icons.explore, 'label': 'Explore'},
      {'icon': Icons.notifications, 'label': 'Alerts'},
      {'icon': Icons.person, 'label': 'Profile'},
    ];

    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          navItems.length,
          (index) => GestureDetector(
            onTap: () => onNavSelected(index),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  navItems[index]['icon'] as IconData,
                  color: selectedIndex == index
                      ? HomeScreen.primaryColor
                      : Colors.white30,
                ),
                const SizedBox(height: 4),
                Text(
                  navItems[index]['label'] as String,
                  style: TextStyle(
                    color: selectedIndex == index
                        ? HomeScreen.primaryColor
                        : Colors.white30,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Waveform extends StatelessWidget {
  final bool isPlaying;
  final AnimationController animationController;

  const _Waveform({
    required this.isPlaying,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _WaveformPainter(
        isPlaying: isPlaying,
        animation: animationController,
      ),
      size: const Size(double.infinity, double.infinity),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final bool isPlaying;
  final Animation<double> animation;

  _WaveformPainter({
    required this.isPlaying,
    required this.animation,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4E157)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final barWidth = 4.0;
    final spacing = 2.0;
    final totalBars = ((size.width / (barWidth + spacing)).toInt());
    final centerY = size.height / 2;

    for (int i = 0; i < totalBars; i++) {
      final x = i * (barWidth + spacing) + 8;
      
      // Generate pseudo-random height for each bar
      final seed = i * 12.5;
      final baseHeight = (size.height * 0.3) + 
          ((sin(seed) * 0.5 + 0.5) * size.height * 0.5);
      
      // Animate bars when playing
      final animatedHeight = isPlaying
          ? baseHeight * (0.5 + 0.5 * sin(seed + animation.value).abs())
          : baseHeight * 0.3;

      canvas.drawLine(
        Offset(x, centerY - animatedHeight / 2),
        Offset(x, centerY + animatedHeight / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter oldDelegate) => true;
}

class AudioPost {
  final String id;
  final String username;
  final String displayName;
  final String avatar;
  final String timeAgo;
  final String duration;
  final String title;
  final String waveformImage;
  final List<String> tags;
  final int likes;
  final int comments;
  final int shares;
  final String audioUrl;

  AudioPost({
    required this.id,
    required this.username,
    required this.displayName,
    required this.avatar,
    required this.timeAgo,
    required this.duration,
    required this.title,
    required this.waveformImage,
    required this.tags,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.audioUrl,
  });
}
