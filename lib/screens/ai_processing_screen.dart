import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/screening_result.dart';
import '../services/storage_service.dart';
import '../services/tflite_service.dart';
import '../utils/constants.dart';
import '../utils/routes.dart';

class AIProcessingScreen extends StatefulWidget {
  final String patientId;
  final String audioPath;

  const AIProcessingScreen({
    super.key,
    required this.patientId,
    required this.audioPath,
  });

  @override
  State<AIProcessingScreen> createState() => _AIProcessingScreenState();
}

class _AIProcessingScreenState extends State<AIProcessingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final TFLiteService _tfliteService = TFLiteService();

  int _currentStep = 0;
  final List<String> _steps = [
    'Loading AI Model...',
    'Preprocessing Audio...',
    'Extracting Features...',
    'Running Analysis...',
    'Generating Results...',
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _runAnalysis();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _runAnalysis() async {
    // Simulate step-by-step processing
    for (int i = 0; i < _steps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        setState(() => _currentStep = i);
      }
    }

    // Run actual prediction (mock for demo)
    await _tfliteService.init();
    final result = await _tfliteService.predictTBRisk(widget.audioPath);

    // Save screening result
    final storage = Provider.of<StorageService>(context, listen: false);

    final screening = ScreeningResult(
      id: const Uuid().v4(),
      patientId: widget.patientId,
      riskLevelIndex: ScreeningResult.riskLevelToIndex(result.riskLevel),
      confidence: result.confidence,
      recommendation: result.riskLevel.recommendation,
      screenedAt: DateTime.now(),
      audioFilePath: widget.audioPath,
    );

    await storage.saveScreening(screening);

    // Navigate to result screen
    if (mounted) {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.result,
        arguments: {
          'patientId': widget.patientId,
          'screeningId': screening.id,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated brain/AI icon
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _controller.value * 2 * 3.14159,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.secondary,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.psychology,
                          color: Colors.white,
                          size: 60,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 48),

                const Text(
                  'AI Analysis in Progress',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  'Please wait while we analyze\nthe cough recording...',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textMedium,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 48),

                // Progress Steps
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    children: List.generate(_steps.length, (index) {
                      final isCompleted = index < _currentStep;
                      final isCurrent = index == _currentStep;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isCompleted
                                    ? AppColors.riskLow
                                    : isCurrent
                                        ? AppColors.primary
                                        : Colors.grey.shade200,
                              ),
                              child: isCompleted
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16,
                                    )
                                  : isCurrent
                                      ? const SizedBox(
                                          width: 14,
                                          height: 14,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                          ),
                                        )
                                      : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _steps[index],
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight:
                                      isCurrent ? FontWeight.w600 : FontWeight.normal,
                                  color: isCompleted || isCurrent
                                      ? AppColors.textDark
                                      : AppColors.textLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 32),

                // Offline Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.wifi_off,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Works Offline',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
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
