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

class AnemiaScanScreen extends StatefulWidget {
  final String patientId;
  final String patientName;

  const AnemiaScanScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<AnemiaScanScreen> createState() => _AnemiaScanScreenState();
}

class _AnemiaScanScreenState extends State<AnemiaScanScreen> {
  final ImageService _imageService = ImageService();
  final TFLiteService _tfliteService = TFLiteService();
  
  String _scanType = 'palm'; // 'palm' or 'eye'
  String? _imagePath;
  bool _isProcessing = false;

  Future<void> _captureImage() async {
    final path = await _imageService.captureImage(
      category: ImageCategory.anemia,
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
      final result = await _tfliteService.predictAnemiaRisk(_imagePath!);

      final storage = Provider.of<StorageService>(context, listen: false);

      final screening = ScreeningResult(
        id: const Uuid().v4(),
        patientId: widget.patientId,
        riskLevelIndex: ScreeningResult.riskLevelToIndex(result.riskLevel),
        confidence: result.confidence,
        recommendation: _getAnemiaRecommendation(result.riskLevel),
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

  String _getAnemiaRecommendation(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return 'Pallor levels appear normal. Encourage iron-rich foods and regular health checkups.';
      case RiskLevel.medium:
        return 'Mild pallor detected. Recommend dietary supplements and PHC visit for blood test.';
      case RiskLevel.high:
        return 'Significant pallor detected indicating possible anemia. Urgent blood test and medical consultation required.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Anemia Check'),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Scan Type Toggle
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildToggle('Palm', 'palm', Icons.pan_tool),
                  ),
                  Expanded(
                    child: _buildToggle('Eye', 'eye', Icons.remove_red_eye),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6F00).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: const Color(0xFFFF6F00),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _scanType == 'palm'
                          ? 'Photograph the inner palm under natural light'
                          : 'Photograph the lower eyelid (pull down gently)',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Image Preview
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFFF6F00).withOpacity(0.2),
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
                            _scanType == 'palm' ? Icons.pan_tool : Icons.remove_red_eye,
                            size: 80,
                            color: const Color(0xFFFF6F00).withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _scanType == 'palm' ? 'Capture Palm Image' : 'Capture Eye Image',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
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
                backgroundColor: const Color(0xFFFF6F00),
              )
            else ...[
              ActionButton(
                label: 'Analyze for Anemia',
                icon: Icons.analytics,
                onPressed: _analyzeImage,
                isLoading: _isProcessing,
                backgroundColor: const Color(0xFFFF6F00),
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

  Widget _buildToggle(String label, String value, IconData icon) {
    final isSelected = _scanType == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _scanType = value;
          _imagePath = null;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF6F00) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
