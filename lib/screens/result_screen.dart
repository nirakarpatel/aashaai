import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/patient.dart';
import '../models/screening_result.dart';
import '../services/location_service.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';
import '../utils/routes.dart';
import '../widgets/action_button.dart';
import '../widgets/risk_indicator.dart';

class ResultScreen extends StatefulWidget {
  final String patientId;
  final String screeningId;

  const ResultScreen({
    super.key,
    required this.patientId,
    required this.screeningId,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final LocationService _locationService = LocationService();
  
  Patient? _patient;
  ScreeningResult? _screening;
  PHCInfo? _nearestPHC;
  bool _isLoadingPHC = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final storage = Provider.of<StorageService>(context, listen: false);
    setState(() {
      _patient = storage.getPatient(widget.patientId);
      _screening = storage.getScreening(widget.screeningId);
    });

    // Find nearest PHC for medium/high risk
    if (_screening != null && _screening!.riskLevel != RiskLevel.low) {
      _findNearestPHC();
    }
  }

  Future<void> _findNearestPHC() async {
    setState(() => _isLoadingPHC = true);

    try {
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        final phc = await _locationService.findNearestPHC(position);
        setState(() => _nearestPHC = phc);
      }
    } catch (e) {
      // Ignore location errors
    } finally {
      setState(() => _isLoadingPHC = false);
    }
  }

  Future<void> _openMaps() async {
    if (_nearestPHC == null) return;

    final url = Uri.parse(_nearestPHC!.mapsUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _markAsReferred() async {
    if (_screening == null) return;

    final storage = Provider.of<StorageService>(context, listen: false);
    final updated = _screening!.copyWith(isReferred: true);
    await storage.saveScreening(updated);

    setState(() => _screening = updated);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Patient marked as referred'),
          backgroundColor: AppColors.riskLow,
        ),
      );
    }
  }

  void _goToHome() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_screening == null || _patient == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final riskLevel = _screening!.riskLevel;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Screening Result'),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        _patient!.name[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _patient!.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${_patient!.age} yrs • ${_patient!.gender}',
                          style: const TextStyle(
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_screening!.isReferred)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.riskLow.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Referred',
                        style: TextStyle(
                          color: AppColors.riskLow,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Risk Level Card
            RiskIndicatorLarge(
              riskLevel: riskLevel,
              confidencePercent: _screening!.confidence.toInt() * 100 ~/ 1,
            ),

            const SizedBox(height: 24),

            // Recommendation Card
            Container(
              padding: const EdgeInsets.all(20),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.medical_services_outlined,
                        color: riskLevel.color,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Recommendation',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    riskLevel.recommendation,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: AppColors.textMedium,
                    ),
                  ),
                ],
              ),
            ),

            // Nearest PHC (for medium/high risk)
            if (riskLevel != RiskLevel.low) ...[
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: riskLevel.color.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: riskLevel.color,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Nearest Health Center',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (_isLoadingPHC)
                      const Center(
                        child: CircularProgressIndicator(),
                      )
                    else if (_nearestPHC != null) ...[
                      Text(
                        _nearestPHC!.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _nearestPHC!.address,
                        style: const TextStyle(
                          color: AppColors.textMedium,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.navigation,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _nearestPHC!.distanceFormatted,
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.phone,
                            size: 16,
                            color: AppColors.textLight,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _nearestPHC!.phone,
                            style: const TextStyle(
                              color: AppColors.textMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SecondaryButton(
                        label: 'Open in Maps',
                        icon: Icons.map,
                        onPressed: _openMaps,
                        height: 48,
                      ),
                    ] else
                      const Text(
                        'Could not determine location.\nPlease enable GPS.',
                        style: TextStyle(
                          color: AppColors.textLight,
                        ),
                      ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Action Buttons
            if (riskLevel != RiskLevel.low && !_screening!.isReferred)
              ActionButton(
                label: 'Mark as Referred',
                icon: Icons.check_circle_outline,
                onPressed: _markAsReferred,
                backgroundColor: riskLevel.color,
              ),

            if (riskLevel != RiskLevel.low && !_screening!.isReferred)
              const SizedBox(height: 12),

            ActionButton(
              label: 'Back to Home',
              icon: Icons.home,
              onPressed: _goToHome,
              backgroundColor:
                  _screening!.isReferred ? AppColors.primary : AppColors.textDark,
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
