import 'package:travel_buddy/models/user.dart';

class Ride {
  final String id;
  final User host;
  final String from;
  final String to;
  final int capacity;
  final dynamic price;
  final String date;
  final String time; // Added time field
  final String description;
  final List<Request> requests;
  final String createdAt;

  Ride({
    required this.id,
    required this.host,
    required this.from,
    required this.to,
    required this.capacity,
    required this.price,
    required this.date,
    required this.time, // Added time parameter
    required this.description,
    required this.requests,
    required this.createdAt,
  });

  factory Ride.fromJson(Map<String, dynamic> json) {
    List<Request> requestsList = [];
    if (json['requests'] != null) {
      requestsList = List<Request>.from(
        json['requests'].map((request) => Request.fromJson(request)),
      );
    }

    return Ride(
      id: json['_id'],
      host: User.fromJson(json['host']),
      from: json['from'],
      to: json['to'],
      capacity: json['capacity'],
      price: json['price'],
      date: json['date'],
      time: json['time'] ?? '', // Handle null case
      description: json['description'],
      requests: requestsList,
      createdAt: json['createdAt'],
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
      'time': time,
      'description': description,
      'requests': requests.map((request) => request.toJson()).toList(),
      'createdAt': createdAt,
    };
  }
}

class Request {
  final String id;
  final String passenger;
  final String ride;
  final String status;

  Request({
    required this.id,
    required this.passenger,
    required this.ride,
    required this.status,
  });

  factory Request.fromJson(Map<String, dynamic> json) {
    return Request(
      id: json['_id'],
      passenger: json['passenger'],
      ride: json['ride'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'passenger': passenger,
      'ride': ride,
      'status': status,
    };
  }
}
