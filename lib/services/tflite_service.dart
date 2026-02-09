import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import '../utils/constants.dart';

/// TFLite inference service for offline AI predictions
/// Supports multiple disease screening models
class TFLiteService {
  bool _isInitialized = false;
  
  // Model paths
  static const String tbModelPath = 'assets/models/tb_cough.tflite';
  static const String skinModelPath = 'assets/models/skin_disease.tflite';
  static const String anemiaModelPath = 'assets/models/anemia_screen.tflite';
  static const String maternalModelPath = 'assets/models/maternal_risk.tflite';
  
  Future<void> init() async {
    if (_isInitialized) return;
    
    // In production, initialize TFLite interpreter here
    // For hackathon demo, we use mock predictions
    _isInitialized = true;
  }
  
  /// Predict TB risk from cough audio features
  /// Returns probability score 0.0 - 1.0
  Future<PredictionResult> predictTBRisk(String audioPath) async {
    // Simulate processing time
    await Future.delayed(const Duration(seconds: 2));
    
    // Mock prediction for demo
    // In production: process audio -> spectrogram -> run TFLite model
    return _generateMockPrediction('TB Cough Analysis');
  }
  
  /// Predict skin disease from image
  Future<PredictionResult> predictSkinDisease(String imagePath) async {
    await Future.delayed(const Duration(seconds: 2));
    
    // Mock prediction with random skin condition
    final conditions = [
      'Fungal Infection',
      'Eczema',
      'Ringworm',
      'Scabies',
      'Contact Dermatitis',
      'Normal Skin',
    ];
    
    final random = Random();
    final condition = conditions[random.nextInt(conditions.length)];
    
    return _generateMockPrediction(condition);
  }
  
  /// Predict anemia risk from palm/eye image
  Future<PredictionResult> predictAnemiaRisk(String imagePath) async {
    await Future.delayed(const Duration(seconds: 2));
    
    return _generateMockPrediction('Anemia Pallor Analysis');
  }
  
  /// Predict maternal health risk from questionnaire
  Future<PredictionResult> predictMaternalRisk(Map<String, dynamic> answers) async {
    await Future.delayed(const Duration(seconds: 1));
    
    // Calculate risk based on danger signs
    int dangerSigns = 0;
    
    if (answers['highBP'] == true) dangerSigns += 2;
    if (answers['bleeding'] == true) dangerSigns += 3;
    if (answers['swelling'] == true) dangerSigns += 1;
    if (answers['severeHeadache'] == true) dangerSigns += 2;
    if (answers['reducedMovement'] == true) dangerSigns += 2;
    if (answers['weakness'] == true) dangerSigns += 1;
    
    double probability;
    if (dangerSigns >= 4) {
      probability = 0.7 + Random().nextDouble() * 0.25;
    } else if (dangerSigns >= 2) {
      probability = 0.4 + Random().nextDouble() * 0.25;
    } else {
      probability = Random().nextDouble() * 0.35;
    }
    
    return PredictionResult(
      condition: 'Maternal Health Assessment',
      probability: probability,
      riskLevel: _getRiskLevel(probability),
      confidence: 0.75 + Random().nextDouble() * 0.2,
    );
  }
  
  /// Symptom triage based on symptoms
  Future<PredictionResult> predictSymptomTriage(List<String> symptoms) async {
    await Future.delayed(const Duration(seconds: 1));
    
    // Weight symptoms for urgency
    int urgencyScore = 0;
    
    for (final symptom in symptoms) {
      if (symptom.contains('breathing') || symptom.contains('chest')) {
        urgencyScore += 3;
      } else if (symptom.contains('fever') || symptom.contains('blood')) {
        urgencyScore += 2;
      } else {
        urgencyScore += 1;
      }
    }
    
    double probability = (urgencyScore / 10).clamp(0.0, 0.95);
    
    return PredictionResult(
      condition: 'Symptom Triage',
      probability: probability,
      riskLevel: _getRiskLevel(probability),
      confidence: 0.7 + Random().nextDouble() * 0.25,
    );
  }
  
  /// Generate mock prediction for demo
  PredictionResult _generateMockPrediction(String condition) {
    final random = Random();
    
    // Weighted random to show variety in demo
    double probability;
    final roll = random.nextDouble();
    if (roll < 0.3) {
      probability = random.nextDouble() * 0.35; // Low risk
    } else if (roll < 0.7) {
      probability = 0.35 + random.nextDouble() * 0.35; // Medium risk
    } else {
      probability = 0.7 + random.nextDouble() * 0.25; // High risk
    }
    
    return PredictionResult(
      condition: condition,
      probability: probability,
      riskLevel: _getRiskLevel(probability),
      confidence: 0.75 + random.nextDouble() * 0.2,
    );
  }
  
  RiskLevel _getRiskLevel(double probability) {
    if (probability >= AppConstants.riskHighThreshold) {
      return RiskLevel.high;
    } else if (probability >= AppConstants.riskMediumThreshold) {
      return RiskLevel.medium;
    } else {
      return RiskLevel.low;
    }
  }
}

/// Prediction result from any model
class PredictionResult {
  final String condition;
  final double probability;
  final RiskLevel riskLevel;
  final double confidence;
  
  PredictionResult({
    required this.condition,
    required this.probability,
    required this.riskLevel,
    required this.confidence,
  });
  
  int get confidencePercent => (confidence * 100).round();
  int get probabilityPercent => (probability * 100).round();
}
