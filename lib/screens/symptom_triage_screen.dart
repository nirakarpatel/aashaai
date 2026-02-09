import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/screening_result.dart';
import '../services/storage_service.dart';
import '../services/tflite_service.dart';
import '../utils/constants.dart';
import '../utils/routes.dart';
import '../widgets/action_button.dart';

class SymptomTriageScreen extends StatefulWidget {
  final String patientId;
  final String patientName;

  const SymptomTriageScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<SymptomTriageScreen> createState() => _SymptomTriageScreenState();
}

class _SymptomTriageScreenState extends State<SymptomTriageScreen> {
  final TFLiteService _tfliteService = TFLiteService();
  bool _isProcessing = false;
  
  final List<String> _selectedSymptoms = [];
  
  final List<Map<String, dynamic>> _symptomGroups = [
    {
      'category': 'Respiratory',
      'color': const Color(0xFF2196F3),
      'icon': Icons.air,
      'symptoms': [
        'Difficulty breathing',
        'Persistent cough',
        'Chest pain',
        'Wheezing',
      ],
    },
    {
      'category': 'General',
      'color': const Color(0xFFFF9800),
      'icon': Icons.thermostat,
      'symptoms': [
        'High fever (>102°F)',
        'Severe headache',
        'Body aches',
        'Extreme fatigue',
      ],
    },
    {
      'category': 'Digestive',
      'color': const Color(0xFF4CAF50),
      'icon': Icons.water_drop,
      'symptoms': [
        'Severe diarrhea',
        'Vomiting',
        'Abdominal pain',
        'Blood in stool',
      ],
    },
    {
      'category': 'Child Health',
      'color': const Color(0xFFE91E63),
      'icon': Icons.child_care,
      'symptoms': [
        'Not eating/drinking',
        'Lethargy in child',
        'Rash with fever',
        'Convulsions',
      ],
    },
    {
      'category': 'Other',
      'color': const Color(0xFF9C27B0),
      'icon': Icons.more_horiz,
      'symptoms': [
        'Severe dehydration',
        'Unconsciousness',
        'Injury/Trauma',
        'Allergic reaction',
      ],
    },
  ];

  Future<void> _analyzeSymptoms() async {
    if (_selectedSymptoms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one symptom')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      await _tfliteService.init();
      final result = await _tfliteService.predictSymptomTriage(_selectedSymptoms);

      final storage = Provider.of<StorageService>(context, listen: false);

      final screening = ScreeningResult(
        id: const Uuid().v4(),
        patientId: widget.patientId,
        riskLevelIndex: ScreeningResult.riskLevelToIndex(result.riskLevel),
        confidence: result.confidence,
        recommendation: _getTriageRecommendation(result.riskLevel),
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

  String _getTriageRecommendation(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return 'Symptoms suggest minor illness. Rest, fluids, and home remedies recommended. Monitor for 48 hours.';
      case RiskLevel.medium:
        return 'Moderate symptoms present. Visit PHC within 24 hours for proper diagnosis and treatment.';
      case RiskLevel.high:
        return 'URGENT: Serious symptoms detected. Immediate medical attention required. Transport to hospital if possible.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Symptom Checker'),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            color: const Color(0xFF00897B),
            child: Row(
              children: [
                const Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select all symptoms',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_selectedSymptoms.length} selected',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Symptom Groups
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _symptomGroups.length,
              itemBuilder: (context, groupIndex) {
                final group = _symptomGroups[groupIndex];
                final symptoms = group['symptoms'] as List<String>;
                final color = group['color'] as Color;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Header
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(group['icon'], color: color, size: 24),
                            const SizedBox(width: 12),
                            Text(
                              group['category'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Symptoms
                      ...symptoms.map((symptom) {
                        final isSelected = _selectedSymptoms.contains(symptom);
                        
                        return InkWell(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedSymptoms.remove(symptom);
                              } else {
                                _selectedSymptoms.add(symptom);
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? color.withOpacity(0.05)
                                  : Colors.transparent,
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey.shade100,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: isSelected ? color : Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected ? color : Colors.grey.shade300,
                                      width: 2,
                                    ),
                                  ),
                                  child: isSelected
                                      ? const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 14,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    symptom,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      color: isSelected ? color : AppColors.textDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
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
            child: ActionButton(
              label: 'Check Urgency',
              icon: Icons.analytics,
              onPressed: _analyzeSymptoms,
              isLoading: _isProcessing,
              backgroundColor: const Color(0xFF00897B),
            ),
          ),
        ],
      ),
    );
  }
}
