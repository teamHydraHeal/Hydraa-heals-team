import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/models/district_model.dart';

class DistrictMapWidget extends StatefulWidget {
  final List<District> districts;
  final bool showRiskPrediction;
  final Function(District) onDistrictSelected;

  const DistrictMapWidget({
    super.key,
    required this.districts,
    required this.showRiskPrediction,
    required this.onDistrictSelected,
  });

  @override
  State<DistrictMapWidget> createState() => _DistrictMapWidgetState();
}

class _DistrictMapWidgetState extends State<DistrictMapWidget> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};

  @override
  void initState() {
    super.initState();
    _createMarkers();
    _createZoneCircles();
  }

  @override
  void didUpdateWidget(DistrictMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.districts != widget.districts || 
        oldWidget.showRiskPrediction != widget.showRiskPrediction) {
      _createMarkers();
      _createZoneCircles();
    }
  }

  void _createMarkers() {
    _markers.clear();
    
    for (final district in widget.districts) {
      final marker = Marker(
        markerId: MarkerId(district.id),
        position: LatLng(district.latitude, district.longitude),
        infoWindow: InfoWindow(
          title: district.name,
          snippet: widget.showRiskPrediction
              ? 'Risk: ${district.riskLevel.name.toUpperCase()}'
              : 'Reports: ${district.activeReports} active, ${district.criticalReports} critical',
        ),
        icon: widget.showRiskPrediction
            ? _getMarkerIcon(district.riskLevel)
            : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        onTap: () => widget.onDistrictSelected(district),
      );
      _markers.add(marker);
    }
  }

  BitmapDescriptor _getMarkerIcon(RiskLevel riskLevel) {
    // In a real app, you would load custom marker icons
    // For now, we'll use default markers with different colors
    switch (riskLevel) {
      case RiskLevel.low:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      case RiskLevel.medium:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
      case RiskLevel.high:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      case RiskLevel.critical:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);
    }
  }

  void _createZoneCircles() {
    _circles.clear();

    if (!widget.showRiskPrediction) {
      for (final district in widget.districts) {
        final bool hasCritical = district.criticalReports > 0;
        final Color reportColor = hasCritical ? Colors.red : Colors.orange;
        final double radius = 6000 + (district.activeReports * 350);

        _circles.add(
          Circle(
            circleId: CircleId('${district.id}_reports'),
            center: LatLng(district.latitude, district.longitude),
            radius: radius,
            fillColor: reportColor.withValues(alpha: 0.2),
            strokeColor: reportColor.withValues(alpha: 0.7),
            strokeWidth: 2,
          ),
        );
      }
      return;
    }

    for (final district in widget.districts) {
      final color = _getRiskColor(district.riskLevel);
      // Radius based on risk: higher risk = bigger zone
      double radius;
      switch (district.riskLevel) {
        case RiskLevel.critical:
          radius = 30000; // 30 km
          break;
        case RiskLevel.high:
          radius = 25000; // 25 km
          break;
        case RiskLevel.medium:
          radius = 20000; // 20 km
          break;
        case RiskLevel.low:
          radius = 15000; // 15 km
          break;
      }

      _circles.add(
        Circle(
          circleId: CircleId(district.id),
          center: LatLng(district.latitude, district.longitude),
          radius: radius,
          fillColor: color.withValues(alpha: 0.25),
          strokeColor: color.withValues(alpha: 0.7),
          strokeWidth: 2,
        ),
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    
    // Fit map to show all districts
    if (widget.districts.isNotEmpty) {
      _fitMapToDistricts();
    }
  }

  void _fitMapToDistricts() {
    if (_mapController == null || widget.districts.isEmpty) return;

    double minLat = widget.districts.first.latitude;
    double maxLat = widget.districts.first.latitude;
    double minLng = widget.districts.first.longitude;
    double maxLng = widget.districts.first.longitude;

    for (final district in widget.districts) {
      minLat = minLat < district.latitude ? minLat : district.latitude;
      maxLat = maxLat > district.latitude ? maxLat : district.latitude;
      minLng = minLng < district.longitude ? minLng : district.longitude;
      maxLng = maxLng > district.longitude ? maxLng : district.longitude;
    }

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat - 0.1, minLng - 0.1),
          northeast: LatLng(maxLat + 0.1, maxLng + 0.1),
        ),
        100.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.districts.isEmpty) {
      return const Center(
        child: Text('No districts available'),
      );
    }

    return Column(
      children: [
        // Map Legend
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: widget.showRiskPrediction
                ? [
                    _buildLegendItem('Low', Colors.green),
                    _buildLegendItem('Medium', Colors.orange),
                    _buildLegendItem('High', Colors.red),
                    _buildLegendItem('Critical', Colors.purple),
                  ]
                : [
                    _buildLegendItem('No reports', Colors.green),
                    _buildLegendItem('Active reports', Colors.orange),
                    _buildLegendItem('Critical present', Colors.red),
                    _buildLegendItem('Report marker', Colors.blue),
                  ],
          ),
        ),
        
        // Map
        Expanded(
          child: GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: LatLng(
                widget.districts.first.latitude,
                widget.districts.first.longitude,
              ),
              zoom: 8.0,
            ),
            markers: _markers,
            circles: _circles,
            mapType: MapType.normal,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
            mapToolbarEnabled: false,
          ),
        ),
        
        // District List
        Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.showRiskPrediction ? 'Risk Prediction' : 'Field Reports',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 70,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.districts.length,
                  itemBuilder: (context, index) {
                    final district = widget.districts[index];
                    return _buildDistrictCard(district);
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildDistrictCard(District district) {
    final color = _getRiskColor(district.riskLevel);
    return GestureDetector(
      onTap: () => widget.onDistrictSelected(district),
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    district.name,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Risk: ${district.riskLevel.name.toUpperCase()}  •  ${district.riskScore.toStringAsFixed(1)}/10',
              style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Color _getRiskColor(RiskLevel riskLevel) {
    switch (riskLevel) {
      case RiskLevel.low:
        return Colors.green;
      case RiskLevel.medium:
        return Colors.orange;
      case RiskLevel.high:
        return Colors.red;
      case RiskLevel.critical:
        return Colors.purple;
    }
  }
}
