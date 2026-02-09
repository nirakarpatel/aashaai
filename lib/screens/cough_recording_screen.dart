import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import '../utils/constants.dart';
import '../utils/routes.dart';
import '../widgets/action_button.dart';

class CoughRecordingScreen extends StatefulWidget {
  final String patientId;
  final String patientName;

  const CoughRecordingScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<CoughRecordingScreen> createState() => _CoughRecordingScreenState();
}

class _CoughRecordingScreenState extends State<CoughRecordingScreen>
    with SingleTickerProviderStateMixin {
  final AudioService _audioService = AudioService();

  bool _isRecording = false;
  bool _hasRecording = false;
  String? _recordingPath;
  int _recordingSeconds = 0;
  Timer? _timer;
  Timer? _amplitudeTimer;
  List<double> _amplitudes = [];
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _amplitudeTimer?.cancel();
    _pulseController.dispose();
    _audioService.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    final started = await _audioService.startRecording();
    if (!started) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not access microphone. Please grant permission.'),
          ),
        );
      }
      return;
    }

    setState(() {
      _isRecording = true;
      _recordingSeconds = 0;
      _amplitudes = [];
    });

    _pulseController.repeat(reverse: true);

    // Timer for duration
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordingSeconds++;
      });

      // Auto-stop after max duration
      if (_recordingSeconds >= AppConstants.maxRecordDurationSeconds) {
        _stopRecording();
      }
    });

    // Timer for amplitude visualization
    _amplitudeTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) async {
      if (_isRecording) {
        final amplitude = await _audioService.getAmplitude();
        setState(() {
          _amplitudes.add(amplitude);
          if (_amplitudes.length > 50) {
            _amplitudes.removeAt(0);
          }
        });
      }
    });
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    _amplitudeTimer?.cancel();
    _pulseController.stop();

    final path = await _audioService.stopRecording();

    setState(() {
      _isRecording = false;
      _hasRecording = path != null;
      _recordingPath = path;
    });
  }

  void _retryRecording() {
    setState(() {
      _hasRecording = false;
      _recordingPath = null;
      _recordingSeconds = 0;
      _amplitudes = [];
    });
  }

  void _proceedToAnalysis() {
    if (_recordingPath == null) return;

    Navigator.pushNamed(
      context,
      AppRoutes.aiProcessing,
      arguments: {
        'patientId': widget.patientId,
        'audioPath': _recordingPath,
      },
    );
  }

  String get _formattedTime {
    final minutes = _recordingSeconds ~/ 60;
    final seconds = _recordingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('TB Cough Screening'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Patient Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          widget.patientName[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.patientName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Text(
                            'Recording cough sample',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Instructions
              if (!_isRecording && !_hasRecording)
                Column(
                  children: [
                    Icon(
                      Icons.mic_none,
                      size: 80,
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Record Cough Sample',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Ask the patient to cough 3-4 times\ninto the phone microphone',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textMedium,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),

              // Recording visualization
              if (_isRecording)
                Column(
                  children: [
                    // Animated recording indicator
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          width: 150 + (_pulseController.value * 30),
                          height: 150 + (_pulseController.value * 30),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.riskHigh.withOpacity(0.1 + (_pulseController.value * 0.1)),
                          ),
                          child: Center(
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.riskHigh,
                              ),
                              child: const Icon(
                                Icons.mic,
                                color: Colors.white,
                                size: 50,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),

                    // Timer
                    Text(
                      _formattedTime,
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: AppColors.riskHigh,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Recording...',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textMedium,
                      ),
                    ),

                    // Waveform visualization
                    const SizedBox(height: 32),
                    SizedBox(
                      height: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          min(_amplitudes.length, 30),
                          (index) {
                            final amplitude = _amplitudes[_amplitudes.length - 1 - index];
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              width: 4,
                              height: 10 + (amplitude * 50),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.5 + (amplitude * 0.5)),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),

              // Recording complete
              if (_hasRecording && !_isRecording)
                Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.riskLow.withOpacity(0.1),
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: AppColors.riskLow,
                        size: 60,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Recording Complete',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Duration: $_formattedTime',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textMedium,
                      ),
                    ),
                  ],
                ),

              const Spacer(),

              // Action Buttons
              if (!_isRecording && !_hasRecording)
                ActionButton(
                  label: 'Start Recording',
                  icon: Icons.mic,
                  onPressed: _startRecording,
                  backgroundColor: AppColors.riskHigh,
                ),

              if (_isRecording)
                ActionButton(
                  label: 'Stop Recording',
                  icon: Icons.stop,
                  onPressed: _stopRecording,
                  backgroundColor: AppColors.textDark,
                ),

              if (_hasRecording && !_isRecording) ...[
                ActionButton(
                  label: 'Analyze Cough',
                  icon: Icons.analytics,
                  onPressed: _proceedToAnalysis,
                ),
                const SizedBox(height: 12),
                SecondaryButton(
                  label: 'Record Again',
                  icon: Icons.refresh,
                  onPressed: _retryRecording,
                ),
              ],

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
