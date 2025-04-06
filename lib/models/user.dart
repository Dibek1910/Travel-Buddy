class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final RatingStats ratingStats;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.ratingStats,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      ratingStats: RatingStats.fromJson(json['ratingStats']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'ratingStats': ratingStats.toJson(),
    };
  }
}

class RatingStats {
  final int totalRatings;
  final double averageRating;

  RatingStats({
    required this.totalRatings,
    required this.averageRating,
  });

  factory RatingStats.fromJson(Map<String, dynamic> json) {
    return RatingStats(
      totalRatings: json['totalRatings'],
      averageRating: json['averageRating'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalRatings': totalRatings,
      'averageRating': averageRating,
    };
  }
}
