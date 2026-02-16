import 'package:flutter/material.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import 'package:voiceapp/services/audio_player_service.dart';
import 'package:voiceapp/screens/comment_screen.dart';
import 'package:voiceapp/assets/constants.dart';
import 'package:voiceapp/models/voice_post.dart';
import 'package:voiceapp/providers/feed_provider.dart';
import 'package:voiceapp/services/voice_service.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});


  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeedProvider>().loadFeed();
    });
  }

  static const _tabFeedTypes = [FeedType.forYou, FeedType.following, FeedType.trending];

  void _onTabSelected(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
    context.read<FeedProvider>().loadFeed(type: _tabFeedTypes[index]);
  }

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
                  onTabSelected: _onTabSelected,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Consumer<FeedProvider>(
                    builder: (context, feedProvider, child) {
                      if (feedProvider.isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Constants.primaryColor,
                          ),
                        );
                      }
                      if (feedProvider.error != null) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Failed to load feed',
                                style: TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () => feedProvider.loadFeed(
                                  type: _tabFeedTypes[_selectedTabIndex],
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Constants.primaryColor,
                                  foregroundColor: Colors.black,
                                ),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }
                      if (feedProvider.posts.isEmpty) {
                        return const Center(
                          child: Text(
                            'No posts yet',
                            style: TextStyle(color: Colors.white54),
                          ),
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: feedProvider.posts.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _AudioCard(post: feedProvider.posts[index]),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
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
                color: Constants.primaryColor.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: const Center(
              child: Icon(Icons.person, color: Constants.primaryColor),
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

  const _TabBar({required this.selectedIndex, required this.onTabSelected});

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
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: selectedIndex == index
                      ? Constants.primaryColor
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
  final VoicePost post;

  const _AudioCard({required this.post});

  @override
  State<_AudioCard> createState() => _AudioCardState();
}

class _AudioCardState extends State<_AudioCard> with TickerProviderStateMixin {
  bool _isPlaying = false;
  bool _showReactionPicker = false;
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
                      backgroundColor: Constants.primaryColor,
                      child: Text(
                        widget.post.username.isNotEmpty
                            ? widget.post.username[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
                          '${widget.post.timeAgo} • ${widget.post.durationFormatted}',
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
                      color: Constants.primaryColor,
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
                  widget.post.title ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                if (widget.post.tags.isNotEmpty)
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
                            color: Constants.primaryColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.post.tags[index],
                            style: const TextStyle(
                              color: Constants.primaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                if (_showReactionPicker)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _ReactionPicker(
                        post: widget.post,
                        onSelected: (emoji) {
                          final key = _emojiToKey[emoji] ?? emoji;
                          context.read<FeedProvider>().reactToPost(
                            widget.post.id,
                            key,
                          );
                          setState(() {
                            _showReactionPicker = false;
                          });
                        },
                      ),
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _EngagementButton(
                      icon: Icons.favorite_outline,
                      count: widget.post.likes,
                      color: Constants.primaryColor,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CommentScreen(
                              postId: widget.post.id,
                              originalAuthor: widget.post.username,
                              originalTitle: widget.post.title ?? '',
                              audioUrl: widget.post.audioUrl,
                              duration: widget.post.durationFormatted,
                              likes: widget.post.likes,
                              commentCount: widget.post.comments,
                            ),
                          ),
                        );
                      },
                      child: _EngagementButton(
                        icon: Icons.chat_bubble_outline,
                        count: widget.post.comments,
                      ),
                    ),
                    _ReactionButton(
                      post: widget.post,
                      onTogglePicker: () {
                        setState(() {
                          _showReactionPicker = !_showReactionPicker;
                        });
                      },
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

const _reactionEmojis = ['🔥', '❤️', '👏'];
const _emojiToKey = {'🔥': 'fire', '❤️': 'heart', '👏': 'clap'};
const _keyToEmoji = {'fire': '🔥', 'heart': '❤️', 'clap': '👏'};
const _emojiStyle = TextStyle(fontFamily: 'Apple Color Emoji', fontSize: 14);

class _ReactionButton extends StatelessWidget {
  final VoicePost post;
  final VoidCallback onTogglePicker;

  const _ReactionButton({
    required this.post,
    required this.onTogglePicker,
  });

  @override
  Widget build(BuildContext context) {
    final hasReacted = post.myReaction != null;
    final topEmoji = post.topReactionEmoji;
    final totalCount = post.totalReactions;

    return GestureDetector(
      onTap: onTogglePicker,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: hasReacted
              ? Constants.primaryColor.withOpacity(0.1)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasReacted ? Constants.primaryColor.withOpacity(0.3) : Colors.white10,
          ),
        ),
        child: Row(
          children: [
            Text(
              (topEmoji != null ? _keyToEmoji[topEmoji] : null) ?? '😀',
              style: _emojiStyle,
            ),
            const SizedBox(width: 6),
            Text(
              totalCount.toString(),
              style: TextStyle(
                fontSize: 12,
                color: hasReacted ? Constants.primaryColor : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReactionPicker extends StatelessWidget {
  final VoicePost post;
  final ValueChanged<String> onSelected;

  const _ReactionPicker({
    required this.post,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _reactionEmojis.map((emoji) {
          final isSelected = post.myReaction == _emojiToKey[emoji];
          return GestureDetector(
            onTap: () => onSelected(emoji),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isSelected
                    ? Constants.primaryColor.withOpacity(0.2)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Text(emoji, style: _emojiStyle.copyWith(fontSize: 20)),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _Waveform extends StatelessWidget {
  final bool isPlaying;
  final AnimationController animationController;

  const _Waveform({required this.isPlaying, required this.animationController});

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

  _WaveformPainter({required this.isPlaying, required this.animation})
    : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Constants.primaryColor
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final barWidth = 4.0;
    final spacing = 2.0;
    final totalBars = ((size.width / (barWidth + spacing)).toInt());
    final centerY = size.height / 2;

    for (int i = 0; i < totalBars; i++) {
      final x = i * (barWidth + spacing) + 8;

      final seed = i * 12.5;
      final baseHeight =
          (size.height * 0.3) + ((sin(seed) * 0.5 + 0.5) * size.height * 0.5);

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
