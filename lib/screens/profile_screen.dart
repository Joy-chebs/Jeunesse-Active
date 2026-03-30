import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_provider.dart';
import '../services/services_provider.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
          SliverToBoxAdapter(
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Background gradient
                Container(
                  height: 160,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primary, Color(0xFF1A6FA8)],
                    ),
                  ),
                ),

                // Top bar
                Positioned(
                  top: MediaQuery.of(context).padding.top + 12,
                  left: 16,
                  right: 16,
                  child: Row(
                    children: [
                      const Text(
                        'Mon Profil',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pushNamed('/edit-profile'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.edit_outlined, color: Colors.white, size: 14),
                              SizedBox(width: 6),
                              Text(
                                'Modifier',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () async {
                          await auth.logout();
                          if (context.mounted) {
                            Navigator.of(context).pushNamedAndRemoveUntil('/welcome', (_) => false);
                          }
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.logout_rounded, color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                ),

                // Avatar
                Positioned(
                  top: 100,
                  child: _AvatarWithUpload(user: user),
                ),
              ],
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 72, 20, 0),
              child: Column(
                children: [
                  // Name and verified
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      if (user.isVerified) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.verified_rounded,
                            color: AppTheme.primary, size: 20),
                      ],
                    ],
                  ),

                  const SizedBox(height: 4),

                  if (!isEmployee && user.companyName != null)
                    Text(
                      user.companyName!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                  Text(
                    isEmployee ? 'Prestataire de services' : 'Employeur',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),

                  if (user.location.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 14, color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          user.location,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 12),

                  // Rating
                  if (user.rating > 0)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        StarRating(rating: user.rating, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          '${user.rating} (${user.reviewCount} avis)',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 20),

                  // Stats cards
                  Row(
                    children: [
                      _profileStat('Offres', '${myOffers.length}', Icons.assignment_outlined),
                      const SizedBox(width: 10),
                      _profileStat('Avis', '${user.reviewCount}', Icons.star_outline_rounded),
                      const SizedBox(width: 10),
                      _profileStat('Vues', '${myOffers.fold(0, (sum, o) => sum + o.viewCount)}',
                          Icons.remove_red_eye_outlined),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Bio
                  if (user.bio.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'À propos',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            user.bio,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Skills
                  if (user.skills.isNotEmpty) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SectionHeader(title: 'Compétences'),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: user.skills
                          .map((s) => SkillChip(label: s, isSelected: true))
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Services
                  if (myOffers.isNotEmpty) ...[
                    SectionHeader(
                      title: 'Mes services (${myOffers.length})',
                      actionLabel: isEmployee ? '+ Ajouter' : null,
                      onAction: isEmployee
                          ? () => Navigator.of(context).pushNamed('/add-service')
                          : null,
                    ),
                    const SizedBox(height: 14),
                    ...myOffers.map((offer) => ServiceCard(
                          offer: offer,
                          onTap: () => Navigator.of(context).pushNamed(
                            '/service-detail',
                            arguments: {'offer': offer},
                          ),
                        )),
                  ] else if (isEmployee) ...[
                    AppButton(
                      label: 'Publier ma première offre',
                      icon: Icons.add_rounded,
                      color: AppTheme.accent,
                      onPressed: () => Navigator.of(context).pushNamed('/add-service'),
                    ),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileStat(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primary, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarWithUpload extends StatefulWidget {
  final UserModel user;
  const _AvatarWithUpload({required this.user});

  @override
  State<_AvatarWithUpload> createState() => _AvatarWithUploadState();
}

class _AvatarWithUploadState extends State<_AvatarWithUpload> {
  final _picker = ImagePicker();

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choisir une photo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppTheme.primary,
                  child: Icon(Icons.camera_alt_rounded, color: Colors.white),
                ),
                title: const Text('Prendre une photo'),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _capture(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppTheme.accent,
                  child: Icon(Icons.photo_library_rounded, color: Colors.white),
                ),
                title: const Text('Galerie photo'),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _capture(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _capture(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (pickedFile != null && mounted) {
      await context.read<AuthProvider>().updateProfile(
        profileImagePath: pickedFile.path,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [AppDecorations.cardShadow],
            ),
            child: UserAvatar(
              imagePath: widget.user.profileImagePath,
              name: widget.user.name,
              size: 90,
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppTheme.accent,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14),
            ),
          ),
        ],
      ),
    );
  }
}

// Edit Profile Screen
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;
  late TextEditingController _locationController;
  late TextEditingController _companyController;
  late TextEditingController _skillController;
  late List<String> _skills;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser!;
    _nameController = TextEditingController(text: user.name);
    _phoneController = TextEditingController(text: user.phone);
    _bioController = TextEditingController(text: user.bio);
    _locationController = TextEditingController(text: user.location);
    _companyController = TextEditingController(text: user.companyName ?? '');
    _skillController = TextEditingController();
    _skills = List<String>.from(user.skills);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _companyController.dispose();
    _skillController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final auth = context.read<AuthProvider>();
    final isEmployee = auth.currentUser!.userType == UserType.employee;

    await auth.updateProfile(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      bio: _bioController.text.trim(),
      location: _locationController.text.trim(),
      skills: _skills,
      companyName: !isEmployee ? _companyController.text.trim() : null,
    );

    setState(() => _isSaving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profil mis à jour avec succès !'),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isEmployee = auth.currentUser!.userType == UserType.employee;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier le profil'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Enregistrer',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                label: 'Nom complet',
                controller: _nameController,
                prefixIcon: const Icon(Icons.person_outline),
                validator: (v) => v!.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 14),

              AppTextField(
                label: 'Téléphone',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone_outlined),
              ),
              const SizedBox(height: 14),

              AppTextField(
                label: 'Localisation',
                controller: _locationController,
                prefixIcon: const Icon(Icons.location_on_outlined),
                hint: 'ex: Yaoundé, Centre',
              ),
              const SizedBox(height: 14),

              if (!isEmployee) ...[
                AppTextField(
                  label: 'Nom de l\'entreprise',
                  controller: _companyController,
                  prefixIcon: const Icon(Icons.business_outlined),
                ),
                const SizedBox(height: 14),
              ],

              AppTextField(
                label: 'Bio / Présentation',
                controller: _bioController,
                maxLines: 4,
                hint: 'Décrivez-vous, vos expériences, vos services...',
              ),

              if (isEmployee) ...[
                const SizedBox(height: 20),
                const Text(
                  'Compétences',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'Ajouter une compétence',
                        controller: _skillController,
                        prefixIcon: const Icon(Icons.add_circle_outline),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        final skill = _skillController.text.trim();
                        if (skill.isNotEmpty && !_skills.contains(skill)) {
                          setState(() {
                            _skills.add(skill);
                            _skillController.clear();
                          });
                        }
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.add_rounded, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                if (_skills.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _skills
                        .map((s) => SkillChip(
                              label: s,
                              isSelected: true,
                              canDelete: true,
                              onDelete: () => setState(() => _skills.remove(s)),
                            ))
                        .toList(),
                  ),
                ],
              ],

              const SizedBox(height: 28),
              AppButton(
                label: 'Enregistrer les modifications',
                onPressed: _save,
                isLoading: _isSaving,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
