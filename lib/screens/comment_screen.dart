import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:provider/provider.dart';
import 'package:voiceapp/assets/constants.dart';
import 'package:voiceapp/providers/comment_provider.dart';
import 'package:voiceapp/models/voice_comment.dart';

enum RecordingState { idle, recording, stopped }

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
  String? _playingCommentId;
  String _sortFilter = 'recent';
  final TextEditingController _replyController = TextEditingController();
  
  // Recording variables
  final _recorder = AudioRecorder();
  final _player = AudioPlayer();
  RecordingState _recordingState = RecordingState.idle;
  Duration _recordedDuration = Duration.zero;
  Timer? _timer;
  String? _recordedFilePath;
  double _amplitude = 0.0;
  bool _isUploading = false;
  
  static const _maxDuration = Duration(minutes: 3, seconds: 45);

  @override
  void initState() {
    super.initState();
    _waveformController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // Load comments from API
    Future.microtask(() {
      context.read<CommentProvider>().loadComments(widget.postId, sortBy: _sortFilter);
    });
  }

  @override
  void dispose() {
    _waveformController.dispose();
    _replyController.dispose();
    _timer?.cancel();
    _recorder.dispose();
    _player.dispose();
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

  Future<void> _togglePlaybackComment(String commentId, String audioUrl) async {
    try {
      
      if (_playingCommentId == commentId) {
        // Toggle play/pause
        if (_isPlayingComment) {
          await _player.pause();
          _waveformController.stop();
        } else {
          await _player.play();
          _waveformController.repeat();
        }
        setState(() {
          _isPlayingComment = !_isPlayingComment;
        });
      } else {
        // Stop previous and play new
        if (_playingCommentId != null) {
          await _player.stop();
          _waveformController.stop();
        }
        
        print('Setting audio source from URL: $audioUrl');
        await _player.setUrl(audioUrl);
        await _player.play();
        _waveformController.repeat();
        
        setState(() {
          _playingCommentId = commentId;
          _isPlayingComment = true;
        });
        
        // Listen for playback completion
        _player.playerStateStream.listen((state) {
          if (state.processingState == ProcessingState.completed) {
            if (mounted) {
              setState(() {
                _isPlayingComment = false;
                _playingCommentId = null;
              });
              _waveformController.stop();
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error playing audio: $e')),
        );
      }
    }
  }

  // Recording methods
  Future<void> _startRecording() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission denied')),
        );
      }
      return;
    }

    final dir = await getTemporaryDirectory();
    _recordedFilePath = '${dir.path}/comment_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: _recordedFilePath!,
    );

    _recordedDuration = Duration.zero;
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) async {
      if (!mounted) return;

      final amp = await _recorder.getAmplitude();
      final normalized = ((amp.current + 60) / 60).clamp(0.0, 1.0);

      setState(() {
        _recordedDuration += const Duration(milliseconds: 100);
        _amplitude = normalized;
      });

      if (_recordedDuration >= _maxDuration) {
        await _stopRecording();
      }
    });

    setState(() => _recordingState = RecordingState.recording);
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    _timer = null;
    await _recorder.stop();
    setState(() {
      _recordingState = RecordingState.stopped;
      _amplitude = 0.0;
    });
  }

  Future<void> _discardRecording() async {
    await _player.stop();

    if (_recordedFilePath != null) {
      final file = File(_recordedFilePath!);
      if (await file.exists()) await file.delete();
      _recordedFilePath = null;
    }

    setState(() {
      _recordingState = RecordingState.idle;
      _recordedDuration = Duration.zero;
      _replyController.clear();
    });
  }

  Future<void> _postComment() async {
    if (_recordedFilePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please record a comment first')),
      );
      return;
    }

    final file = File(_recordedFilePath!);
    if (!await file.exists()) {
      return;
    }

    setState(() => _isUploading = true);
    try {
      final success = await context.read<CommentProvider>().postComment(
            widget.postId,
            audioFile: file,
            duration: _recordedDuration.inSeconds,
          );

      if (success) {
        await _discardRecording();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Comment posted!')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to post comment')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CommentScreen.backgroundColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(onBackPressed: () => Navigator.pop(context)),
            Expanded(
              child: SingleChildScrollView(
                reverse: true,
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
                      Consumer<CommentProvider>(
                        builder: (context, commentProvider, _) {
                          if (commentProvider.isLoading) {
                            return const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4E157)),
                              ),
                            );
                          }
                          
                          if (commentProvider.error != null) {
                            return Center(
                              child: Column(
                                children: [
                                  Text(
                                    'Error: ${commentProvider.error}',
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () {
                                      commentProvider.loadComments(widget.postId, sortBy: _sortFilter);
                                    },
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            );
                          }
                          
                          return _CommentsList(
                            comments: commentProvider.comments,
                            playingCommentId: _playingCommentId,
                            isPlayingComment: _isPlayingComment,
                            onCommentPlayPressed: (commentId, audioUrl) {
                              _togglePlaybackComment(commentId, audioUrl);
                            },
                            animationController: _waveformController,
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom > 0
                    ? 0
                    : MediaQuery.of(context).padding.bottom,
              ),
              child: _ReplyInput(
                controller: _replyController,
                recordingState: _recordingState,
                recordedDuration: _recordedDuration,
                onStartRecording: _startRecording,
                onStopRecording: _stopRecording,
                onPostComment: _postComment,
                onDiscardRecording: _discardRecording,
                isUploading: _isUploading,
                amplitude: _amplitude,
              ),
            ),
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
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
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
  
  void _handlePlayPress() {
    onPlayPressed();
  }

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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _handlePlayPress,
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
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  duration,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
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
  final String? playingCommentId;
  final bool isPlayingComment;
  final Function(String, String)? onCommentPlayPressed;
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
        (index) =>                 _CommentCard(
                  comment: comments[index],
                  isPlaying: playingCommentId == comments[index].id && isPlayingComment,
                  onPlayPressed: onCommentPlayPressed ?? (String commentId, String audioUrl) {},
                  animationController: animationController,
                ),
      ),
    );
  }
}

class _CommentCard extends StatelessWidget {
  final VoiceComment comment;
  final bool isPlaying;
  final Function(String, String) onPlayPressed;
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
                onPlayPressed: () => onPlayPressed(comment.id, comment.audioUrl),
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
  final RecordingState recordingState;
  final Duration recordedDuration;
  final VoidCallback onStartRecording;
  final VoidCallback onStopRecording;
  final VoidCallback onPostComment;
  final VoidCallback onDiscardRecording;
  final bool isUploading;
  final double amplitude;
  
  const _ReplyInput({
    required this.controller,
    required this.recordingState,
    required this.recordedDuration,
    required this.onStartRecording,
    required this.onStopRecording,
    required this.onPostComment,
    required this.onDiscardRecording,
    required this.isUploading,
    required this.amplitude,
  });
  
  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
  
  @override
  Widget build(BuildContext context) {
    final isRecording = recordingState == RecordingState.recording;
    final isStopped = recordingState == RecordingState.stopped;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CommentScreen.cardColor,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: Column(
        children: [
          // Show recording indicator if recording
          if (isRecording) ...[
            Row(
              children: [
                const SizedBox(width: 8),
                Icon(
                  Icons.radio_button_checked,
                  color: Colors.red,
                  size: 12,
                ),
                const SizedBox(width: 8),
                Text(
                  'Recording... ${_formatDuration(recordedDuration)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const Spacer(),
                Text(
                  'Amplitude: ${(amplitude * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(color: Colors.white54, fontSize: 10),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          // Show recorded duration if stopped
          if (isStopped) ...[
            Row(
              children: [
                const SizedBox(width: 8),
                const Icon(Icons.check_circle, color: Colors.green, size: 14),
                const SizedBox(width: 8),
                Text(
                  'Recorded: ${_formatDuration(recordedDuration)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Constants.primaryColor,
                child: const Text('U', style: TextStyle(color: Colors.black)),
              ),
              const SizedBox(width: 12),
              if (recordingState == RecordingState.idle)
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
                )
              else
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      isStopped ? 'Comment ready to post' : 'Recording...',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              // Microphone button - Start/Stop recording
              if (recordingState == RecordingState.idle)
                GestureDetector(
                  onTap: isUploading ? null : onStartRecording,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFD4E157),
                    ),
                    child: Icon(
                      Icons.mic,
                      color: Colors.black,
                      size: isUploading ? 16 : 20,
                    ),
                  ),
                )
              else if (isRecording)
                GestureDetector(
                  onTap: onStopRecording,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFD4E157),
                    ),
                    child: const Icon(
                      Icons.stop,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                )
              else if (isStopped)
                Row(
                  children: [
                    // Cancel button
                    GestureDetector(
                      onTap: isUploading ? null : onDiscardRecording,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red.withOpacity(0.3),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Post button
                    GestureDetector(
                      onTap: isUploading ? null : onPostComment,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFD4E157),
                        ),
                        child: isUploading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                ),
                              )
                            : const Icon(
                                Icons.send,
                                color: Colors.black,
                                size: 20,
                              ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
