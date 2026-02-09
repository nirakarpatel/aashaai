import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';
import '../utils/routes.dart';
import '../widgets/module_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final storage = Provider.of<StorageService>(context, listen: false);
    final todayCount = storage.getTodayScreeningCount();
    final totalPatients = storage.patientCount;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back,',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                storage.workerName ?? 'ASHA Worker',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Stats Row
                    Row(
                      children: [
                        _buildStatCard(
                          'Today',
                          todayCount.toString(),
                          Icons.today,
                        ),
                        const SizedBox(width: 16),
                        _buildStatCard(
                          'Total Patients',
                          totalPatients.toString(),
                          Icons.people_outline,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Quick Actions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildQuickAction(
                        'New Screening',
                        Icons.add_circle_outline,
                        AppColors.primary,
                        () => Navigator.pushNamed(
                            context, AppRoutes.patientRegistration),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickAction(
                        'Patient History',
                        Icons.history,
                        AppColors.secondary,
                        () => Navigator.pushNamed(
                            context, AppRoutes.patientHistory),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // Modules Title
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Health Modules',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Modules Grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.95,
                ),
                delegate: SliverChildListDelegate([
                  ModuleCard(
                    title: 'TB Screening',
                    subtitle: 'Cough-based risk detection',
                    icon: Icons.mic,
                    color: const Color(0xFFE53935),
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.patientRegistration,
                      arguments: {'module': 'tb'},
                    ),
                  ),
                  ModuleCard(
                    title: 'Skin Disease',
                    subtitle: 'Photo-based detection',
                    icon: Icons.camera_alt,
                    color: const Color(0xFF8E24AA),
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.patientRegistration,
                      arguments: {'module': 'skin'},
                    ),
                  ),
                  ModuleCard(
                    title: 'Anemia Check',
                    subtitle: 'Palm/Eye pallor analysis',
                    icon: Icons.remove_red_eye,
                    color: const Color(0xFFFF6F00),
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.patientRegistration,
                      arguments: {'module': 'anemia'},
                    ),
                  ),
                  ModuleCard(
                    title: 'Maternal Health',
                    subtitle: 'Pregnancy risk screening',
                    icon: Icons.pregnant_woman,
                    color: const Color(0xFFEC407A),
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.patientRegistration,
                      arguments: {'module': 'maternal'},
                    ),
                  ),
                  ModuleCard(
                    title: 'Symptom Triage',
                    subtitle: 'General health checker',
                    icon: Icons.chat_bubble_outline,
                    color: const Color(0xFF00897B),
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.patientRegistration,
                      arguments: {'module': 'triage'},
                    ),
                  ),
                  ModuleCard(
                    title: 'More Coming',
                    subtitle: 'Diabetes, Eye, Dental...',
                    icon: Icons.more_horiz,
                    color: Colors.grey,
                    isEnabled: false,
                    onTap: () {},
                  ),
                ]),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
