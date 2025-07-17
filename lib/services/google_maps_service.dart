import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:travel_buddy/config/api_config.dart';

class GoogleMapsService {
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api';

  static Future<List<PlacePrediction>> getPlacePredictions(
    String input, {
    bool restrictToCountry = false,
    String countryCode = 'in',
    List<String>? types,
  }) async {
    if (input.isEmpty) return [];

    try {
      String url =
          '$_baseUrl/place/autocomplete/json'
          '?input=${Uri.encodeComponent(input)}'
          '&key=${ApiConfig.googleMapsApiKey}';

      if (types != null && types.isNotEmpty) {
        url += '&types=${types.join('|')}';
      }

      if (restrictToCountry && countryCode.isNotEmpty) {
        url += '&components=country:$countryCode';
      }

      final response = await http.get(Uri.parse(url));
      final data = jsonDecode(response.body);

      if (data['status'] == 'OK') {
        final predictions = data['predictions'] as List;
        return predictions
            .map((prediction) => PlacePrediction.fromJson(prediction))
            .toList();
      }
      return [];
    } catch (error) {
      print('Error getting place predictions: $error');
      return [];
    }
  }

  static Future<List<PlacePrediction>> searchPlaces(
    String query, {
    String? location,
    int? radius,
    List<String>? types,
    String? language,
  }) async {
    if (query.isEmpty) return [];

    try {
      String url =
          '$_baseUrl/place/textsearch/json'
          '?query=${Uri.encodeComponent(query)}'
          '&key=${ApiConfig.googleMapsApiKey}';

      if (location != null) {
        url += '&location=$location';
      }
      if (radius != null) {
        url += '&radius=$radius';
      }
      if (types != null && types.isNotEmpty) {
        url += '&type=${types.first}';
      }
      if (language != null) {
        url += '&language=$language';
      }

      final response = await http.get(Uri.parse(url));
      final data = jsonDecode(response.body);

      if (data['status'] == 'OK') {
        final results = data['results'] as List;
        return results
            .map((result) => PlacePrediction.fromTextSearch(result))
            .toList();
      }
      return [];
    } catch (error) {
      print('Error searching places: $error');
      return [];
    }
  }

  static Future<PlaceDetails?> getPlaceDetails(String placeId) async {
    try {
      final url =
          '$_baseUrl/place/details/json'
          '?place_id=$placeId'
          '&key=${ApiConfig.googleMapsApiKey}'
          '&fields=geometry,formatted_address,name,address_components,types';

      final response = await http.get(Uri.parse(url));
      final data = jsonDecode(response.body);

      if (data['status'] == 'OK') {
        return PlaceDetails.fromJson(data['result']);
      }
      return null;
    } catch (error) {
      print('Error getting place details: $error');
      return null;
    }
  }

  static Future<LatLng?> geocodeAddress(String address) async {
    try {
      final url =
          '$_baseUrl/geocode/json'
          '?address=${Uri.encodeComponent(address)}'
          '&key=${ApiConfig.googleMapsApiKey}';

      final response = await http.get(Uri.parse(url));
      final data = jsonDecode(response.body);

      if (data['status'] == 'OK' && data['results'].isNotEmpty) {
        final location = data['results'][0]['geometry']['location'];
        return LatLng(location['lat'], location['lng']);
      }
      return null;
    } catch (error) {
      print('Error geocoding address: $error');
      return null;
    }
  }

  static Future<DirectionsResult?> getDirections(
    LatLng origin,
    LatLng destination,
  ) async {
    try {
      final url =
          '$_baseUrl/directions/json'
          '?origin=${origin.latitude},${origin.longitude}'
          '&destination=${destination.latitude},${destination.longitude}'
          '&key=${ApiConfig.googleMapsApiKey}';

      final response = await http.get(Uri.parse(url));
      final data = jsonDecode(response.body);

      if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
        return DirectionsResult.fromJson(data['routes'][0]);
      }
      return null;
    } catch (error) {
      print('Error getting directions: $error');
      return null;
    }
  }
}

class PlacePrediction {
  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;
  final List<String> types;

  PlacePrediction({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
    required this.types,
  });

  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    return PlacePrediction(
      placeId: json['place_id'] ?? '',
      description: json['description'] ?? '',
      mainText: json['structured_formatting']?['main_text'] ?? '',
      secondaryText: json['structured_formatting']?['secondary_text'] ?? '',
      types: List<String>.from(json['types'] ?? []),
    );
  }

  factory PlacePrediction.fromTextSearch(Map<String, dynamic> json) {
    return PlacePrediction(
      placeId: json['place_id'] ?? '',
      description: json['formatted_address'] ?? json['name'] ?? '',
      mainText: json['name'] ?? '',
      secondaryText: json['formatted_address'] ?? '',
      types: List<String>.from(json['types'] ?? []),
    );
  }

  IconData get icon {
    if (types.contains('airport')) return Icons.flight;
    if (types.contains('train_station')) return Icons.train;
    if (types.contains('bus_station')) return Icons.directions_bus;
    if (types.contains('university')) return Icons.school;
    if (types.contains('hospital')) return Icons.local_hospital;
    if (types.contains('shopping_mall')) return Icons.shopping_cart;
    if (types.contains('restaurant')) return Icons.restaurant;
    if (types.contains('gas_station')) return Icons.local_gas_station;
    return Icons.location_on;
  }
}

class PlaceDetails {
  final String formattedAddress;
  final String name;
  final LatLng location;
  final List<AddressComponent> addressComponents;
  final List<String> types;

  PlaceDetails({
    required this.formattedAddress,
    required this.name,
    required this.location,
    required this.addressComponents,
    required this.types,
  });

  factory PlaceDetails.fromJson(Map<String, dynamic> json) {
    final geometry = json['geometry']['location'];
    final addressComponentsList = json['address_components'] as List? ?? [];

    return PlaceDetails(
      formattedAddress: json['formatted_address'] ?? '',
      name: json['name'] ?? '',
      location: LatLng(geometry['lat'], geometry['lng']),
      addressComponents:
          addressComponentsList
              .map((component) => AddressComponent.fromJson(component))
              .toList(),
      types: List<String>.from(json['types'] ?? []),
    );
  }
}

class AddressComponent {
  final String longName;
  final String shortName;
  final List<String> types;

  AddressComponent({
    required this.longName,
    required this.shortName,
    required this.types,
  });

  factory AddressComponent.fromJson(Map<String, dynamic> json) {
    return AddressComponent(
      longName: json['long_name'] ?? '',
      shortName: json['short_name'] ?? '',
      types: List<String>.from(json['types'] ?? []),
    );
  }
}

class LatLng {
  final double latitude;
  final double longitude;

  LatLng(this.latitude, this.longitude);
}

class DirectionsResult {
  final String polyline;
  final String distance;
  final String duration;
  final List<LatLng> points;

  DirectionsResult({
    required this.polyline,
    required this.distance,
    required this.duration,
    required this.points,
  });

  factory DirectionsResult.fromJson(Map<String, dynamic> json) {
    final leg = json['legs'][0];
    final polyline = json['overview_polyline']['points'];

    return DirectionsResult(
      polyline: polyline,
      distance: leg['distance']['text'],
      duration: leg['duration']['text'],
      points: _decodePolyline(polyline),
    );
  }

  static List<LatLng> _decodePolyline(String polyline) {
    List<LatLng> points = [];
    int index = 0;
    int len = polyline.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }
}
