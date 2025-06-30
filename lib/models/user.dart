class User {
  final String id;
  final String firstName;
  final String? lastName;
  final String email;
  final String? phoneNumber;
  final RatingStats ratingStats;
  final bool verifiedEmail;
  final bool isAllowed;
  final bool isAdmin;
  final String createdAt;

  User({
    required this.id,
    required this.firstName,
    this.lastName,
    required this.email,
    this.phoneNumber,
    required this.ratingStats,
    this.verifiedEmail = false,
    this.isAllowed = true,
    this.isAdmin = false,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'],
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'],
      ratingStats: RatingStats.fromJson(json['ratingStats'] ?? {}),
      verifiedEmail: json['verifiedEmail'] ?? false,
      isAllowed: json['isAllowed'] ?? true,
      isAdmin: json['isAdmin'] ?? false,
      createdAt: json['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'ratingStats': ratingStats.toJson(),
      'verifiedEmail': verifiedEmail,
      'isAllowed': isAllowed,
      'isAdmin': isAdmin,
      'createdAt': createdAt,
    };
  }

  String get fullName {
    if (lastName != null && lastName!.isNotEmpty) {
      return '$firstName $lastName';
    }
    return firstName;
  }

  String get initials {
    if (lastName != null && lastName!.isNotEmpty) {
      return '${firstName[0]}${lastName![0]}'.toUpperCase();
    }
    return firstName[0].toUpperCase();
  }
}

class RatingStats {
  final int totalRatings;
  final double? averageRating;

  RatingStats({
    required this.totalRatings,
    this.averageRating,
  });

  factory RatingStats.fromJson(Map<String, dynamic> json) {
    return RatingStats(
      totalRatings: json['totalRatings'] ?? 0,
      averageRating: json['averageRating']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalRatings': totalRatings,
      'averageRating': averageRating,
    };
  }
}
