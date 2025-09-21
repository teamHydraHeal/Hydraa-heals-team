import 'package:flutter/material.dart';

class IotDataWidget extends StatelessWidget {
  final Map<String, dynamic> iotData;

  const IotDataWidget({
    super.key,
    required this.iotData,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.sensors, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'IoT Sensor Data',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSensorGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorGrid() {
    final sensors = [
      {
        'key': 'water_quality',
        'label': 'Water Quality',
        'value': iotData['water_quality'] ?? 'Unknown',
        'unit': '',
        'icon': Icons.water_drop,
        'color': _getWaterQualityColor(iotData['water_quality']),
      },
      {
        'key': 'temperature',
        'label': 'Temperature',
        'value': iotData['temperature']?.toString() ?? 'N/A',
        'unit': '°C',
        'icon': Icons.thermostat,
        'color': _getTemperatureColor(iotData['temperature']),
      },
      {
        'key': 'humidity',
        'label': 'Humidity',
        'value': iotData['humidity']?.toString() ?? 'N/A',
        'unit': '%',
        'icon': Icons.water,
        'color': _getHumidityColor(iotData['humidity']),
      },
      {
        'key': 'ph_level',
        'label': 'pH Level',
        'value': iotData['ph_level']?.toString() ?? 'N/A',
        'unit': '',
        'icon': Icons.science,
        'color': _getPhColor(iotData['ph_level']),
      },
      {
        'key': 'turbidity',
        'label': 'Turbidity',
        'value': iotData['turbidity']?.toString() ?? 'N/A',
        'unit': 'NTU',
        'icon': Icons.visibility,
        'color': _getTurbidityColor(iotData['turbidity']),
      },
      {
        'key': 'chlorine_level',
        'label': 'Chlorine',
        'value': iotData['chlorine_level']?.toString() ?? 'N/A',
        'unit': 'mg/L',
        'icon': Icons.cleaning_services,
        'color': _getChlorineColor(iotData['chlorine_level']),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: sensors.length,
      itemBuilder: (context, index) {
        final sensor = sensors[index];
        return _buildSensorCard(sensor);
      },
    );
  }

  Widget _buildSensorCard(Map<String, dynamic> sensor) {
    final color = sensor['color'] as Color;
    final value = sensor['value'] as String;
    final unit = sensor['unit'] as String;
    final label = sensor['label'] as String;
    final icon = sensor['icon'] as IconData;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            '$value$unit',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getWaterQualityColor(dynamic quality) {
    if (quality == null) return Colors.grey;
    
    switch (quality.toString().toLowerCase()) {
      case 'good':
        return Colors.green;
      case 'fair':
        return Colors.orange;
      case 'poor':
        return Colors.red;
      case 'critical':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Color _getTemperatureColor(dynamic temperature) {
    if (temperature == null) return Colors.grey;
    
    final temp = double.tryParse(temperature.toString()) ?? 25.0;
    
    if (temp < 20) return Colors.blue;
    if (temp < 25) return Colors.green;
    if (temp < 30) return Colors.orange;
    return Colors.red;
  }

  Color _getHumidityColor(dynamic humidity) {
    if (humidity == null) return Colors.grey;
    
    final hum = double.tryParse(humidity.toString()) ?? 70.0;
    
    if (hum < 60) return Colors.blue;
    if (hum < 80) return Colors.green;
    if (hum < 90) return Colors.orange;
    return Colors.red;
  }

  Color _getPhColor(dynamic ph) {
    if (ph == null) return Colors.grey;
    
    final phValue = double.tryParse(ph.toString()) ?? 7.0;
    
    if (phValue < 6.5 || phValue > 8.5) return Colors.red;
    if (phValue < 7.0 || phValue > 8.0) return Colors.orange;
    return Colors.green;
  }

  Color _getTurbidityColor(dynamic turbidity) {
    if (turbidity == null) return Colors.grey;
    
    final turb = double.tryParse(turbidity.toString()) ?? 1.0;
    
    if (turb < 1) return Colors.green;
    if (turb < 4) return Colors.orange;
    return Colors.red;
  }

  Color _getChlorineColor(dynamic chlorine) {
    if (chlorine == null) return Colors.grey;
    
    final chlor = double.tryParse(chlorine.toString()) ?? 0.5;
    
    if (chlor < 0.2) return Colors.red;
    if (chlor < 0.5) return Colors.orange;
    if (chlor < 4.0) return Colors.green;
    return Colors.red;
  }
}
