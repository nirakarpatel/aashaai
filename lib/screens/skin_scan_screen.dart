import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/screening_result.dart';
import '../services/image_service.dart';
import '../services/storage_service.dart';
import '../services/tflite_service.dart';
import '../utils/constants.dart';
import '../utils/routes.dart';
import '../widgets/action_button.dart';

class SkinScanScreen extends StatefulWidget {
  final String patientId;
  final String patientName;

  const SkinScanScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<SkinScanScreen> createState() => _SkinScanScreenState();
}

class _SkinScanScreenState extends State<SkinScanScreen> {
  final ImageService _imageService = ImageService();
  final TFLiteService _tfliteService = TFLiteService();
  
  String? _imagePath;
  bool _isProcessing = false;

  Future<void> _captureImage() async {
    final path = await _imageService.captureImage(
      category: ImageCategory.skin,
    );
    
    if (path != null) {
      setState(() => _imagePath = path);
    }
  }

  Future<void> _analyzeImage() async {
    if (_imagePath == null) return;

    setState(() => _isProcessing = true);

    try {
      await _tfliteService.init();
      final result = await _tfliteService.predictSkinDisease(_imagePath!);

      final storage = Provider.of<StorageService>(context, listen: false);

      final screening = ScreeningResult(
        id: const Uuid().v4(),
        patientId: widget.patientId,
        riskLevelIndex: ScreeningResult.riskLevelToIndex(result.riskLevel),
        confidence: result.confidence,
        recommendation: _getSkinRecommendation(result),
        screenedAt: DateTime.now(),
      );

      await storage.saveScreening(screening);

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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  String _getSkinRecommendation(PredictionResult result) {
    switch (result.riskLevel) {
      case RiskLevel.low:
        return 'Skin appears healthy. Continue monitoring and maintain hygiene.';
      case RiskLevel.medium:
        return 'Possible skin condition detected: ${result.condition}. Visit PHC for proper diagnosis.';
      case RiskLevel.high:
        return 'Significant skin condition detected. Urgent referral to dermatology recommended.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Skin Scan'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Patient Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Text(
                    widget.patientName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Image Preview
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: _imagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.file(
                          File(_imagePath!),
                          fit: BoxFit.cover,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt_outlined,
                            size: 80,
                            color: AppColors.primary.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Capture affected skin area',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ensure good lighting\nKeep camera 10-15cm away',
                            style: TextStyle(
                              color: AppColors.textLight,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            if (_imagePath == null)
              ActionButton(
                label: 'Capture Image',
                icon: Icons.camera_alt,
                onPressed: _captureImage,
                backgroundColor: const Color(0xFF8E24AA),
              )
            else ...[
              ActionButton(
                label: 'Analyze Skin',
                icon: Icons.analytics,
                onPressed: _analyzeImage,
                isLoading: _isProcessing,
                backgroundColor: const Color(0xFF8E24AA),
              ),
              const SizedBox(height: 12),
              SecondaryButton(
                label: 'Retake Photo',
                icon: Icons.refresh,
                onPressed: () => setState(() => _imagePath = null),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
