import 'package:travel_buddy/models/user.dart';

class Ride {
  final String id;
  final User host;
  final String from;
  final String to;
  final int capacity;
  final double? price;
  final String date;
  final int? phoneNo;
  final String description;
  final List<RideRequest> requests;
  final String createdAt;

  Ride({
    required this.id,
    required this.host,
    required this.from,
    required this.to,
    required this.capacity,
    this.price,
    required this.date,
    this.phoneNo,
    required this.description,
    required this.requests,
    required this.createdAt,
  });

  factory Ride.fromJson(Map<String, dynamic> json) {
    List<RideRequest> requestsList = [];
    if (json['requests'] != null) {
      requestsList = List<RideRequest>.from(
        json['requests'].map((request) => RideRequest.fromJson(request)),
      );
    }

    return Ride(
      id: json['_id'] ?? '',
      host: User.fromJson(json['host'] ?? {}),
      from: json['from'] ?? '',
      to: json['to'] ?? '',
      capacity: json['capacity'] ?? 0,
      price: json['price']?.toDouble(),
      date: json['date'] ?? '',
      phoneNo: json['phoneNo'],
      description: json['description'] ?? '',
      requests: requestsList,
      createdAt: json['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'host': host.toJson(),
      'from': from,
      'to': to,
      'capacity': capacity,
      'price': price,
      'date': date,
      'phoneNo': phoneNo,
      'description': description,
      'requests': requests.map((request) => request.toJson()).toList(),
      'createdAt': createdAt,
    };
  }

  int get approvedRequestsCount {
    return requests.where((req) => req.status == 'approved').length;
  }

  int get availableSeats {
    return capacity - approvedRequestsCount;
  }

  bool get isFull {
    return availableSeats <= 0;
  }

  DateTime? get dateTime {
    try {
      return DateTime.parse(date);
    } catch (e) {
      return null;
    }
  }
}

class RideRequest {
  final String id;
  final User? passenger;
  final String? ride;
  final String status;
  final String createdAt;

  RideRequest({
    required this.id,
    this.passenger,
    this.ride,
    required this.status,
    required this.createdAt,
  });

  factory RideRequest.fromJson(Map<String, dynamic> json) {
    return RideRequest(
      id: json['_id'] ?? '',
      passenger:
          json['passenger'] != null ? User.fromJson(json['passenger']) : null,
      ride: json['ride'] is String ? json['ride'] : json['ride']?['_id'],
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'passenger': passenger?.toJson(),
      'ride': ride,
      'status': status,
      'createdAt': createdAt,
    };
  }
}

class UserRideRequest {
  final String id;
  final Ride ride;
  final String status;
  final String createdAt;

  UserRideRequest({
    required this.id,
    required this.ride,
    required this.status,
    required this.createdAt,
  });

  factory UserRideRequest.fromJson(Map<String, dynamic> json) {
    return UserRideRequest(
      id: json['_id'] ?? '',
      ride: Ride.fromJson(json['ride'] ?? {}),
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] ?? '',
    );
  }
}
