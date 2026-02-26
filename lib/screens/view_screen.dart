import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:voiceapp/assets/constants.dart';
import 'package:voiceapp/services/voice_service.dart';

enum RecordingState { idle, recording, stopped }

class ViewScreen extends StatefulWidget {
  const ViewScreen({super.key});

  @override
  State<ViewScreen> createState() => _ViewScreenState();
}

class _ViewScreenState extends State<ViewScreen> {
  final _recorder = AudioRecorder();
  final _player = AudioPlayer();

  RecordingState _state = RecordingState.idle;
  Duration _elapsed = Duration.zero;
  Timer? _timer;
  String? _filePath;
  double _amplitude = 0.0;
  bool _isPlaying = false;
  bool _isUploading = false;

  List<Category> _categories = [];
  Category? _selectedCategory;
  bool _loadingCategories = false;

  static const _maxDuration = Duration(minutes: 3, seconds: 45);

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() => _loadingCategories = true);
    try {
      final cats = await VoiceApi().getCategories();
      if (mounted) setState(() => _categories = cats);
    } catch (_) {
      // silently fail — category is optional
    } finally {
      if (mounted) setState(() => _loadingCategories = false);
    }
  }

  // ── RECORDING ─────────────────────────────────────────────────────────────

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
    _filePath =
        '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: _filePath!,
    );

    _elapsed = Duration.zero;

    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) async {
      if (!mounted) return;

      final amp = await _recorder.getAmplitude();
      final normalized = ((amp.current + 60) / 60).clamp(0.0, 1.0);

      setState(() {
        _elapsed += const Duration(milliseconds: 100);
        _amplitude = normalized;
      });

      if (_elapsed >= _maxDuration) {
        await _stopRecording();
      }
    });

    setState(() => _state = RecordingState.recording);
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    _timer = null;
    await _recorder.stop();
    setState(() {
      _state = RecordingState.stopped;
      _amplitude = 0.0;
    });
  }

  // ── PLAYBACK ──────────────────────────────────────────────────────────────

  Future<void> _togglePlayback() async {
    if (_filePath == null) return;

    if (_isPlaying) {
      await _player.pause();
      setState(() => _isPlaying = false);
    } else {
      await _player.setFilePath(_filePath!);
      unawaited(_player.play());
      setState(() => _isPlaying = true);

      _player.playerStateStream.listen((s) {
        if (s.processingState == ProcessingState.completed && mounted) {
          setState(() => _isPlaying = false);
        }
      });
    }
  }

  // ── DISCARD ───────────────────────────────────────────────────────────────

  Future<void> _discard() async {
    await _player.stop();

    if (_filePath != null) {
      final file = File(_filePath!);
      if (await file.exists()) await file.delete();
      _filePath = null;
    }

    setState(() {
      _state = RecordingState.idle;
      _elapsed = Duration.zero;
      _isPlaying = false;
      _selectedCategory = null;
    });
  }

  // ── UPLOAD ────────────────────────────────────────────────────────────────

  Future<void> _post() async {
    if (_filePath == null) return;
    final file = File(_filePath!);
    if (!await file.exists()) return;

    if (_selectedCategory == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a category before posting')),
        );
      }
      return;
    }

    setState(() => _isUploading = true);
    try {
      await VoiceApi().uploadVoice(
        audio: file,
        duration: _elapsed.inSeconds,
        category: _selectedCategory!.name,
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Posted!')),
        );
      }
    } catch (e) {
      debugPrint(e.toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  // ── HELPERS ───────────────────────────────────────────────────────────────

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        bottom: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // Header
            Padding(
              padding: const EdgeInsets.only(left: 0.0, right: 28.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, size: 34),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text('New Wave', style: Constants.headingStyle),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.question_mark,
                      size: 18,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Timer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    ' ${_formatDuration(_elapsed)} ',
                    style: const TextStyle(color: Colors.white, fontSize: 36),
                  ),
                  Text(
                    '/',
                    style: TextStyle(
                      color: Constants.secondaryColor,
                      fontSize: 36,
                    ),
                  ),
                  Text(
                    ' ${_formatDuration(_maxDuration)} ',
                    style: TextStyle(
                      color: Constants.secondaryColor,
                      fontSize: 36,
                    ),
                  ),
                ],
              ),
            ),

            // Waveform
            SizedBox(
              width: double.infinity,
              height: 200,
              child: _state == RecordingState.idle
                  ? const Center(
                      child: Icon(Icons.mic_none, size: 80, color: Colors.white24),
                    )
                  : CustomPaint(
                      painter: _WaveformPainter(
                        amplitude: _amplitude,
                        isRecording: _state == RecordingState.recording,
                      ),
                    ),
            ),

            const SizedBox(height: 20),

            // Status indicator
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 10,
                  width: 10,
                  decoration: BoxDecoration(
                    color: _state == RecordingState.recording
                        ? Constants.primaryColor
                        : Colors.white30,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  switch (_state) {
                    RecordingState.idle => 'Tap to start',
                    RecordingState.recording => 'Recording',
                    RecordingState.stopped => 'Recorded',
                  },
                  style: TextStyle(
                    color: _state == RecordingState.recording
                        ? Constants.primaryColor
                        : Colors.white54,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Bottom panel
            _BottomPanel(
              state: _state,
              elapsed: _elapsed,
              isPlaying: _isPlaying,
              isUploading: _isUploading,
              categories: _categories,
              loadingCategories: _loadingCategories,
              selectedCategory: _selectedCategory,
              onCategoryChanged: (cat) => setState(() => _selectedCategory = cat),
              onStart: _startRecording,
              onStop: _stopRecording,
              onTogglePlay: _togglePlayback,
              onDiscard: _discard,
              onPost: _post,
            ),
          ],
        ),
      ),
    );
  }
}

// ── WAVEFORM PAINTER ──────────────────────────────────────────────────────────

class _WaveformPainter extends CustomPainter {
  final double amplitude;
  final bool isRecording;

  const _WaveformPainter({required this.amplitude, required this.isRecording});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Constants.primaryColor
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    const barCount = 40;
    final barSpacing = size.width / (barCount * 2);
    final centerY = size.height / 2;
    final maxBarHeight = size.height * 0.45;

    for (int i = 0; i < barCount; i++) {
      final x = i * barSpacing * 2 + barSpacing;
      final sineOffset = (i / barCount) * math.pi * 4;
      final sineMultiplier = (math.sin(sineOffset).abs() * 0.6) + 0.4;

      final barHeight = isRecording
          ? (0.08 + amplitude * 0.92) * maxBarHeight * sineMultiplier
          : maxBarHeight * 0.08;

      canvas.drawLine(
        Offset(x, centerY - barHeight),
        Offset(x, centerY + barHeight),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter old) =>
      old.amplitude != amplitude || old.isRecording != isRecording;
}

// ── BOTTOM PANEL ──────────────────────────────────────────────────────────────

class _BottomPanel extends StatelessWidget {
  final RecordingState state;
  final Duration elapsed;
  final bool isPlaying;
  final bool isUploading;
  final List<Category> categories;
  final bool loadingCategories;
  final Category? selectedCategory;
  final ValueChanged<Category?> onCategoryChanged;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onTogglePlay;
  final VoidCallback onDiscard;
  final VoidCallback onPost;

  const _BottomPanel({
    required this.state,
    required this.elapsed,
    required this.isPlaying,
    required this.isUploading,
    required this.categories,
    required this.loadingCategories,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.onStart,
    required this.onStop,
    required this.onTogglePlay,
    required this.onDiscard,
    required this.onPost,
  });

  void _showCategoryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF191b0f),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'CATEGORY',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (loadingCategories)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(color: Constants.primaryColor),
                )
              else if (categories.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'No categories available',
                    style: TextStyle(color: Colors.white54),
                  ),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: categories.length,
                    itemBuilder: (_, i) {
                      final cat = categories[i];
                      final isSelected = selectedCategory?.id == cat.id;
                      return ListTile(
                        onTap: () {
                          onCategoryChanged(isSelected ? null : cat);
                          Navigator.pop(context);
                        },
                        title: Text(
                          cat.name,
                          style: TextStyle(
                            color: isSelected ? Constants.primaryColor : Colors.white,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle, color: Constants.primaryColor, size: 20)
                            : null,
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFF191b0f),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom > 0
                ? MediaQuery.of(context).viewInsets.bottom
                : MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // Playback bar + category picker — only visible after recording stops
              if (state == RecordingState.stopped) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: onTogglePlay,
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: const Color(0xFF24271b),
                          child: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            color: const Color(0xFFF6FDF7),
                            size: 24,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 4,
                              thumbShape: SliderComponentShape.noThumb,
                              activeTrackColor: Constants.primaryColor,
                              inactiveTrackColor: const Color(0xFFEDEDED),
                              overlayShape: SliderComponentShape.noOverlay,
                            ),
                            child: Slider(
                              min: 0,
                              max: 100,
                              value: 30,
                              onChanged: (_) {},
                            ),
                          ),
                        ),
                      ),
                      Text(
                        '${elapsed.inMinutes}:${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Category picker
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CATEGORY',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () => _showCategoryPicker(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF24271b),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  selectedCategory?.name ?? 'Pick a category...',
                                  style: TextStyle(
                                    color: selectedCategory != null
                                        ? Colors.white
                                        : Colors.white38,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              if (loadingCategories)
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.5,
                                    color: Constants.primaryColor,
                                  ),
                                )
                              else
                                const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Constants.primaryColor,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 28),

              // Main action row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Left: Discard (stopped) or empty space
                  SizedBox(
                    width: 96,
                    child: state == RecordingState.stopped
                        ? Column(
                            children: [
                              GestureDetector(
                                onTap: onDiscard,
                                child: Container(
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF191b0f),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.transparent,
                                    child: Icon(
                                      Icons.delete,
                                      color: Color(0xFFF6FDF7),
                                      size: 32,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Discard',
                                style: TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ],
                          )
                        : const SizedBox(),
                  ),

                  // Center: main action button
                  GestureDetector(
                    onTap: switch (state) {
                      RecordingState.idle => onStart,
                      RecordingState.recording => onStop,
                      RecordingState.stopped => null,
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF191b0f),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: state == RecordingState.recording
                                ? Colors.red.withValues(alpha: 0.5)
                                : state == RecordingState.stopped
                                    ? Colors.transparent
                                    : Constants.primaryColor.withValues(alpha: 0.6),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 45,
                        backgroundColor: switch (state) {
                          RecordingState.idle => Constants.primaryColor,
                          RecordingState.recording => Colors.red,
                          RecordingState.stopped => Colors.grey.shade700,
                        },
                        child: Icon(
                          switch (state) {
                            RecordingState.idle => Icons.mic,
                            RecordingState.recording => Icons.stop,
                            RecordingState.stopped => Icons.check,
                          },
                          color: Colors.black,
                          size: 40,
                        ),
                      ),
                    ),
                  ),

                  // Right: Post (stopped) or empty space
                  SizedBox(
                    width: 96,
                    child: state == RecordingState.stopped
                        ? Column(
                            children: [
                              GestureDetector(
                                onTap: isUploading ? null : onPost,
                                child: Container(
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF191b0f),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.transparent,
                                    child: isUploading
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Constants.primaryColor,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.send,
                                            color: Color(0xFFF6FDF7),
                                            size: 32,
                                          ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Post',
                                style: TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ],
                          )
                        : const SizedBox(),
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
