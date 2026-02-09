import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/patient.dart';
import '../models/screening_result.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';
import '../utils/routes.dart';
import '../widgets/patient_card.dart';

class PatientHistoryScreen extends StatefulWidget {
  const PatientHistoryScreen({super.key});

  @override
  State<PatientHistoryScreen> createState() => _PatientHistoryScreenState();
}

class _PatientHistoryScreenState extends State<PatientHistoryScreen> {
  RiskLevel? _filterRisk;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Patient> _getFilteredPatients(StorageService storage) {
    var patients = storage.getAllPatients();

    // Filter by search
    if (_searchQuery.isNotEmpty) {
      patients = patients.where((p) {
        return p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (p.phone?.contains(_searchQuery) ?? false);
      }).toList();
    }

    // Filter by risk level
    if (_filterRisk != null) {
      patients = patients.where((p) {
        if (p.latestScreeningId == null) return false;
        final screening = storage.getScreening(p.latestScreeningId!);
        return screening?.riskLevel == _filterRisk;
      }).toList();
    }

    return patients;
  }

  @override
  Widget build(BuildContext context) {
    final storage = Provider.of<StorageService>(context, listen: false);
    final patients = _getFilteredPatients(storage);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Patient History'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: _PatientSearchDelegate(storage),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', null),
                  const SizedBox(width: 8),
                  _buildFilterChip('High Risk', RiskLevel.high),
                  const SizedBox(width: 8),
                  _buildFilterChip('Medium Risk', RiskLevel.medium),
                  const SizedBox(width: 8),
                  _buildFilterChip('Low Risk', RiskLevel.low),
                ],
              ),
            ),
          ),

          // Stats Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildStatBadge(
                  'Total',
                  storage.patientCount.toString(),
                  AppColors.secondary,
                ),
                const SizedBox(width: 12),
                _buildStatBadge(
                  'High Risk',
                  storage.getScreeningsByRisk(RiskLevel.high).length.toString(),
                  AppColors.riskHigh,
                ),
                const SizedBox(width: 12),
                _buildStatBadge(
                  'Referred',
                  storage
                      .getAllScreenings()
                      .where((s) => s.isReferred)
                      .length
                      .toString(),
                  AppColors.riskLow,
                ),
              ],
            ),
          ),

          // Patient List
          Expanded(
            child: patients.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: AppColors.textLight.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No patients found',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.textLight,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _filterRisk != null
                              ? 'Try removing filters'
                              : 'Start a new screening',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textLight.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: patients.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final patient = patients[index];
                      final screening = patient.latestScreeningId != null
                          ? storage.getScreening(patient.latestScreeningId!)
                          : null;

                      return PatientCard(
                        patient: patient,
                        latestScreening: screening,
                        onTap: () {
                          if (screening != null) {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.result,
                              arguments: {
                                'patientId': patient.id,
                                'screeningId': screening.id,
                              },
                            );
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.patientRegistration),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('New Screening'),
      ),
    );
  }

  Widget _buildFilterChip(String label, RiskLevel? risk) {
    final isSelected = _filterRisk == risk;
    final color = risk?.color ?? AppColors.secondary;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _filterRisk = selected ? risk : null);
      },
      backgroundColor: Colors.grey.shade100,
      selectedColor: color.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? color : AppColors.textMedium,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      checkmarkColor: color,
      side: BorderSide(
        color: isSelected ? color : Colors.transparent,
      ),
    );
  }

  Widget _buildStatBadge(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Search Delegate
class _PatientSearchDelegate extends SearchDelegate<Patient?> {
  final StorageService storage;

  _PatientSearchDelegate(this.storage);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final patients = storage.getAllPatients().where((p) {
      return p.name.toLowerCase().contains(query.toLowerCase()) ||
          (p.phone?.contains(query) ?? false);
    }).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: patients.length,
      itemBuilder: (context, index) {
        final patient = patients[index];
        final screening = patient.latestScreeningId != null
            ? storage.getScreening(patient.latestScreeningId!)
            : null;

        return PatientCard(
          patient: patient,
          latestScreening: screening,
          onTap: () {
            close(context, patient);
            if (screening != null) {
              Navigator.pushNamed(
                context,
                AppRoutes.result,
                arguments: {
                  'patientId': patient.id,
                  'screeningId': screening.id,
                },
              );
            }
          },
        );
      },
    );
  }
}
