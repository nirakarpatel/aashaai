import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Symptom checkbox with large touch area
class SymptomCheckbox extends StatelessWidget {
  final String symptom;
  final bool isChecked;
  final ValueChanged<bool> onChanged;
  
  const SymptomCheckbox({
    super.key,
    required this.symptom,
    required this.isChecked,
    required this.onChanged,
  });
  
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(!isChecked),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isChecked 
                ? AppColors.primary.withOpacity(0.1)
                : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isChecked 
                  ? AppColors.primary.withOpacity(0.3)
                  : Colors.grey.shade200,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isChecked ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isChecked 
                        ? AppColors.primary 
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
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  symptom,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isChecked ? FontWeight.w600 : FontWeight.normal,
                    color: isChecked 
                        ? AppColors.textDark 
                        : AppColors.textMedium,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
