import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:travel_buddy/config/api_config.dart';

class GoogleMapsService {
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api';

  // Get place predictions for autocomplete
  static Future<List<PlacePrediction>> getPlacePredictions(String input) async {
    if (input.isEmpty) return [];

    try {
      final url = '$_baseUrl/place/autocomplete/json'
          '?input=${Uri.encodeComponent(input)}'
          '&key=${ApiConfig.googleMapsApiKey}'
          '&types=geocode'
          '&components=country:in'; // Restrict to India

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

  // Get place details by place ID
  static Future<PlaceDetails?> getPlaceDetails(String placeId) async {
    try {
      final url = '$_baseUrl/place/details/json'
          '?place_id=$placeId'
          '&key=${ApiConfig.googleMapsApiKey}'
          '&fields=geometry,formatted_address,name';

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

  // Geocode an address to get coordinates
  static Future<LatLng?> geocodeAddress(String address) async {
    try {
      final url = '$_baseUrl/geocode/json'
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

  // Get directions between two points
  static Future<DirectionsResult?> getDirections(
    LatLng origin,
    LatLng destination,
  ) async {
    try {
      final url = '$_baseUrl/directions/json'
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

  PlacePrediction({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
  });

  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    return PlacePrediction(
      placeId: json['place_id'],
      description: json['description'],
      mainText: json['structured_formatting']['main_text'],
      secondaryText: json['structured_formatting']['secondary_text'] ?? '',
    );
  }
}

class PlaceDetails {
  final String formattedAddress;
  final String name;
  final LatLng location;

  PlaceDetails({
    required this.formattedAddress,
    required this.name,
    required this.location,
  });

  factory PlaceDetails.fromJson(Map<String, dynamic> json) {
    final geometry = json['geometry']['location'];
    return PlaceDetails(
      formattedAddress: json['formatted_address'],
      name: json['name'],
      location: LatLng(geometry['lat'], geometry['lng']),
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
