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

  @override
  void initState() {
    super.initState();
    _createMarkers();
  }

  @override
  void didUpdateWidget(DistrictMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.districts != widget.districts || 
        oldWidget.showRiskPrediction != widget.showRiskPrediction) {
      _createMarkers();
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
          snippet: 'Risk: ${district.riskLevel.name.toUpperCase()}',
        ),
        icon: _getMarkerIcon(district.riskLevel),
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
            children: [
              _buildLegendItem('Low', Colors.green),
              _buildLegendItem('Medium', Colors.orange),
              _buildLegendItem('High', Colors.red),
              _buildLegendItem('Critical', Colors.purple),
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
            mapType: MapType.normal,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
            mapToolbarEnabled: false,
          ),
        ),
        
        // District List
        Container(
          height: 120,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.showRiskPrediction ? 'Risk Prediction' : 'Field Reports',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
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
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        child: InkWell(
          onTap: () => widget.onDistrictSelected(district),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _getRiskColor(district.riskLevel),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        district.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Risk: ${district.riskLevel.name.toUpperCase()}',
                  style: TextStyle(
                    color: _getRiskColor(district.riskLevel),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Score: ${district.riskScore.toStringAsFixed(1)}/10',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Reports: ${district.activeReports}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
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
