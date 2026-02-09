import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../models/screening_result.dart';
import '../utils/constants.dart';
import 'risk_indicator.dart';

/// Patient card widget for history list
class PatientCard extends StatelessWidget {
  final Patient patient;
  final ScreeningResult? latestScreening;
  final VoidCallback? onTap;
  
  const PatientCard({
    super.key,
    required this.patient,
    this.latestScreening,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    patient.name.isNotEmpty ? patient.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Patient info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${patient.age} yrs • ${patient.gender}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textLight,
                      ),
                    ),
                    if (patient.symptoms.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${patient.symptoms.length} symptoms',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textLight.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Risk indicator or status
              if (latestScreening != null)
                RiskIndicator(
                  riskLevel: latestScreening!.riskLevel,
                  showLabel: false,
                  size: 40,
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'New',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textLight,
                    ),
                  ),
                ),
              
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: AppColors.textLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
