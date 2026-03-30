# JeunesseActive 🚀

**La plateforme des jeunes entrepreneurs africains**

Application mobile Flutter complète permettant aux jeunes entrepreneurs de proposer leurs services, créer un profil professionnel et se connecter avec des clients grâce au GPS intégré.

---

## 📱 Fonctionnalités

### Pour les Prestataires (Employés)
- ✅ Inscription / Connexion avec compte Prestataire
- ✅ Profil professionnel avec photo (caméra ou galerie)
- ✅ Publication d'offres de services
- ✅ Gestion des compétences
- ✅ Statistiques (vues, avis, note)
- ✅ Messagerie directe avec les clients

### Pour les Employeurs
- ✅ Inscription / Connexion avec compte Employeur
- ✅ Profil entreprise
- ✅ Exploration des offres de services
- ✅ Recherche par catégorie
- ✅ Carte GPS pour localiser les prestataires proches
- ✅ Messagerie directe avec les prestataires

### GPS & Carte
- ✅ Localisation GPS en temps réel
- ✅ Carte interactive (OpenStreetMap)
- ✅ Marqueurs colorés (Prestataires = orange, Employeurs = vert)
- ✅ Fiche info au clic sur un marqueur
- ✅ Bouton centrage sur position actuelle

### Autres
- ✅ Écran de démarrage animé
- ✅ Page d'accueil avec sélection du rôle
- ✅ Thème cohérent (bleu marine + orange)
- ✅ Typographie Google Fonts (Poppins)
- ✅ Stockage local avec SharedPreferences
- ✅ Données de démo pré-chargées

---

## 🛠️ Technologies utilisées

| Technologie | Usage |
|-------------|-------|
| Flutter 3.x | Framework mobile |
| Dart 3.x | Langage de programmation |
| Provider | Gestion d'état |
| flutter_map + latlong2 | Carte GPS (OpenStreetMap) |
| geolocator | Accès GPS du téléphone |
| image_picker | Photo de profil (caméra/galerie) |
| google_fonts | Typographie Poppins |
| shared_preferences | Stockage local |
| uuid | Génération d'identifiants uniques |
| timeago | Affichage des dates relatives |

---

## 🚀 Installation et lancement

### Prérequis
- Flutter SDK ≥ 3.0.0 installé ([flutter.dev](https://flutter.dev/docs/get-started/install))
- Android Studio ou VS Code avec extension Flutter
- Un émulateur Android/iOS ou un appareil physique

### Étapes

```bash
# 1. Aller dans le dossier du projet
cd jeunesseactive

# 2. Récupérer les dépendances
flutter pub get

# 3. Lancer l'application
flutter run
```

### Pour Android spécifiquement
```bash
# Vérifier les appareils disponibles
flutter devices

# Lancer sur Android
flutter run -d android

# Créer un APK
flutter build apk --release
# L'APK sera dans: build/app/outputs/flutter-apk/app-release.apk
```

### Pour iOS (Mac uniquement)
```bash
flutter run -d ios
```

---

## 📂 Structure du projet

```
lib/
├── main.dart                    # Point d'entrée + routage
├── theme/
│   └── app_theme.dart           # Thème, couleurs, styles
├── models/
│   └── models.dart              # Modèles de données
├── services/
│   ├── auth_provider.dart       # Authentification + utilisateurs
│   ├── services_provider.dart   # Offres de services
│   └── messages_provider.dart   # Messagerie
├── widgets/
│   └── common_widgets.dart      # Composants réutilisables
└── screens/
    ├── splash_screen.dart       # Écran de démarrage
    ├── welcome_screen.dart      # Page d'accueil (choix du rôle)
    ├── login_screen.dart        # Connexion / Inscription
    ├── home_screen.dart         # Navigation principale (bottom bar)
    ├── dashboard_screen.dart    # Tableau de bord
    ├── explore_screen.dart      # Exploration des services
    ├── map_screen.dart          # Carte GPS interactive
    ├── messages_screen.dart     # Messagerie + Chat
    ├── profile_screen.dart      # Profil + Modification + Upload photo
    ├── add_service_screen.dart  # Publier une offre
    └── service_detail_screen.dart # Détail d'une offre
```

---

## 🔑 Comptes de démonstration

| Rôle | Email | Mot de passe |
|------|-------|--------------|
| Prestataire | jpmbarga@email.com | 123456 |
| Employeur | contact@techinno.cm | 123456 |

> Les identifiants sont pré-remplis automatiquement sur l'écran de connexion.

---

## 📸 Permissions requises

### Android
- `ACCESS_FINE_LOCATION` - GPS précis
- `ACCESS_COARSE_LOCATION` - Localisation approximative
- `CAMERA` - Photo de profil
- `READ_MEDIA_IMAGES` - Accès galerie photos
- `INTERNET` - Chargement de la carte

### iOS
- `NSLocationWhenInUseUsageDescription` - GPS
- `NSCameraUsageDescription` - Caméra
- `NSPhotoLibraryUsageDescription` - Galerie

---

## 🎨 Design System

| Élément | Valeur |
|---------|--------|
| Couleur primaire | `#0A3D62` (Bleu marine) |
| Couleur accent | `#FF6B35` (Orange) |
| Succès | `#27AE60` |
| Avertissement | `#F39C12` |
| Erreur | `#E74C3C` |
| Police | Poppins (Google Fonts) |
| Coins arrondis | 12–20px |

---

## 🔧 Personnalisation

Pour changer les couleurs de l'application, modifiez `lib/theme/app_theme.dart` :
```dart
static const Color primary = Color(0xFF0A3D62); // Votre couleur principale
static const Color accent  = Color(0xFFFF6B35);  // Votre couleur d'accent
```

---

## 📦 Build APK de production

```bash
# Générer le keystore (une seule fois)
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload

# Build APK
flutter build apk --release

# Build App Bundle (recommandé pour Play Store)
flutter build appbundle --release
```

---

Développé avec ❤️ pour les jeunes entrepreneurs d'Afrique 🌍
