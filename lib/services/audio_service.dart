import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';

/// Audio recording service for TB cough screening
class AudioService {
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  String? _currentRecordingPath;
  
  bool get isRecording => _isRecording;
  String? get currentRecordingPath => _currentRecordingPath;
  
  /// Check and request microphone permission
  Future<bool> checkPermission() async {
    return await _recorder.hasPermission();
  }
  
  /// Start recording cough audio
  Future<bool> startRecording() async {
    if (_isRecording) return false;
    
    final hasPermission = await checkPermission();
    if (!hasPermission) return false;
    
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'cough_${const Uuid().v4()}.m4a';
      _currentRecordingPath = '${directory.path}/recordings/$fileName';
      
      // Create recordings directory if not exists
      final recordingsDir = Directory('${directory.path}/recordings');
      if (!await recordingsDir.exists()) {
        await recordingsDir.create(recursive: true);
      }
      
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: _currentRecordingPath!,
      );
      
      _isRecording = true;
      return true;
    } catch (e) {
      _isRecording = false;
      return false;
    }
  }
  
  /// Stop recording and return the file path
  Future<String?> stopRecording() async {
    if (!_isRecording) return null;
    
    try {
      final path = await _recorder.stop();
      _isRecording = false;
      return path ?? _currentRecordingPath;
    } catch (e) {
      _isRecording = false;
      return null;
    }
  }
  
  /// Cancel recording without saving
  Future<void> cancelRecording() async {
    if (!_isRecording) return;
    
    try {
      await _recorder.stop();
      
      // Delete the incomplete recording
      if (_currentRecordingPath != null) {
        final file = File(_currentRecordingPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (e) {
      // Ignore errors during cancel
    } finally {
      _isRecording = false;
      _currentRecordingPath = null;
    }
  }
  
  /// Get amplitude for waveform visualization
  Future<double> getAmplitude() async {
    if (!_isRecording) return 0.0;
    
    try {
      final amplitude = await _recorder.getAmplitude();
      // Normalize amplitude to 0.0 - 1.0 range
      final normalized = ((amplitude.current + 60) / 60).clamp(0.0, 1.0);
      return normalized;
    } catch (e) {
      return 0.0;
    }
  }
  
  /// Delete a recorded audio file
  Future<void> deleteRecording(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Ignore errors
    }
  }
  
  void dispose() {
    _recorder.dispose();
  }
}
