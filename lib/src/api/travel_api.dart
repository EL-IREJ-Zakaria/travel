import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Resident {
  const Resident({
    required this.id,
    required this.name,
    required this.role,
    required this.avatarAsset,
  });

  final String id;
  final String name;
  final String role;
  final String avatarAsset;

  factory Resident.fromJson(Map<String, dynamic> json) {
    return Resident(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? '',
      avatarAsset: json['avatarAsset'] as String? ?? '',
    );
  }
}

class FlightOffer {
  const FlightOffer({
    required this.id,
    required this.time,
    required this.priceAmount,
    required this.currency,
    required this.origin,
    required this.destination,
  });

  final String id;
  final String time;
  final num priceAmount;
  final String currency;
  final String origin;
  final String destination;

  String get formattedPrice => '$priceAmount $currency';

  factory FlightOffer.fromJson(Map<String, dynamic> json) {
    return FlightOffer(
      id: json['id'] as String? ?? '',
      time: json['time'] as String? ?? '',
      priceAmount: json['priceAmount'] as num? ?? 0,
      currency: json['currency'] as String? ?? 'USD',
      origin: json['origin'] as String? ?? '',
      destination: json['destination'] as String? ?? '',
    );
  }
}

class DestinationData {
  const DestinationData({required this.resident, required this.flights});

  final Resident resident;
  final List<FlightOffer> flights;

  factory DestinationData.fromJson(Map<String, dynamic> json) {
    final residentJson = json['resident'] as Map<String, dynamic>? ?? {};
    final flightsJson = json['flights'] as List<dynamic>? ?? [];

    return DestinationData(
      resident: Resident.fromJson(residentJson),
      flights: flightsJson
          .whereType<Map<String, dynamic>>()
          .map(FlightOffer.fromJson)
          .toList(),
    );
  }
}

class TravelApi {
  TravelApi({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = _normalizedBaseUrl(baseUrl ?? _defaultBaseUrl);

  final http.Client _client;
  final String _baseUrl;

  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static String get _defaultBaseUrl {
    if (_configuredBaseUrl.isNotEmpty) {
      return _configuredBaseUrl;
    }
    if (kIsWeb) {
      return 'http://localhost:8080';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080';
    }
    return 'http://localhost:8080';
  }

  static String _normalizedBaseUrl(String baseUrl) {
    if (baseUrl.endsWith('/')) {
      return baseUrl.substring(0, baseUrl.length - 1);
    }
    return baseUrl;
  }

  Future<DestinationData> fetchDestinationData() async {
    final uri = Uri.parse('$_baseUrl/api/destination');
    final response = await _client.get(
      uri,
      headers: const {'accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw StateError(
        'Backend request failed with status ${response.statusCode}',
      );
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    return DestinationData.fromJson(payload);
  }
}
