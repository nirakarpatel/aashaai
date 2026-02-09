import 'package:hive_flutter/hive_flutter.dart';
import '../models/patient.dart';
import '../models/screening_result.dart';
import '../utils/constants.dart';

class StorageService {
  late Box<Patient> _patientBox;
  late Box<ScreeningResult> _screeningBox;
  late Box _settingsBox;
  
  bool _isInitialized = false;
  
  Future<void> init() async {
    if (_isInitialized) return;
    
    // Register adapters
    Hive.registerAdapter(PatientAdapter());
    Hive.registerAdapter(ScreeningResultAdapter());
    
    // Open boxes
    _patientBox = await Hive.openBox<Patient>(AppConstants.patientBoxKey);
    _screeningBox = await Hive.openBox<ScreeningResult>(AppConstants.screeningBoxKey);
    _settingsBox = await Hive.openBox(AppConstants.settingsBoxKey);
    
    _isInitialized = true;
  }
  
  // ============================================
  // PATIENT OPERATIONS
  // ============================================
  
  Future<void> savePatient(Patient patient) async {
    await _patientBox.put(patient.id, patient);
  }
  
  Patient? getPatient(String id) {
    return _patientBox.get(id);
  }
  
  List<Patient> getAllPatients() {
    return _patientBox.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
  
  Future<void> deletePatient(String id) async {
    await _patientBox.delete(id);
  }
  
  int get patientCount => _patientBox.length;
  
  // ============================================
  // SCREENING OPERATIONS
  // ============================================
  
  Future<void> saveScreening(ScreeningResult screening) async {
    await _screeningBox.put(screening.id, screening);
    
    // Update patient's latest screening
    final patient = getPatient(screening.patientId);
    if (patient != null) {
      final updated = patient.copyWith(latestScreeningId: screening.id);
      await savePatient(updated);
    }
  }
  
  ScreeningResult? getScreening(String id) {
    return _screeningBox.get(id);
  }
  
  List<ScreeningResult> getAllScreenings() {
    return _screeningBox.values.toList()
      ..sort((a, b) => b.screenedAt.compareTo(a.screenedAt));
  }
  
  List<ScreeningResult> getPatientScreenings(String patientId) {
    return _screeningBox.values
      .where((s) => s.patientId == patientId)
      .toList()
      ..sort((a, b) => b.screenedAt.compareTo(a.screenedAt));
  }
  
  List<ScreeningResult> getScreeningsByRisk(RiskLevel level) {
    return _screeningBox.values
      .where((s) => s.riskLevel == level)
      .toList()
      ..sort((a, b) => b.screenedAt.compareTo(a.screenedAt));
  }
  
  int getTodayScreeningCount() {
    final today = DateTime.now();
    return _screeningBox.values.where((s) {
      return s.screenedAt.year == today.year &&
          s.screenedAt.month == today.month &&
          s.screenedAt.day == today.day;
    }).length;
  }
  
  int get screeningCount => _screeningBox.length;
  
  // ============================================
  // SETTINGS OPERATIONS
  // ============================================
  
  Future<void> setSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }
  
  T? getSetting<T>(String key) {
    return _settingsBox.get(key) as T?;
  }
  
  bool get isFirstLaunch => getSetting<bool>('firstLaunch') ?? true;
  
  Future<void> setFirstLaunchComplete() async {
    await setSetting('firstLaunch', false);
  }
  
  String? get workerName => getSetting<String>('workerName');
  String? get workerPhone => getSetting<String>('workerPhone');
  
  Future<void> saveWorkerInfo(String name, String phone) async {
    await setSetting('workerName', name);
    await setSetting('workerPhone', phone);
  }
  
  // ============================================
  // SYNC STATUS
  // ============================================
  
  List<Patient> getUnsyncedPatients() {
    return _patientBox.values.where((p) => !p.isSynced).toList();
  }
  
  List<ScreeningResult> getUnsyncedScreenings() {
    return _screeningBox.values.where((s) => !s.isSynced).toList();
  }
  
  Future<void> markPatientSynced(String id) async {
    final patient = getPatient(id);
    if (patient != null) {
      final updated = patient.copyWith(isSynced: true);
      await savePatient(updated);
    }
  }
  
  Future<void> markScreeningSynced(String id) async {
    final screening = getScreening(id);
    if (screening != null) {
      final updated = screening.copyWith(isSynced: true);
      await saveScreening(updated);
    }
  }
}
