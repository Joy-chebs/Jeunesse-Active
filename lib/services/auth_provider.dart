import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;
  List<UserModel> _allUsers = [];

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;
  List<UserModel> get allUsers => _allUsers;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    await _loadSampleUsers();
    await _loadCurrentUser();
  }

  Future<void> _loadSampleUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('all_users');
    if (usersJson != null) {
      final List decoded = jsonDecode(usersJson);
      _allUsers = decoded.map((e) => UserModel.fromMap(e)).toList();
    } else {
      // Create sample users
      _allUsers = [
        UserModel(
          id: 'sample_emp1',
          name: 'Jean-Pierre Mbarga',
          email: 'jpmbarga@email.com',
          phone: '+237 677 123 456',
          bio: 'Développeur web passionné avec 3 ans d\'expérience en React et Flutter.',
          userType: UserType.employee,
          location: 'Yaoundé, Centre',
          latitude: 3.8667,
          longitude: 11.5167,
          skills: ['Flutter', 'React', 'Node.js', 'UI/UX'],
          rating: 4.8,
          reviewCount: 24,
          isVerified: true,
        ),
        UserModel(
          id: 'sample_emp2',
          name: 'Amina Diallo',
          email: 'amina.d@email.com',
          phone: '+237 699 234 567',
          bio: 'Designer graphique créative spécialisée en branding et identité visuelle.',
          userType: UserType.employee,
          location: 'Douala, Littoral',
          latitude: 4.0511,
          longitude: 9.7679,
          skills: ['Photoshop', 'Illustrator', 'Figma', 'Branding'],
          rating: 4.9,
          reviewCount: 38,
          isVerified: true,
        ),
        UserModel(
          id: 'sample_er1',
          name: 'Tech Innovations SARL',
          email: 'contact@techinno.cm',
          phone: '+237 222 123 456',
          bio: 'Startup technologique en pleine croissance cherchant des talents locaux.',
          userType: UserType.employer,
          location: 'Yaoundé, Centre',
          latitude: 3.8500,
          longitude: 11.5021,
          companyName: 'Tech Innovations SARL',
          isVerified: true,
        ),
      ];
      await _saveAllUsers();
    }
  }

  Future<void> _saveAllUsers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'all_users',
      jsonEncode(_allUsers.map((u) => u.toMap()).toList()),
    );
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('current_user');
    if (userJson != null) {
      _currentUser = UserModel.fromMap(jsonDecode(userJson));
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password, UserType userType) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    try {
      final user = _allUsers.firstWhere(
        (u) => u.email.toLowerCase() == email.toLowerCase() && u.userType == userType,
        orElse: () => throw Exception('Utilisateur non trouvé'),
      );

      _currentUser = user;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user', jsonEncode(user.toMap()));

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Email ou mot de passe incorrect';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required UserType userType,
    String? companyName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1000));

    try {
      final exists = _allUsers.any(
        (u) => u.email.toLowerCase() == email.toLowerCase(),
      );

      if (exists) {
        _error = 'Cet email est déjà utilisé';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final newUser = UserModel(
        id: const Uuid().v4(),
        name: name,
        email: email,
        phone: phone,
        userType: userType,
        companyName: companyName,
      );

      _allUsers.add(newUser);
      await _saveAllUsers();

      _currentUser = newUser;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user', jsonEncode(newUser.toMap()));

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Erreur lors de l\'inscription';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> updateProfile({
    String? name,
    String? phone,
    String? bio,
    String? location,
    double? latitude,
    double? longitude,
    List<String>? skills,
    String? profileImagePath,
    String? companyName,
  }) async {
    if (_currentUser == null) return;

    if (name != null) _currentUser!.name = name;
    if (phone != null) _currentUser!.phone = phone;
    if (bio != null) _currentUser!.bio = bio;
    if (location != null) _currentUser!.location = location;
    if (latitude != null) _currentUser!.latitude = latitude;
    if (longitude != null) _currentUser!.longitude = longitude;
    if (skills != null) _currentUser!.skills = skills;
    if (profileImagePath != null) _currentUser!.profileImagePath = profileImagePath;
    if (companyName != null) _currentUser!.companyName = companyName;

    // Update in all users list
    final idx = _allUsers.indexWhere((u) => u.id == _currentUser!.id);
    if (idx >= 0) {
      _allUsers[idx] = _currentUser!;
    }

    await _saveAllUsers();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user', jsonEncode(_currentUser!.toMap()));
    notifyListeners();
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user');
    notifyListeners();
  }

  List<UserModel> getNearbyUsers(double lat, double lng, {double radiusKm = 50}) {
    return _allUsers
        .where((u) =>
            u.id != _currentUser?.id &&
            u.latitude != null &&
            u.longitude != null &&
            _calculateDistance(lat, lng, u.latitude!, u.longitude!) <= radiusKm)
        .toList();
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    // Simple Euclidean approximation for short distances in km
    final dLat = (lat2 - lat1) * 111.32;
    final dLon = (lon2 - lon1) * 111.32 * cos(lat1 * pi / 180);
    return sqrt(dLat * dLat + dLon * dLon);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
