import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../config/app_config.dart';

/// Map + legend showing the configured office point and allowed radius (Android / iOS).
/// Web and desktop show coordinates only (Maps web needs extra HTML API key setup).
class OfficeLocationMapCard extends StatelessWidget {
  const OfficeLocationMapCard({super.key});

  static bool get _nativeMap =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.business,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Office location',
                    style: theme.textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Check-in is allowed within the blue circle (${AppConfig.officeRadiusMeters.toStringAsFixed(0)} m).',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            if (_nativeMap)
              const _OfficeGoogleMap()
            else
              _FallbackCoords(theme: theme),
          ],
        ),
      ),
    );
  }
}

class _OfficeGoogleMap extends StatefulWidget {
  const _OfficeGoogleMap();

  @override
  State<_OfficeGoogleMap> createState() => _OfficeGoogleMapState();
}

class _OfficeGoogleMapState extends State<_OfficeGoogleMap> {
  static final LatLng _office = LatLng(
    AppConfig.officeLatitude,
    AppConfig.officeLongitude,
  );

  late final Set<Circle> _circles = {
    Circle(
      circleId: const CircleId('office_radius'),
      center: _office,
      radius: AppConfig.officeRadiusMeters,
      fillColor: const Color(0xFF1565C0).withValues(alpha: 0.18),
      strokeColor: const Color(0xFF0D47A1),
      strokeWidth: 2,
    ),
  };

  late final Set<Marker> _markers = {
    Marker(
      markerId: const MarkerId('office'),
      position: _office,
      infoWindow: InfoWindow(
        title: AppConfig.officeMapLabel,
        snippet:
            'Allowed zone: ${AppConfig.officeRadiusMeters.toStringAsFixed(0)} m radius',
      ),
    ),
  };

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 220,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _office,
            zoom: 16.2,
          ),
          circles: _circles,
          markers: _markers,
          mapToolbarEnabled: false,
          zoomControlsEnabled: true,
          compassEnabled: true,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          padding: const EdgeInsets.only(top: 8, right: 8),
        ),
      ),
    );
  }
}

class _FallbackCoords extends StatelessWidget {
  const _FallbackCoords({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Coordinates',
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            SelectableText(
              '${AppConfig.officeLatitude}, ${AppConfig.officeLongitude}',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Radius: ${AppConfig.officeRadiusMeters.toStringAsFixed(0)} m',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (kIsWeb) ...[
              const SizedBox(height: 8),
              Text(
                'Run on Android or iOS to see the interactive Google Map.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
