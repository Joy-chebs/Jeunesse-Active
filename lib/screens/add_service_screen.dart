import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../services/services_provider.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class AddServiceScreen extends StatefulWidget {
  const AddServiceScreen({super.key});

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  String _selectedCategory = kCategories.first.name;
  String _priceType = 'fixed';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser!;
    _locationController.text = user.location;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _publish() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final auth = context.read<AuthProvider>();
    final services = context.read<ServicesProvider>();

    final offer = ServiceOffer(
      userId: auth.currentUser!.id,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      category: _selectedCategory,
      price: double.tryParse(_priceController.text) ?? 0,
      priceType: _priceType,
      location: _locationController.text.trim(),
      latitude: auth.currentUser!.latitude,
      longitude: auth.currentUser!.longitude,
    );

    await services.addOffer(offer);
    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Offre publiée avec succès ! 🎉'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle offre'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category picker
              const Text(
                'Catégorie',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: kCategories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = kCategories[index];
                    final isSelected = _selectedCategory == cat.name;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat.name),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primary : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? AppTheme.primary : AppTheme.border,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(cat.icon, style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                            Text(
                              cat.name,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              AppTextField(
                label: 'Titre de l\'offre',
                controller: _titleController,
                hint: 'ex: Développement d\'application mobile',
                validator: (v) => v!.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 14),

              AppTextField(
                label: 'Description',
                controller: _descController,
                maxLines: 5,
                hint: 'Décrivez votre service en détail...',
                validator: (v) => v!.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 14),

              // Price type
              const Text(
                'Type de tarif',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _priceTypeChip('fixed', 'Forfait'),
                  const SizedBox(width: 10),
                  _priceTypeChip('hourly', 'Par heure'),
                  const SizedBox(width: 10),
                  _priceTypeChip('daily', 'Par jour'),
                ],
              ),
              const SizedBox(height: 14),

              AppTextField(
                label: 'Prix (FCFA)',
                controller: _priceController,
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.attach_money_rounded),
                validator: (v) {
                  if (v!.isEmpty) return 'Champ requis';
                  if (double.tryParse(v) == null) return 'Prix invalide';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              AppTextField(
                label: 'Localisation',
                controller: _locationController,
                prefixIcon: const Icon(Icons.location_on_outlined),
                hint: 'ex: Yaoundé, Centre',
                validator: (v) => v!.isEmpty ? 'Champ requis' : null,
              ),

              const SizedBox(height: 28),

              AppButton(
                label: 'Publier l\'offre',
                icon: Icons.rocket_launch_rounded,
                onPressed: _publish,
                isLoading: _isSaving,
                color: AppTheme.accent,
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _priceTypeChip(String value, String label) {
    final isSelected = _priceType == value;
    return GestureDetector(
      onTap: () => setState(() => _priceType = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}
