import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/screening_result.dart';
import '../services/storage_service.dart';
import '../services/tflite_service.dart';
import '../utils/constants.dart';
import '../utils/routes.dart';
import '../widgets/action_button.dart';

class MaternalHealthScreen extends StatefulWidget {
  final String patientId;
  final String patientName;

  const MaternalHealthScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<MaternalHealthScreen> createState() => _MaternalHealthScreenState();
}

class _MaternalHealthScreenState extends State<MaternalHealthScreen> {
  final TFLiteService _tfliteService = TFLiteService();
  bool _isProcessing = false;

  // Questionnaire answers
  final Map<String, bool> _answers = {
    'highBP': false,
    'bleeding': false,
    'swelling': false,
    'severeHeadache': false,
    'reducedMovement': false,
    'weakness': false,
    'fever': false,
    'convulsions': false,
  };

  final List<Map<String, dynamic>> _questions = [
    {
      'key': 'highBP',
      'question': 'High blood pressure / dizziness?',
      'icon': Icons.favorite,
      'severity': 'high',
    },
    {
      'key': 'bleeding',
      'question': 'Vaginal bleeding?',
      'icon': Icons.water_drop,
      'severity': 'critical',
    },
    {
      'key': 'swelling',
      'question': 'Swelling in hands/feet/face?',
      'icon': Icons.pan_tool,
      'severity': 'medium',
    },
    {
      'key': 'severeHeadache',
      'question': 'Severe headache or blurred vision?',
      'icon': Icons.psychology,
      'severity': 'high',
    },
    {
      'key': 'reducedMovement',
      'question': 'Reduced baby movement?',
      'icon': Icons.child_care,
      'severity': 'high',
    },
    {
      'key': 'weakness',
      'question': 'Extreme weakness or fatigue?',
      'icon': Icons.battery_0_bar,
      'severity': 'medium',
    },
    {
      'key': 'fever',
      'question': 'Fever or chills?',
      'icon': Icons.thermostat,
      'severity': 'medium',
    },
    {
      'key': 'convulsions',
      'question': 'Convulsions or fits?',
      'icon': Icons.emergency,
      'severity': 'critical',
    },
  ];

  Future<void> _analyzeRisk() async {
    setState(() => _isProcessing = true);

    try {
      await _tfliteService.init();
      final result = await _tfliteService.predictMaternalRisk(_answers);

      final storage = Provider.of<StorageService>(context, listen: false);

      final screening = ScreeningResult(
        id: const Uuid().v4(),
        patientId: widget.patientId,
        riskLevelIndex: ScreeningResult.riskLevelToIndex(result.riskLevel),
        confidence: result.confidence,
        recommendation: _getMaternalRecommendation(result.riskLevel),
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

  String _getMaternalRecommendation(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return 'Pregnancy appears normal. Continue regular checkups, balanced diet, and rest.';
      case RiskLevel.medium:
        return 'Some warning signs present. Schedule PHC visit within 24-48 hours for checkup.';
      case RiskLevel.high:
        return 'DANGER SIGNS DETECTED. Immediate medical attention required. Transport to hospital.';
    }
  }

  int get _selectedCount => _answers.values.where((v) => v).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Maternal Health'),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFFEC407A),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.pregnant_woman,
                  color: Colors.white,
                  size: 40,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pregnancy Danger Signs',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Check all symptoms the patient has',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Questions
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _questions.length,
              itemBuilder: (context, index) {
                final q = _questions[index];
                final isChecked = _answers[q['key']] ?? false;
                
                Color severityColor;
                switch (q['severity']) {
                  case 'critical':
                    severityColor = AppColors.riskHigh;
                    break;
                  case 'high':
                    severityColor = AppColors.riskMedium;
                    break;
                  default:
                    severityColor = AppColors.textMedium;
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _answers[q['key']] = !isChecked;
                        });
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isChecked
                              ? severityColor.withOpacity(0.1)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isChecked
                                ? severityColor
                                : Colors.grey.shade200,
                            width: isChecked ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isChecked
                                    ? severityColor
                                    : Colors.grey.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                q['icon'],
                                color: isChecked ? Colors.white : Colors.grey,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                q['question'],
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight:
                                      isChecked ? FontWeight.w600 : FontWeight.normal,
                                  color: isChecked
                                      ? severityColor
                                      : AppColors.textDark,
                                ),
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: isChecked ? severityColor : Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isChecked
                                      ? severityColor
                                      : Colors.grey.shade300,
                                  width: 2,
                                ),
                              ),
                              child: isChecked
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 18,
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom Action
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                if (_selectedCount > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      '$_selectedCount warning sign${_selectedCount > 1 ? 's' : ''} selected',
                      style: TextStyle(
                        color: AppColors.riskMedium,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ActionButton(
                  label: 'Assess Risk',
                  icon: Icons.analytics,
                  onPressed: _analyzeRisk,
                  isLoading: _isProcessing,
                  backgroundColor: const Color(0xFFEC407A),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
