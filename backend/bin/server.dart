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
    _handleRequest(request);
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

  if (path == "/api/home/destinations") {
    final tab =
        (request.uri.queryParameters["tab"] ?? "all").trim().toLowerCase();
    final data = _destinationsByTab(tab);

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

List<Map<String, dynamic>>? _destinationsByTab(String tab) {
  final sections = homeData["sections"] as Map<String, dynamic>;
  final destinations = sections["destinations"] as List<dynamic>;

  if (tab == "all") return _cleanDestinations(destinations);

  final tag = _tabToTag[tab];
  if (tag == null) return null;

  final filtered = destinations
      .where((item) => (item as Map<String, dynamic>)["tags"].contains(tag))
      .toList();
  return _cleanDestinations(filtered);
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
