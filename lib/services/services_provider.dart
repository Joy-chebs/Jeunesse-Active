import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class ServicesProvider extends ChangeNotifier {
  List<ServiceOffer> _offers = [];
  bool _isLoading = false;

  List<ServiceOffer> get offers => _offers;
  bool get isLoading => _isLoading;

  ServicesProvider() {
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final offersJson = prefs.getString('service_offers');

    if (offersJson != null) {
      final List decoded = jsonDecode(offersJson);
      _offers = decoded.map((e) => ServiceOffer.fromMap(e)).toList();
    } else {
      _offers = _sampleOffers();
      await _saveOffers();
    }

    _isLoading = false;
    notifyListeners();
  }

  List<ServiceOffer> _sampleOffers() {
    return [
      ServiceOffer(
        id: 'offer1',
        userId: 'sample_emp1',
        title: 'Développement d\'application Flutter',
        description:
            'Je crée des applications mobiles professionnelles pour iOS et Android. Expérience avec Firebase, REST APIs et design UI/UX.',
        category: 'Développement Web',
        price: 150000,
        priceType: 'fixed',
        location: 'Yaoundé, Centre',
        latitude: 3.8667,
        longitude: 11.5167,
        viewCount: 45,
      ),
      ServiceOffer(
        id: 'offer2',
        userId: 'sample_emp2',
        title: 'Création de logo & identité visuelle',
        description:
            'Logo, carte de visite, flyers et tout ce qui concerne votre branding. Livraison en 48h avec révisions illimitées.',
        category: 'Design Graphique',
        price: 50000,
        priceType: 'fixed',
        location: 'Douala, Littoral',
        latitude: 4.0511,
        longitude: 9.7679,
        viewCount: 78,
      ),
      ServiceOffer(
        id: 'offer3',
        userId: 'sample_emp1',
        title: 'Maintenance site web',
        description:
            'Maintenance mensuelle de votre site web, mises à jour de sécurité, sauvegardes et optimisation des performances.',
        category: 'Développement Web',
        price: 25000,
        priceType: 'fixed',
        location: 'Yaoundé, Centre',
        latitude: 3.8480,
        longitude: 11.5021,
        viewCount: 32,
      ),
    ];
  }

  Future<void> _saveOffers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'service_offers',
      jsonEncode(_offers.map((o) => o.toMap()).toList()),
    );
  }

  Future<void> addOffer(ServiceOffer offer) async {
    _offers.insert(0, offer);
    await _saveOffers();
    notifyListeners();
  }

  Future<void> updateOffer(ServiceOffer offer) async {
    final idx = _offers.indexWhere((o) => o.id == offer.id);
    if (idx >= 0) {
      _offers[idx] = offer;
      await _saveOffers();
      notifyListeners();
    }
  }

  Future<void> deleteOffer(String offerId) async {
    _offers.removeWhere((o) => o.id == offerId);
    await _saveOffers();
    notifyListeners();
  }

  List<ServiceOffer> getOffersForUser(String userId) {
    return _offers.where((o) => o.userId == userId).toList();
  }

  List<ServiceOffer> searchOffers(String query, {String? category}) {
    return _offers.where((o) {
      final matchQuery = query.isEmpty ||
          o.title.toLowerCase().contains(query.toLowerCase()) ||
          o.description.toLowerCase().contains(query.toLowerCase());
      final matchCategory = category == null || category.isEmpty || o.category == category;
      return matchQuery && matchCategory && o.isAvailable;
    }).toList();
  }

  void incrementViewCount(String offerId) {
    final idx = _offers.indexWhere((o) => o.id == offerId);
    if (idx >= 0) {
      _offers[idx].viewCount++;
      _saveOffers();
      notifyListeners();
    }
  }
}
