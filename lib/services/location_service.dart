import 'package:geolocator/geolocator.dart';

/// Location service for finding nearest PHC
class LocationService {
  /// Check and request location permission
  Future<bool> checkPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }
    
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    
    return true;
  }
  
  /// Get current location
  Future<Position?> getCurrentLocation() async {
    final hasPermission = await checkPermission();
    if (!hasPermission) return null;
    
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      return null;
    }
  }
  
  /// Find nearest PHC from predefined list
  /// In production, this would query a real database
  Future<PHCInfo?> findNearestPHC(Position currentPosition) async {
    // Demo PHC data for rural Odisha
    final phcList = [
      PHCInfo(
        name: 'PHC Bhubaneswar Block-A',
        address: 'Khandagiri, Bhubaneswar',
        phone: '0674-2350001',
        latitude: 20.2556,
        longitude: 85.8004,
      ),
      PHCInfo(
        name: 'Community Health Center Jatni',
        address: 'Jatni, Khordha',
        phone: '0674-2490012',
        latitude: 20.1606,
        longitude: 85.7078,
      ),
      PHCInfo(
        name: 'PHC Khordha Town',
        address: 'Station Road, Khordha',
        phone: '06755-220123',
        latitude: 20.1825,
        longitude: 85.6156,
      ),
      PHCInfo(
        name: 'Sub-Center Dhauli',
        address: 'Dhauli Village, Bhubaneswar',
        phone: '0674-2431001',
        latitude: 20.2099,
        longitude: 85.8361,
      ),
      PHCInfo(
        name: 'PHC Pipili',
        address: 'Main Road, Pipili',
        phone: '06758-222001',
        latitude: 20.1147,
        longitude: 85.8304,
      ),
    ];
    
    PHCInfo? nearest;
    double? minDistance;
    
    for (final phc in phcList) {
      final distance = Geolocator.distanceBetween(
        currentPosition.latitude,
        currentPosition.longitude,
        phc.latitude,
        phc.longitude,
      );
      
      if (minDistance == null || distance < minDistance) {
        minDistance = distance;
        nearest = phc.copyWith(distanceMeters: distance);
      }
    }
    
    return nearest;
  }
  
  /// Get distance string (formatted)
  String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
  }
}

/// PHC Information
class PHCInfo {
  final String name;
  final String address;
  final String phone;
  final double latitude;
  final double longitude;
  final double? distanceMeters;
  
  PHCInfo({
    required this.name,
    required this.address,
    required this.phone,
    required this.latitude,
    required this.longitude,
    this.distanceMeters,
  });
  
  PHCInfo copyWith({double? distanceMeters}) {
    return PHCInfo(
      name: name,
      address: address,
      phone: phone,
      latitude: latitude,
      longitude: longitude,
      distanceMeters: distanceMeters ?? this.distanceMeters,
    );
  }
  
  String get distanceFormatted {
    if (distanceMeters == null) return 'Unknown';
    if (distanceMeters! < 1000) {
      return '${distanceMeters!.round()} m away';
    } else {
      return '${(distanceMeters! / 1000).toStringAsFixed(1)} km away';
    }
  }
  
  String get mapsUrl {
    return 'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude';
  }
}
