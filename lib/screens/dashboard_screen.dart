import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../services/services_provider.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final services = context.watch<ServicesProvider>();
    final user = auth.currentUser!;
    final isEmployee = user.userType == UserType.employee;
    final myOffers = services.getOffersForUser(user.id);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                bottom: 24,
                left: 20,
                right: 20,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primary, Color(0xFF1A6FA8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      UserAvatar(
                        imagePath: user.profileImagePath,
                        name: user.name,
                        size: 44,
                        isOnline: true,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bonjour, ${user.name.split(' ').first} 👋',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              isEmployee ? 'Prestataire de services' : 'Employeur',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (user.isVerified)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.success.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppTheme.success.withOpacity(0.4),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified_rounded,
                                  color: Colors.greenAccent, size: 14),
                              SizedBox(width: 4),
                              Text(
                                'Vérifié',
                                style: TextStyle(
                                  color: Colors.greenAccent,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Stats row
                  Row(
                    children: [
                      _statCard(
                        isEmployee ? 'Mes offres' : 'Publiées',
                        '${myOffers.length}',
                        Icons.assignment_outlined,
                      ),
                      const SizedBox(width: 10),
                      _statCard(
                        'Note',
                        user.rating > 0 ? '${user.rating}/5' : 'N/A',
                        Icons.star_outline_rounded,
                      ),
                      const SizedBox(width: 10),
                      _statCard(
                        'Avis',
                        '${user.reviewCount}',
                        Icons.reviews_outlined,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick actions
                  SectionHeader(
                    title: 'Actions rapides',
                    actionLabel: '',
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      if (isEmployee) ...[
                        _quickAction(
                          context,
                          icon: Icons.add_circle_outline_rounded,
                          label: 'Ajouter\nune offre',
                          color: AppTheme.primary,
                          onTap: () => Navigator.of(context).pushNamed('/add-service'),
                        ),
                        const SizedBox(width: 12),
                        _quickAction(
                          context,
                          icon: Icons.edit_outlined,
                          label: 'Modifier\nle profil',
                          color: AppTheme.accent,
                          onTap: () => Navigator.of(context).pushNamed('/edit-profile'),
                        ),
                      ] else ...[
                        _quickAction(
                          context,
                          icon: Icons.search_rounded,
                          label: 'Chercher\ndes talents',
                          color: AppTheme.primary,
                          onTap: () {},
                        ),
                        const SizedBox(width: 12),
                        _quickAction(
                          context,
                          icon: Icons.map_outlined,
                          label: 'Voir la\ncarte',
                          color: AppTheme.accent,
                          onTap: () {},
                        ),
                      ],
                      const SizedBox(width: 12),
                      _quickAction(
                        context,
                        icon: Icons.chat_bubble_outline_rounded,
                        label: 'Messages',
                        color: AppTheme.success,
                        onTap: () {},
                      ),
                      const SizedBox(width: 12),
                      _quickAction(
                        context,
                        icon: Icons.location_on_outlined,
                        label: 'Autour\nde moi',
                        color: AppTheme.warning,
                        onTap: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Banner CTA
                  if (isEmployee && myOffers.isEmpty)
                    _bannerCTA(context),

                  // My offers or recent services
                  if (isEmployee && myOffers.isNotEmpty) ...[
                    SectionHeader(
                      title: 'Mes offres',
                      actionLabel: 'Voir tout',
                      onAction: () {},
                    ),
                    const SizedBox(height: 14),
                    ...myOffers.take(3).map((offer) => ServiceCard(
                          offer: offer,
                          user: auth.currentUser,
                          onTap: () => Navigator.of(context).pushNamed(
                            '/service-detail',
                            arguments: {'offer': offer},
                          ),
                        )),
                  ],

                  // Recent services for employers
                  if (!isEmployee) ...[
                    SectionHeader(
                      title: 'Dernières offres',
                      actionLabel: 'Voir tout',
                      onAction: () {},
                    ),
                    const SizedBox(height: 14),
                    ...services.offers.take(3).map((offer) {
                      final offerUser = auth.allUsers
                          .firstWhere((u) => u.id == offer.userId, orElse: () => auth.currentUser!);
                      return ServiceCard(
                        offer: offer,
                        user: offerUser,
                        onTap: () => Navigator.of(context).pushNamed(
                          '/service-detail',
                          arguments: {'offer': offer},
                        ),
                      );
                    }),
                  ],

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.15)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bannerCTA(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.accent, Color(0xFFFF8C61)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Publiez votre\npremière offre !',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Commencez à attirer des clients dès maintenant',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => Navigator.of(context).pushNamed('/add-service'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Commencer →',
                      style: TextStyle(
                        color: AppTheme.accent,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.star_rounded, color: Colors.white, size: 80),
        ],
      ),
    );
  }
}
