import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/auth_provider.dart';
import '../services/services_provider.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  Position? _currentPosition;
  bool _isLoadingLocation = false;
  String _locationError = '';
  List<UserModel> _nearbyUsers = [];
  UserModel? _selectedUser;

  // Default center: Yaoundé, Cameroun
  static const LatLng _defaultCenter = LatLng(3.8667, 11.5167);

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationError = '';
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationError = 'Le service de localisation est désactivé.';
          _isLoadingLocation = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationError = 'Permission de localisation refusée.';
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationError = 'Permission de localisation refusée définitivement.';
          _isLoadingLocation = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _isLoadingLocation = false;
      });

      _mapController.move(
        LatLng(position.latitude, position.longitude),
        13,
      );

      _loadNearbyUsers(position.latitude, position.longitude);

      // Save location to profile
      if (mounted) {
        context.read<AuthProvider>().updateProfile(
          latitude: position.latitude,
          longitude: position.longitude,
        );
      }
    } catch (e) {
      setState(() {
        _locationError = 'Impossible d\'obtenir votre position.';
        _isLoadingLocation = false;
      });
    }
  }

  void _loadNearbyUsers(double lat, double lng) {
    final auth = context.read<AuthProvider>();
    setState(() {
      _nearbyUsers = auth.getNearbyUsers(lat, lng, radiusKm: 500);
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final services = context.watch<ServicesProvider>();

    final center = _currentPosition != null
        ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
        : _defaultCenter;

    // Build markers from all users with locations
    final allUsersWithLocation = auth.allUsers
        .where((u) => u.latitude != null && u.longitude != null && u.id != auth.currentUser?.id)
        .toList();

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 12,
              onTap: (_, __) => setState(() => _selectedUser = null),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.jeunesseactive.app',
              ),

              // Markers for other users
              MarkerLayer(
                markers: [
                  // Current user marker
                  if (_currentPosition != null)
                    Marker(
                      point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                      width: 50,
                      height: 50,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x440A3D62),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.my_location_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ),

                  // Other users
                  ...allUsersWithLocation.map((u) => Marker(
                    point: LatLng(u.latitude!, u.longitude!),
                    width: 46,
                    height: 46,
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedUser = u),
                      child: Container(
                        decoration: BoxDecoration(
                          color: u.userType == UserType.employee
                              ? AppTheme.accent
                              : AppTheme.success,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _selectedUser?.id == u.id
                                ? Colors.white
                                : Colors.white70,
                            width: 2.5,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x33000000),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            u.name.trim().isNotEmpty
                                ? u.name.trim().split(' ').take(1).map((w) => w[0].toUpperCase()).join()
                                : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )),
                ],
              ),
            ],
          ),

          // Header overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 12,
                bottom: 12,
                left: 16,
                right: 16,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    Colors.white.withOpacity(0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [AppDecorations.cardShadow],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on_rounded,
                              color: AppTheme.primary, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Prestataires proches',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${allUsersWithLocation.length}',
                              style: const TextStyle(
                                color: AppTheme.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _getCurrentLocation,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [AppDecorations.cardShadow],
                      ),
                      child: _isLoadingLocation
                          ? const Center(
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(AppTheme.primary),
                                ),
                              ),
                            )
                          : const Icon(Icons.gps_fixed_rounded,
                              color: AppTheme.primary, size: 22),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Error message
          if (_locationError.isNotEmpty)
            Positioned(
              top: MediaQuery.of(context).padding.top + 80,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.error,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _locationError,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Selected user card
          if (_selectedUser != null)
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: _buildUserCard(_selectedUser!, services),
            ),

          // Legend
          Positioned(
            bottom: 90,
            right: 16,
            child: Column(
              children: [
                _legendItem(AppTheme.accent, 'Prestataire'),
                const SizedBox(height: 6),
                _legendItem(AppTheme.success, 'Employeur'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [AppDecorations.cardShadow],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(UserModel user, ServicesProvider services) {
    final userOffers = services.getOffersForUser(user.id);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          const BoxShadow(
            color: Color(0x20000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              UserAvatar(imagePath: user.profileImagePath, name: user.name, size: 52),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    if (user.location.isNotEmpty)
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 12, color: AppTheme.textSecondary),
                          const SizedBox(width: 3),
                          Text(
                            user.location,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    if (user.rating > 0)
                      Row(
                        children: [
                          StarRating(rating: user.rating, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '(${user.reviewCount})',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _selectedUser = null),
                child: const Icon(Icons.close_rounded, color: AppTheme.textSecondary),
              ),
            ],
          ),
          if (user.skills.isNotEmpty) ...[
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: user.skills.take(4).map((s) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: SkillChip(label: s),
                )).toList(),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Voir profil',
                  isOutlined: true,
                  onPressed: () => Navigator.of(context).pushNamed(
                    '/user-profile',
                    arguments: {'user': user},
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppButton(
                  label: 'Contacter',
                  icon: Icons.chat_bubble_outline_rounded,
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
