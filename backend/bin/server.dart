import "dart:convert";
import "dart:io";

import "package:travell_backend/data/home_data.dart";

const Map<String, String> _tabToTag = {
  "popular": "popular",
  "recommended": "recommended",
  "mostviewed": "mostViewed",
};

Future<void> main() async {
  final port = int.tryParse(Platform.environment["PORT"] ?? "") ?? 4000;
  final server = await HttpServer.bind(InternetAddress.anyIPv4, port);

  stdout.writeln("Travell backend running on http://localhost:$port");

  await for (final request in server) {
    _safeHandleRequest(request);
  }
}

void _safeHandleRequest(HttpRequest request) {
  try {
    _handleRequest(request);
  } catch (_) {
    _sendJson(
      request.response,
      HttpStatus.internalServerError,
      {"success": false, "message": "Internal server error"},
    );
  }
}

void _handleRequest(HttpRequest request) {
  _setCorsHeaders(request.response);

  if (request.method == "OPTIONS") {
    request.response
      ..statusCode = HttpStatus.noContent
      ..close();
    return;
  }

  if (request.method != "GET") {
    _sendJson(
      request.response,
      HttpStatus.methodNotAllowed,
      {"success": false, "message": "Method not allowed"},
    );
    return;
  }

  final path = request.uri.path;

  if (path == "/" || path == "/api") {
    _sendJson(request.response, HttpStatus.ok, {
      "success": true,
      "message": "Travell backend is running",
      "endpoints": [
        "GET /api/health",
        "GET /api/home",
        "GET /api/home/user",
        "GET /api/home/search",
        "GET /api/home/featured-journey",
        "GET /api/home/destinations?tab=all|popular|recommended|mostviewed",
        "GET /api/home/categories",
        "GET /api/home/trip-plans",
        "GET /api/home/travel-tips",
      ],
    });
    return;
  }

  if (path == "/api/health") {
    _sendJson(request.response, HttpStatus.ok, {
      "success": true,
      "service": "travell-backend",
      "status": "ok",
      "timestamp": DateTime.now().toUtc().toIso8601String(),
    });
    return;
  }

  if (path == "/api/home") {
    _sendJson(request.response, HttpStatus.ok, {
      "success": true,
      "data": _homePayload(),
    });
    return;
  }

  if (path == "/api/home/user") {
    _sendJson(request.response, HttpStatus.ok, {
      "success": true,
      "data": homeData["user"],
    });
    return;
  }

  if (path == "/api/home/search") {
    _sendJson(request.response, HttpStatus.ok, {
      "success": true,
      "data": homeData["search"],
    });
    return;
  }

  if (path == "/api/home/featured-journey") {
    final sections = homeData["sections"] as Map<String, dynamic>;
    _sendJson(request.response, HttpStatus.ok, {
      "success": true,
      "data": sections["featuredJourney"],
    });
    return;
  }

  if (path == "/api/home/destinations") {
    final tab =
        (request.uri.queryParameters["tab"] ?? "all").trim().toLowerCase();
    final limitParam = request.uri.queryParameters["limit"];
    final minRatingParam = request.uri.queryParameters["minRating"];
    final limit = _parsePositiveInt(limitParam);
    final minRating = _parseNonNegativeDouble(minRatingParam);

    if (limitParam != null && limit == null) {
      _sendJson(request.response, HttpStatus.badRequest, {
        "success": false,
        "message": "Invalid limit. It must be a positive integer.",
      });
      return;
    }

    if (minRatingParam != null && minRating == null) {
      _sendJson(request.response, HttpStatus.badRequest, {
        "success": false,
        "message": "Invalid minRating. It must be a number >= 0.",
      });
      return;
    }

    final data = _destinationsByTab(
      tab: tab,
      limit: limit,
      minRating: minRating,
    );

    if (data == null) {
      _sendJson(request.response, HttpStatus.badRequest, {
        "success": false,
        "message":
            "Invalid tab. Allowed values: all, popular, recommended, mostviewed",
      });
      return;
    }

    _sendJson(request.response, HttpStatus.ok, {
      "success": true,
      "tab": tab,
      "filters": {
        "limit": limit,
        "minRating": minRating,
      },
      "count": data.length,
      "data": data,
    });
    return;
  }

  if (path == "/api/home/categories") {
    final categories =
        (homeData["sections"] as Map<String, dynamic>)["categories"] as List;
    _sendJson(request.response, HttpStatus.ok, {
      "success": true,
      "count": categories.length,
      "data": categories,
    });
    return;
  }

  if (path == "/api/home/trip-plans") {
    final plans =
        (homeData["sections"] as Map<String, dynamic>)["tripPlans"] as List;
    _sendJson(request.response, HttpStatus.ok, {
      "success": true,
      "count": plans.length,
      "data": plans,
    });
    return;
  }

  if (path == "/api/home/travel-tips") {
    final tips =
        (homeData["sections"] as Map<String, dynamic>)["travelTips"] as List;
    _sendJson(request.response, HttpStatus.ok, {
      "success": true,
      "count": tips.length,
      "data": tips,
    });
    return;
  }

  _sendJson(
    request.response,
    HttpStatus.notFound,
    {"success": false, "message": "Route not found"},
  );
}

Map<String, dynamic> _homePayload() {
  final sections = homeData["sections"] as Map<String, dynamic>;
  return {
    "user": homeData["user"],
    "search": homeData["search"],
    "sections": {
      "featuredJourney": sections["featuredJourney"],
      "exploreTabs": sections["exploreTabs"],
      "destinations": _cleanDestinations(
        sections["destinations"] as List<dynamic>,
      ),
      "tripPlans": sections["tripPlans"],
      "categories": sections["categories"],
      "travelTips": sections["travelTips"],
    },
  };
}

List<Map<String, dynamic>>? _destinationsByTab({
  required String tab,
  int? limit,
  double? minRating,
}) {
  final sections = homeData["sections"] as Map<String, dynamic>;
  final destinations = sections["destinations"] as List<dynamic>;

  List<dynamic> filtered = destinations;

  if (tab != "all") {
    final tag = _tabToTag[tab];
    if (tag == null) return null;

    filtered = filtered
        .where((item) => (item as Map<String, dynamic>)["tags"].contains(tag))
        .toList();
  }

  if (minRating != null) {
    filtered = filtered.where((item) {
      final rating = (item as Map<String, dynamic>)["rating"];
      if (rating is num) return rating.toDouble() >= minRating;
      return false;
    }).toList();
  }

  final cleaned = _cleanDestinations(filtered);
  if (limit == null || limit >= cleaned.length) return cleaned;
  return cleaned.sublist(0, limit);
}

List<Map<String, dynamic>> _cleanDestinations(List<dynamic> destinations) {
  return destinations.map((item) {
    final destination = Map<String, dynamic>.from(item as Map);
    destination.remove("tags");
    return destination;
  }).toList();
}

void _setCorsHeaders(HttpResponse response) {
  response.headers
    ..set("Content-Type", "application/json; charset=utf-8")
    ..set("Access-Control-Allow-Origin", "*")
    ..set("Access-Control-Allow-Methods", "GET,OPTIONS")
    ..set("Access-Control-Allow-Headers", "Content-Type");
}

void _sendJson(HttpResponse response, int statusCode, Object payload) {
  response
    ..statusCode = statusCode
    ..write(jsonEncode(payload))
    ..close();
}

int? _parsePositiveInt(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final parsed = int.tryParse(value);
  if (parsed == null || parsed <= 0) return null;
  return parsed;
}

double? _parseNonNegativeDouble(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final parsed = double.tryParse(value);
  if (parsed == null || parsed < 0) return null;
  return parsed;
}
