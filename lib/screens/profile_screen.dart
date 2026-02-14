import 'package:flutter/material.dart';
import 'dart:math';
import 'package:voiceapp/assets/constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  int _selectedTabIndex = 0;
  int? _playingSnippetIndex;
  late AnimationController _waveformController;

  final List<Snippet> _snippets = [
    Snippet(
      title: 'Monday Morning Rant',
      emoji: '\u{1F921}',
      timeAgo: '2 hours ago',
      listens: '2.4k',
      likes: '184',
      currentTime: '0:42',
      totalTime: '2:15',
    ),
    Snippet(
      title: 'New Beat Demo [WIP]',
      emoji: '\u{1F3B9}',
      timeAgo: 'Yesterday',
      listens: '8.1k',
      likes: '1.2k',
      currentTime: '0:00',
      totalTime: '1:45',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _waveformController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _waveformController.dispose();
    super.dispose();
  }

  void _togglePlayback(int index) {
    setState(() {
      if (_playingSnippetIndex == index) {
        _playingSnippetIndex = null;
        _waveformController.stop();
      } else {
        _playingSnippetIndex = index;
        _waveformController.repeat();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const _ProfileHeader(),
              const SizedBox(height: 24),
              const _Avatar(),
              const SizedBox(height: 16),
              const _UserInfo(),
              const SizedBox(height: 24),
              const _ActionButtons(),
              const SizedBox(height: 24),
              const _StatsRow(),
              const SizedBox(height: 24),
              _TabBar(
                selectedIndex: _selectedTabIndex,
                onTabSelected: (index) {
                  setState(() {
                    _selectedTabIndex = index;
                  });
                },
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Snippets',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Icon(
                          Icons.tune,
                          color: Colors.white.withOpacity(0.5),
                          size: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(
                      _snippets.length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _SnippetCard(
                          snippet: _snippets[index],
                          isPlaying: _playingSnippetIndex == index,
                          onPlayPressed: () => _togglePlayback(index),
                          animationController: _waveformController,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
          ),
          const Text(
            'Profile',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child:
                const Icon(Icons.more_horiz, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Constants.primaryColor.withOpacity(0.6),
          width: 3,
        ),
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/icons/profile.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return CircleAvatar(
              radius: 52,
              backgroundColor: Constants.primaryColor.withOpacity(0.2),
              child: const Icon(
                Icons.person,
                size: 48,
                color: Constants.primaryColor,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _UserInfo extends StatelessWidget {
  const _UserInfo();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          '@audio_max',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Voice-first creator. Sharing daily vibes. \u{1F399}',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_on,
              size: 14,
              color: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(width: 4),
            Text(
              'New York, NY',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(21),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: const Center(
                child: Text(
                  'Follow',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: Constants.primaryColor,
                borderRadius: BorderRadius.circular(21),
              ),
              child: const Center(
                child: Text(
                  'Message',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: const [
          Expanded(child: _StatCard(value: '12.5k', label: 'FOLLOWERS')),
          SizedBox(width: 10),
          Expanded(child: _StatCard(value: '842', label: 'FOLLOWING')),
          SizedBox(width: 10),
          Expanded(child: _StatCard(value: '1.2M', label: 'PLAYS')),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;

  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Constants.primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.5),
              letterSpacing: 0.5,
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

  const _TabBar({required this.selectedIndex, required this.onTabSelected});

  @override
  Widget build(BuildContext context) {
    final tabs = ['Snippets', 'Liked', 'About'];

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: Row(
        children: List.generate(
          tabs.length,
          (index) => Expanded(
            child: GestureDetector(
              onTap: () => onTabSelected(index),
              child: Container(
                padding: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: selectedIndex == index
                          ? Constants.primaryColor
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  tabs[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: selectedIndex == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.4),
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

class _SnippetCard extends StatelessWidget {
  final Snippet snippet;
  final bool isPlaying;
  final VoidCallback onPlayPressed;
  final AnimationController animationController;

  const _SnippetCard({
    required this.snippet,
    required this.isPlaying,
    required this.onPlayPressed,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onPlayPressed,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Constants.primaryColor,
                  ),
                  child: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${snippet.title} ${snippet.emoji}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      snippet.timeAgo,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Icon(Icons.headphones, size: 14, color: Colors.white.withOpacity(0.5)),
                  const SizedBox(width: 4),
                  Text(
                    snippet.listens,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.favorite, size: 14, color: Colors.white.withOpacity(0.5)),
                  const SizedBox(width: 4),
                  Text(
                    snippet.likes,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 40,
            child: CustomPaint(
              painter: _SnippetWaveformPainter(
                isPlaying: isPlaying,
                animation: animationController,
              ),
              size: const Size(double.infinity, 40),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                snippet.currentTime,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
              Text(
                snippet.totalTime,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SnippetWaveformPainter extends CustomPainter {
  final bool isPlaying;
  final Animation<double> animation;

  _SnippetWaveformPainter({
    required this.isPlaying,
    required this.animation,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final activePaint = Paint()
      ..color = Constants.primaryColor
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final inactivePaint = Paint()
      ..color = Constants.primaryColor.withOpacity(0.3)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final barWidth = 2.5;
    final spacing = 1.5;
    final totalBars = ((size.width / (barWidth + spacing)).toInt());
    final centerY = size.height / 2;
    final progressBars = (totalBars * 0.3).toInt();

    for (int i = 0; i < totalBars; i++) {
      final x = i * (barWidth + spacing);
      final seed = i * 12.5;
      final baseHeight =
          (size.height * 0.3) + ((sin(seed) * 0.5 + 0.5) * size.height * 0.4);

      final animatedHeight = isPlaying
          ? baseHeight * (0.5 + 0.5 * sin(seed + animation.value * 6.28).abs())
          : baseHeight * 0.6;

      final paint = i < progressBars ? activePaint : inactivePaint;

      canvas.drawLine(
        Offset(x, centerY - animatedHeight / 2),
        Offset(x, centerY + animatedHeight / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_SnippetWaveformPainter oldDelegate) => true;
}

class Snippet {
  final String title;
  final String emoji;
  final String timeAgo;
  final String listens;
  final String likes;
  final String currentTime;
  final String totalTime;

  Snippet({
    required this.title,
    required this.emoji,
    required this.timeAgo,
    required this.listens,
    required this.likes,
    required this.currentTime,
    required this.totalTime,
  });
}
