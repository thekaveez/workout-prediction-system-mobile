import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:workout_prediction_system_mobile/features/exercise/models/exercise_model.dart';
import 'package:workout_prediction_system_mobile/features/exercise/screens/workout_complete_screen.dart';
import 'package:workout_prediction_system_mobile/utils/text_utils.dart';

class VideoPlayerScreen extends ConsumerStatefulWidget {
  final ExerciseData exercise;
  final VoidCallback onVideoComplete;

  const VideoPlayerScreen({
    super.key,
    required this.exercise,
    required this.onVideoComplete,
  });

  @override
  ConsumerState<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen> {
  late YoutubePlayerController _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _isBuffering = true;
  String? _youtubeId;

  // Timer properties
  Timer? _workoutTimer;
  int _workoutDurationInSeconds = 0;
  int _remainingSeconds = 0;
  bool _workoutStarted = false;
  bool _showStartWorkoutDialog = false;

  @override
  void initState() {
    super.initState();
    _youtubeId = _extractYoutubeId(widget.exercise.videoUrl);
    _initializeYoutubePlayer();

    // Parse the workout duration
    _workoutDurationInSeconds = _parseDurationToSeconds(
      widget.exercise.duration,
    );
    _remainingSeconds = _workoutDurationInSeconds;

    // Show the workout start dialog after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _showStartWorkoutDialog = true;
        });
      }
    });
  }

  void _initializeYoutubePlayer() {
    if (_youtubeId != null) {
      _controller = YoutubePlayerController(
        initialVideoId: _youtubeId!,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          disableDragSeek: false,
          loop: false,
          isLive: false,
          forceHD: false,
          enableCaption: true,
        ),
      );

      _controller.addListener(_videoListener);

      setState(() {
        _isInitialized = true;
        _isBuffering = false;
      });
    }
  }

  void _videoListener() {
    if (!mounted) return;

    setState(() {
      _isPlaying = _controller.value.isPlaying;

      if (_controller.value.playerState == PlayerState.ended) {
        // Don't trigger onVideoComplete here as we want to wait for timer
        // widget.onVideoComplete();

        // Instead play video again if workout is still in progress
        if (_workoutStarted && _remainingSeconds > 0) {
          _controller.seekTo(Duration.zero);
          _controller.play();
        }
      }
    });
  }

  // Start the workout timer
  void _startWorkout() {
    setState(() {
      _workoutStarted = true;
      _showStartWorkoutDialog = false;
    });

    // Play the video if it's not already playing
    if (!_controller.value.isPlaying) {
      _controller.play();
    }

    // Start the countdown timer
    _workoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _completeWorkout();
      }
    });
  }

  // Handle workout completion
  void _completeWorkout() {
    _workoutTimer?.cancel();

    // Navigate to the workout complete screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutCompleteScreen(exercise: widget.exercise),
      ),
    );
  }

  // Parse duration string (e.g., "15 min" or "00:30") to seconds
  int _parseDurationToSeconds(String durationStr) {
    if (durationStr.contains('min')) {
      // Format like "15 min"
      final minutes = int.tryParse(durationStr.split(' ').first) ?? 0;
      return minutes * 60;
    } else if (durationStr.contains(':')) {
      // Format like "mm:ss"
      final parts = durationStr.split(':');
      if (parts.length == 2) {
        final minutes = int.tryParse(parts[0]) ?? 0;
        final seconds = int.tryParse(parts[1]) ?? 0;
        return (minutes * 60) + seconds;
      }
    }

    // Default to 60 seconds if parsing fails
    return 60;
  }

  void _togglePlayPause() {
    if (_isInitialized) {
      setState(() {
        if (_controller.value.isPlaying) {
          _controller.pause();
        } else {
          _controller.play();
        }
        _isPlaying = _controller.value.isPlaying;
      });
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _workoutTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  String? _extractYoutubeId(String url) {
    return YoutubePlayer.convertUrlToId(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.5),
        elevation: 0,
        title: Text(
          widget.exercise.title,
          style: TextUtils.kSubHeading(
            context,
          ).copyWith(color: Colors.white, fontSize: 18.sp),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.ondemand_video, color: Colors.red),
            onPressed: () => _openYoutubeVideo(),
            tooltip: 'Open in YouTube',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Video content
          Center(
            child:
                _isInitialized
                    ? YoutubePlayer(
                      controller: _controller,
                      showVideoProgressIndicator: true,
                      progressIndicatorColor:
                          Theme.of(context).colorScheme.secondary,
                      progressColors: ProgressBarColors(
                        playedColor: Theme.of(context).colorScheme.secondary,
                        handleColor: Theme.of(context).colorScheme.secondary,
                      ),
                      onReady: () {
                        setState(() {
                          _isBuffering = false;
                        });
                      },
                    )
                    : AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Container(
                        color: Colors.black,
                        child:
                            _isBuffering
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    if (_youtubeId != null)
                                      Image.network(
                                        'https://img.youtube.com/vi/$_youtubeId/0.jpg',
                                        fit: BoxFit.cover,
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return Center(
                                            child: Icon(
                                              Icons.fitness_center,
                                              size: 100.sp,
                                              color: Colors.grey[700],
                                            ),
                                          );
                                        },
                                      )
                                    else
                                      Center(
                                        child: Icon(
                                          Icons.fitness_center,
                                          size: 100.sp,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    if (!_isPlaying)
                                      Center(
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.play_circle_filled,
                                            color: Colors.white,
                                            size: 80.sp,
                                          ),
                                          onPressed: _togglePlayPause,
                                        ),
                                      ),
                                  ],
                                ),
                      ),
                    ),
          ),

          // Exercise info overlay at the top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: _getDifficultyColor(
                            widget.exercise.difficulty,
                          ),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Text(
                          widget.exercise.difficulty,
                          style: TextUtils.kBodyText(context).copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Text(
                          widget.exercise.duration,
                          style: TextUtils.kBodyText(context).copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Text(
                          '${widget.exercise.calories} kcal',
                          style: TextUtils.kBodyText(context).copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Timer overlay at the bottom if workout started
          if (_workoutStarted)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Time Remaining',
                      style: TextUtils.kBodyText(
                        context,
                      ).copyWith(color: Colors.white, fontSize: 14.sp),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      _formatTime(_remainingSeconds),
                      style: TextUtils.kHeading(
                        context,
                      ).copyWith(color: Colors.white, fontSize: 32.sp),
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: _completeWorkout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 32.w,
                          vertical: 12.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'End Workout',
                        style: TextUtils.kSubHeading(
                          context,
                        ).copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Start workout dialog
          if (_showStartWorkoutDialog)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 32.w),
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.fitness_center,
                        size: 64.sp,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Ready to Start?',
                        style: TextUtils.kHeading(
                          context,
                        ).copyWith(fontSize: 24.sp),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'This workout will last ${widget.exercise.duration}',
                        style: TextUtils.kBodyText(
                          context,
                        ).copyWith(fontSize: 16.sp),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24.h),
                      ElevatedButton(
                        onPressed: _startWorkout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          foregroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 50.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          'Start Workout',
                          style: TextUtils.kSubHeading(
                            context,
                          ).copyWith(color: Colors.white),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _showStartWorkoutDialog = false;
                          });
                        },
                        child: Text(
                          'Cancel',
                          style: TextUtils.kBodyText(
                            context,
                          ).copyWith(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _openYoutubeVideo() async {
    if (_youtubeId != null) {
      final youtubeUrl = 'https://www.youtube.com/watch?v=$_youtubeId';
      if (!await launchUrl(
        Uri.parse(youtubeUrl),
        mode: LaunchMode.externalApplication,
      )) {
        throw Exception('Could not launch $youtubeUrl');
      }
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Beginner':
        return Colors.green;
      case 'Intermediate':
        return Colors.orange;
      case 'Advanced':
        return Colors.red;
      default:
        return Theme.of(context).colorScheme.secondary;
    }
  }
}
