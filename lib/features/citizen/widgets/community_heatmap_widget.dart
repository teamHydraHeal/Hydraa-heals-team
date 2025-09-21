import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/services/map_service.dart';

class CommunityHeatmapWidget extends StatefulWidget {
  const CommunityHeatmapWidget({super.key});

  @override
  State<CommunityHeatmapWidget> createState() => _CommunityHeatmapWidgetState();
}

class _CommunityHeatmapWidgetState extends State<CommunityHeatmapWidget> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  List<HeatmapPoint> _heatmapData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHeatmapData();
  }

  Future<void> _loadHeatmapData() async {
    try {
      final heatmapData = await MapService.getHeatmapData();
      setState(() {
        _heatmapData = heatmapData;
        _createMarkers();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Failed to load heatmap data: $e');
    }
  }

  void _createMarkers() {
    _markers.clear();
    
    for (int i = 0; i < _heatmapData.length; i++) {
      final point = _heatmapData[i];
      final marker = Marker(
        markerId: MarkerId('heatmap_$i'),
        position: LatLng(point.latitude, point.longitude),
        infoWindow: InfoWindow(
          title: 'Health Reports',
          snippet: '${point.reportCount} reports - ${point.severity.name.toUpperCase()}',
        ),
        icon: _getMarkerIcon(point.severity, point.intensity),
      );
      _markers.add(marker);
    }
  }

  BitmapDescriptor _getMarkerIcon(ReportSeverity severity, double intensity) {
    // Use different marker colors based on severity
    switch (severity) {
      case ReportSeverity.low:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      case ReportSeverity.medium:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
      case ReportSeverity.high:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      case ReportSeverity.critical:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    
    // Fit map to show all heatmap points
    if (_heatmapData.isNotEmpty) {
      _fitMapToHeatmapData();
    }
  }

  void _fitMapToHeatmapData() {
    if (_mapController == null || _heatmapData.isEmpty) return;

    double minLat = _heatmapData.first.latitude;
    double maxLat = _heatmapData.first.latitude;
    double minLng = _heatmapData.first.longitude;
    double maxLng = _heatmapData.first.longitude;

    for (final point in _heatmapData) {
      minLat = minLat < point.latitude ? minLat : point.latitude;
      maxLat = maxLat > point.latitude ? maxLat : point.latitude;
      minLng = minLng < point.longitude ? minLng : point.longitude;
      maxLng = maxLng > point.longitude ? maxLng : point.longitude;
    }

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat - 0.05, minLng - 0.05),
          northeast: LatLng(maxLat + 0.05, maxLng + 0.05),
        ),
        100.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(
                  Icons.map,
                  color: Color(0xFF2E7D32),
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Community Health Map',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_heatmapData.length} Areas',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Map Legend
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
          
          const SizedBox(height: 8),
          
          // Map
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: const CameraPosition(
                  target: LatLng(25.5788, 91.8933), // Shillong coordinates
                  zoom: 10.0,
                ),
                markers: _markers,
                mapType: MapType.normal,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: true,
                mapToolbarEnabled: false,
                compassEnabled: true,
                rotateGesturesEnabled: true,
                scrollGesturesEnabled: true,
                tiltGesturesEnabled: true,
                zoomGesturesEnabled: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

