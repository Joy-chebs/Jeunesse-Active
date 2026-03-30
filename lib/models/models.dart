import 'package:uuid/uuid.dart';

enum UserType { employee, employer }

class UserModel {
  final String id;
  String name;
  String email;
  String phone;
  String bio;
  String? profileImagePath;
  UserType userType;
  String location;
  double? latitude;
  double? longitude;
  List<String> skills;
  double rating;
  int reviewCount;
  bool isVerified;
  DateTime createdAt;
  String? companyName;
  String? companyLogo;

  UserModel({
    String? id,
    required this.name,
    required this.email,
    required this.phone,
    this.bio = '',
    this.profileImagePath,
    required this.userType,
    this.location = '',
    this.latitude,
    this.longitude,
    this.skills = const [],
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isVerified = false,
    DateTime? createdAt,
    this.companyName,
    this.companyLogo,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      bio: map['bio'] ?? '',
      profileImagePath: map['profileImagePath'],
      userType: UserType.values.firstWhere(
        (e) => e.name == map['userType'],
        orElse: () => UserType.employee,
      ),
      location: map['location'] ?? '',
      latitude: map['latitude'],
      longitude: map['longitude'],
      skills: List<String>.from(map['skills'] ?? []),
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      isVerified: map['isVerified'] ?? false,
      createdAt: DateTime.parse(map['createdAt']),
      companyName: map['companyName'],
      companyLogo: map['companyLogo'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'bio': bio,
      'profileImagePath': profileImagePath,
      'userType': userType.name,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'skills': skills,
      'rating': rating,
      'reviewCount': reviewCount,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'companyName': companyName,
      'companyLogo': companyLogo,
    };
  }
}

class ServiceOffer {
  final String id;
  final String userId;
  String title;
  String description;
  String category;
  double price;
  String priceType; // hourly, fixed, daily
  String location;
  double? latitude;
  double? longitude;
  List<String> images;
  bool isAvailable;
  DateTime createdAt;
  int viewCount;

  ServiceOffer({
    String? id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    this.priceType = 'fixed',
    required this.location,
    this.latitude,
    this.longitude,
    this.images = const [],
    this.isAvailable = true,
    DateTime? createdAt,
    this.viewCount = 0,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  factory ServiceOffer.fromMap(Map<String, dynamic> map) {
    return ServiceOffer(
      id: map['id'],
      userId: map['userId'],
      title: map['title'],
      description: map['description'],
      category: map['category'],
      price: (map['price'] ?? 0.0).toDouble(),
      priceType: map['priceType'] ?? 'fixed',
      location: map['location'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      images: List<String>.from(map['images'] ?? []),
      isAvailable: map['isAvailable'] ?? true,
      createdAt: DateTime.parse(map['createdAt']),
      viewCount: map['viewCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'category': category,
      'price': price,
      'priceType': priceType,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'images': images,
      'isAvailable': isAvailable,
      'createdAt': createdAt.toIso8601String(),
      'viewCount': viewCount,
    };
  }
}

class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime timestamp;
  bool isRead;

  MessageModel({
    String? id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    DateTime? timestamp,
    this.isRead = false,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();
}

class ConversationModel {
  final String id;
  final String user1Id;
  final String user2Id;
  final String user2Name;
  final String? user2Image;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;

  ConversationModel({
    String? id,
    required this.user1Id,
    required this.user2Id,
    required this.user2Name,
    this.user2Image,
    required this.lastMessage,
    DateTime? lastMessageTime,
    this.unreadCount = 0,
  })  : id = id ?? const Uuid().v4(),
        lastMessageTime = lastMessageTime ?? DateTime.now();
}

class ServiceCategory {
  final String id;
  final String name;
  final String icon;
  final String color;

  const ServiceCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}

const List<ServiceCategory> kCategories = [
  ServiceCategory(id: '1', name: 'Développement Web', icon: '💻', color: '#3498DB'),
  ServiceCategory(id: '2', name: 'Design Graphique', icon: '🎨', color: '#9B59B6'),
  ServiceCategory(id: '3', name: 'Marketing Digital', icon: '📱', color: '#E91E63'),
  ServiceCategory(id: '4', name: 'Photographie', icon: '📷', color: '#F39C12'),
  ServiceCategory(id: '5', name: 'Traduction', icon: '🌍', color: '#27AE60'),
  ServiceCategory(id: '6', name: 'Comptabilité', icon: '📊', color: '#E74C3C'),
  ServiceCategory(id: '7', name: 'Plomberie', icon: '🔧', color: '#1ABC9C'),
  ServiceCategory(id: '8', name: 'Électricité', icon: '⚡', color: '#F1C40F'),
  ServiceCategory(id: '9', name: 'Enseignement', icon: '📚', color: '#2ECC71'),
  ServiceCategory(id: '10', name: 'Livraison', icon: '🚚', color: '#E67E22'),
  ServiceCategory(id: '11', name: 'Jardinage', icon: '🌱', color: '#16A085'),
  ServiceCategory(id: '12', name: 'Autre', icon: '✨', color: '#7F8C8D'),
];
