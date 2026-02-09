import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Risk level indicator badge widget
class RiskIndicator extends StatelessWidget {
  final RiskLevel riskLevel;
  final bool showLabel;
  final double size;
  
  const RiskIndicator({
    super.key,
    required this.riskLevel,
    this.showLabel = true,
    this.size = 48,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: showLabel ? 16 : 8,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: riskLevel.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: riskLevel.color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            riskLevel.icon,
            color: riskLevel.color,
            size: size * 0.5,
          ),
          if (showLabel) ...[
            const SizedBox(width: 8),
            Text(
              riskLevel.displayName,
              style: TextStyle(
                color: riskLevel.color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Large risk display for result screen
class RiskIndicatorLarge extends StatelessWidget {
  final RiskLevel riskLevel;
  final int confidencePercent;
  
  const RiskIndicatorLarge({
    super.key,
    required this.riskLevel,
    required this.confidencePercent,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            riskLevel.color.withOpacity(0.1),
            riskLevel.color.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: riskLevel.color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: riskLevel.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: riskLevel.color.withOpacity(0.3),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              riskLevel.icon,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            riskLevel.displayName,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: riskLevel.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$confidencePercent% Confidence',
            style: TextStyle(
              fontSize: 16,
              color: riskLevel.color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
