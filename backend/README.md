# Travell Backend (Home API)

## Run

```bash
cd backend
dart run bin/server.dart
```

Server default: `http://localhost:4000`

You can override port:

```bash
PORT=5000 dart run bin/server.dart
```

## Endpoints

- `GET /api/health`
- `GET /api/home`
- `GET /api/home/user`
- `GET /api/home/search`
- `GET /api/home/featured-journey`
- `GET /api/home/destinations?tab=all|popular|recommended|mostviewed&limit=3&minRating=4.8`
- `GET /api/home/categories`
- `GET /api/home/trip-plans`
- `GET /api/home/travel-tips`
