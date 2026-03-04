import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'src/api/travel_api.dart';

void main() {
  runApp(const ImmersiveDestinationApp());
}

class ImmersiveDestinationApp extends StatelessWidget {
  const ImmersiveDestinationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Immersive Destination',
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const ImmersiveDestinationScreen(),
    );
  }
}

class ImmersiveDestinationScreen extends StatefulWidget {
  const ImmersiveDestinationScreen({super.key});

  @override
  State<ImmersiveDestinationScreen> createState() =>
      _ImmersiveDestinationScreenState();
}

class _ImmersiveDestinationScreenState
    extends State<ImmersiveDestinationScreen> {
  late final TravelApi _travelApi;
  late Future<DestinationData> _destinationFuture;

  @override
  void initState() {
    super.initState();
    _travelApi = TravelApi();
    _destinationFuture = _travelApi.fetchDestinationData();
  }

  void _retryFetch() {
    setState(() {
      _destinationFuture = _travelApi.fetchDestinationData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final heroHeight = size.height * 0.46;
    final cardTop = heroHeight - 34;

    return Scaffold(
      backgroundColor: const Color(0xFFEAF4EE),
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: heroHeight + 20,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/private_jet.jpg',
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.60),
                          Colors.black.withValues(alpha: 0.25),
                          Colors.black.withValues(alpha: 0.05),
                        ],
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _RoundIconButton(
                          icon: Icons.arrow_back_rounded,
                          onTap: () {},
                        ),
                        const Spacer(),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Text(
                                'Select a destination',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w700,
                                  height: 1.08,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            _RoundIconButton(
                              icon: Icons.tune_rounded,
                              size: 36,
                              iconSize: 20,
                              onTap: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            top: cardTop,
            bottom: 46,
            child: FutureBuilder<DestinationData>(
              future: _destinationFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const _LoadingDestinationCard();
                }
                if (snapshot.hasError) {
                  return _ErrorDestinationCard(onRetry: _retryFetch);
                }
                final destinationData = snapshot.data;
                if (destinationData == null) {
                  return _ErrorDestinationCard(onRetry: _retryFetch);
                }
                return _MainDestinationCard(destinationData: destinationData);
              },
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 18,
            child: Center(
              child: Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF4BFF70),
                  border: Border.all(color: Colors.black, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4BFF70).withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.airplanemode_active_rounded,
                  size: 34,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MainDestinationCard extends StatelessWidget {
  const _MainDestinationCard({required this.destinationData});

  final DestinationData destinationData;

  @override
  Widget build(BuildContext context) {
    final resident = destinationData.resident;
    final avatarAsset = resident.avatarAsset.isNotEmpty
        ? resident.avatarAsset
        : 'assets/images/private_jet.jpg';
    final flights = destinationData.flights;

    return _CardShell(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF64E58E).withValues(alpha: 0.35),
                        Colors.white.withValues(alpha: 0.60),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.75),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        resident.role.toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          letterSpacing: 1.0,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF41D96A),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          image: DecorationImage(
                            image: AssetImage(avatarAsset),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        resident.name,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF7C8D86),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 88),
              child: flights.isEmpty
                  ? Center(
                      child: Text(
                        'No flights available',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF9CA7A2),
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: flights.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 22),
                      itemBuilder: (context, index) {
                        final flight = flights[index];
                        return _FlightRow(
                          time: flight.time,
                          price: flight.formattedPrice,
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingDestinationCard extends StatelessWidget {
  const _LoadingDestinationCard();

  @override
  Widget build(BuildContext context) {
    return const _CardShell(
      child: Center(child: CircularProgressIndicator(color: Color(0xFF41D96A))),
    );
  }
}

class _ErrorDestinationCard extends StatelessWidget {
  const _ErrorDestinationCard({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Could not load destination data',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF9CA7A2),
                ),
              ),
              const SizedBox(height: 14),
              FilledButton(
                onPressed: onRetry,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF41D96A),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FlightRow extends StatelessWidget {
  const _FlightRow({required this.time, required this.price});

  final String time;
  final String price;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          time,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF9CA7A2),
          ),
        ),
        const Spacer(),
        Text(
          price,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFCED4D0),
          ),
        ),
      ],
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF183028).withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.onTap,
    this.size = 40,
    this.iconSize = 22,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: size / 2,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.2),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.35),
            width: 1.2,
          ),
        ),
        child: Icon(icon, color: Colors.white, size: iconSize),
      ),
    );
  }
}
