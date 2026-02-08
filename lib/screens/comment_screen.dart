import 'package:flutter/material.dart';
import 'dart:math';
import 'package:voiceapp/assets/constants.dart';

class CommentScreen extends StatefulWidget {
  final String postId;
  final String originalAuthor;
  final String originalTitle;
  final String audioUrl;
  final String duration;
  final int likes;
  final int commentCount;

  const CommentScreen({
    Key? key,
    required this.postId,
    required this.originalAuthor,
    required this.originalTitle,
    required this.audioUrl,
    required this.duration,
    required this.likes,
    required this.commentCount,
  }) : super(key: key);

  @override
  State<CommentScreen> createState() => _CommentScreenState();

  static const Color primaryColor = Color(0xFFD4E157);
  static const Color backgroundColor = Color(0xFF0A0A0A);
  static const Color cardColor = Color(0xFF1A1A1A);
}

class _CommentScreenState extends State<CommentScreen>
    with TickerProviderStateMixin {
  late AnimationController _waveformController;
  bool _isPlayingOriginal = false;
  bool _isPlayingComment = false;
  int? _playingCommentId;
  String _sortFilter = 'Recent';
  final TextEditingController _replyController = TextEditingController();

  final List<VoiceComment> comments = [
    VoiceComment(
      id: 1,
      username: '@jamie_vibe',
      displayName: 'Jamie Vibe',
      avatar: 'assets/avatar_1.jpg',
      timeAgo: '12m ago',
      audioUrl: 'assets/audio/comment1.mp3',
      duration: '0:15',
      likes: 24,
      replies: 0,
    ),
    VoiceComment(
      id: 2,
      username: '@marcus_digital',
      displayName: 'Marcus Digital',
      avatar: 'assets/avatar_2.jpg',
      timeAgo: '45m ago',
      audioUrl: 'assets/audio/comment2.mp3',
      duration: '0:08',
      likes: 12,
      replies: 2,
    ),
    VoiceComment(
      id: 3,
      username: '@sarah_sonic',
      displayName: 'Sarah Sonic',
      avatar: 'assets/avatar_3.jpg',
      timeAgo: '1h ago',
      audioUrl: 'assets/audio/comment3.mp3',
      duration: '0:22',
      likes: 45,
      replies: 5,
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
    _replyController.dispose();
    super.dispose();
  }

  void _togglePlaybackOriginal() {
    setState(() {
      _isPlayingOriginal = !_isPlayingOriginal;
      if (_isPlayingOriginal) {
        _waveformController.repeat();
      } else {
        _waveformController.stop();
      }
    });
  }

  void _togglePlaybackComment(int commentId) {
    setState(() {
      if (_playingCommentId == commentId) {
        _isPlayingComment = !_isPlayingComment;
        if (_isPlayingComment) {
          _waveformController.repeat();
        } else {
          _waveformController.stop();
        }
      } else {
        _playingCommentId = commentId;
        _isPlayingComment = true;
        _waveformController.repeat();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CommentScreen.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _Header(onBackPressed: () => Navigator.pop(context)),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      _OriginalPost(
                        author: widget.originalAuthor,
                        title: widget.originalTitle,
                        duration: widget.duration,
                        likes: widget.likes,
                        commentCount: widget.commentCount,
                        isPlaying: _isPlayingOriginal,
                        onPlayPressed: _togglePlaybackOriginal,
                        animationController: _waveformController,
                      ),
                      const SizedBox(height: 32),
                      _CommentsHeader(
                        commentCount: widget.commentCount,
                        sortFilter: _sortFilter,
                        onSortChanged: (value) {
                          setState(() {
                            _sortFilter = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      _CommentsList(
                        comments: comments,
                        playingCommentId: _playingCommentId,
                        isPlayingComment: _isPlayingComment,
                        onCommentPlayPressed: _togglePlaybackComment,
                        animationController: _waveformController,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
            _ReplyInput(controller: _replyController),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onBackPressed;

  const _Header({required this.onBackPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBackPressed,
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Voice Thread',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Reply to @lexi_vibes',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.more_vert, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _OriginalPost extends StatelessWidget {
  final String author;
  final String title;
  final String duration;
  final int likes;
  final int commentCount;
  final bool isPlaying;
  final VoidCallback onPlayPressed;
  final AnimationController animationController;

  const _OriginalPost({
    required this.author,
    required this.title,
    required this.duration,
    required this.likes,
    required this.commentCount,
    required this.isPlaying,
    required this.onPlayPressed,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CommentScreen.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Constants.primaryColor,
                child: Text(author[0], style: const TextStyle(color: Colors.black)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          author,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Constants.primaryColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'ORIGINAL',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '2 hours ago • New York',
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          _AudioPlayer(
            duration: duration,
            isPlaying: isPlaying,
            onPlayPressed: onPlayPressed,
            animationController: animationController,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _EngagementButton(
                icon: Icons.favorite,
                label: '$likes',
                onTap: () {},
              ),
              const SizedBox(width: 24),
              _EngagementButton(
                icon: Icons.chat_bubble_outline,
                label: '$commentCount',
                onTap: () {},
              ),
              const SizedBox(width: 24),
              _EngagementButton(
                icon: Icons.share,
                label: '',
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AudioPlayer extends StatelessWidget {
  final String duration;
  final bool isPlaying;
  final VoidCallback onPlayPressed;
  final AnimationController animationController;

  const _AudioPlayer({
    required this.duration,
    required this.isPlaying,
    required this.onPlayPressed,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onPlayPressed,
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFD4E157),
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
            child: CustomPaint(
              painter: _MiniWaveformPainter(
                isPlaying: isPlaying,
                animation: animationController,
              ),
              size: const Size(double.infinity, 40),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            duration,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD4E157),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniWaveformPainter extends CustomPainter {
  final bool isPlaying;
  final Animation<double> animation;

  _MiniWaveformPainter({
    required this.isPlaying,
    required this.animation,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4E157)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final barWidth = 2.5;
    final spacing = 1.5;
    final totalBars = ((size.width / (barWidth + spacing)).toInt());
    final centerY = size.height / 2;

    for (int i = 0; i < totalBars; i++) {
      final x = i * (barWidth + spacing);
      final seed = i * 12.5;
      final baseHeight = (size.height * 0.3) + 
          ((sin(seed) * 0.5 + 0.5) * size.height * 0.3);

      final animatedHeight = isPlaying
          ? baseHeight * (0.5 + 0.5 * sin(seed + animation.value).abs())
          : baseHeight * 0.2;

      canvas.drawLine(
        Offset(x, centerY - animatedHeight / 2),
        Offset(x, centerY + animatedHeight / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_MiniWaveformPainter oldDelegate) => true;
}

class _EngagementButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _EngagementButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

class _CommentsHeader extends StatelessWidget {
  final int commentCount;
  final String sortFilter;
  final ValueChanged<String> onSortChanged;

  const _CommentsHeader({
    required this.commentCount,
    required this.sortFilter,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'VOICE COMMENTS',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white.withOpacity(0.7),
            letterSpacing: 0.5,
          ),
        ),
        PopupMenuButton<String>(
          onSelected: onSortChanged,
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'Recent', child: Text('Recent')),
            const PopupMenuItem(value: 'Popular', child: Text('Popular')),
          ],
          child: Row(
            children: [
              Text(
                sortFilter,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD4E157),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.arrow_drop_down,
                color: Color(0xFFD4E157),
                size: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CommentsList extends StatelessWidget {
  final List<VoiceComment> comments;
  final int? playingCommentId;
  final bool isPlayingComment;
  final Function(int) onCommentPlayPressed;
  final AnimationController animationController;

  const _CommentsList({
    required this.comments,
    required this.playingCommentId,
    required this.isPlayingComment,
    required this.onCommentPlayPressed,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        comments.length,
        (index) => _CommentCard(
          comment: comments[index],
          isPlaying: playingCommentId == comments[index].id && isPlayingComment,
          onPlayPressed: () => onCommentPlayPressed(comments[index].id),
          animationController: animationController,
        ),
      ),
    );
  }
}

class _CommentCard extends StatelessWidget {
  final VoiceComment comment;
  final bool isPlaying;
  final VoidCallback onPlayPressed;
  final AnimationController animationController;

  const _CommentCard({
    required this.comment,
    required this.isPlaying,
    required this.onPlayPressed,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to comment detail if needed
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Constants.primaryColor,
                  child: Text(
                    comment.displayName[0],
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.username,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        comment.timeAgo,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 52),
              child: _AudioPlayer(
                duration: comment.duration,
                isPlaying: isPlaying,
                onPlayPressed: onPlayPressed,
                animationController: animationController,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 52),
              child: Row(
                children: [
                  _EngagementButton(
                    icon: Icons.favorite,
                    label: '${comment.likes}',
                    onTap: () {},
                  ),
                  const SizedBox(width: 24),
                  GestureDetector(
                    onTap: () {},
                    child: Row(
                      children: [
                        const Icon(Icons.reply, color: Color(0xFFD4E157), size: 16),
                        const SizedBox(width: 6),
                        const Text(
                          'REPLY',
                          style: TextStyle(
                            color: Color(0xFFD4E157),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(height: 1, color: Colors.white.withOpacity(0.1)),
          ],
        ),
      ),
    );
  }
}

class _ReplyInput extends StatelessWidget {
  final TextEditingController controller;

  const _ReplyInput({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CommentScreen.cardColor,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Constants.primaryColor,
            child: const Text('U', style: TextStyle(color: Colors.black)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Type or record a reply...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                filled: true,
                fillColor: Colors.black.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFD4E157),
              ),
              child: const Icon(Icons.mic, color: Colors.black, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class VoiceComment {
  final int id;
  final String username;
  final String displayName;
  final String avatar;
  final String timeAgo;
  final String audioUrl;
  final String duration;
  final int likes;
  final int replies;

  VoiceComment({
    required this.id,
    required this.username,
    required this.displayName,
    required this.avatar,
    required this.timeAgo,
    required this.audioUrl,
    required this.duration,
    required this.likes,
    required this.replies,
  });
}
