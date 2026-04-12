import 'dart:math';

import '../models/health_report_model.dart';

class AIAnalyticsService {
  
  // Calculate district risk scores using XGBoost-like algorithm
  static Future<Map<String, double>> calculateDistrictRiskScores(
    List<HealthReport> reports,
    Map<String, dynamic> iotData,
  ) async {
    try {
      // Mock AI calculation - in real app, this would call ML model
      await Future.delayed(const Duration(seconds: 2));
      
      final riskScores = <String, double>{};
      
      // Group reports by district
      final districtReports = <String, List<HealthReport>>{};
      for (final report in reports) {
        final district = _extractDistrictFromLocation(report.location);
        districtReports.putIfAbsent(district, () => []).add(report);
      }
      
      // Calculate risk score for each district
      for (final entry in districtReports.entries) {
        final district = entry.key;
        final districtReportsList = entry.value;
        
        double riskScore = 0.0;
        
        // Factor 1: Number of reports (weight: 0.3)
        final reportCount = districtReportsList.length;
        riskScore += (reportCount / 50.0) * 0.3; // Normalize to 0-1
        
        // Factor 2: Severity of reports (weight: 0.4)
        final severityScore = _calculateSeverityScore(districtReportsList);
        riskScore += severityScore * 0.4;
        
        // Factor 3: Recent activity (weight: 0.2)
        final recencyScore = _calculateRecencyScore(districtReportsList);
        riskScore += recencyScore * 0.2;
        
        // Factor 4: IoT data (weight: 0.1)
        final iotScore = _calculateIotScore(iotData);
        riskScore += iotScore * 0.1;
        
        // Add some randomness for demo
        riskScore += (Random().nextDouble() - 0.5) * 0.1;
        
        // Clamp between 0 and 1
        riskScore = riskScore.clamp(0.0, 1.0);
        
        riskScores[district] = riskScore;
      }
      
      return riskScores;
    } catch (e) {
      print('Failed to calculate risk scores: $e');
      return {};
    }
  }
  
  // Analyze health report for entity extraction and triage
  static Future<Map<String, dynamic>> analyzeHealthReport(HealthReport report) async {
    try {
      // Mock AI analysis - in real app, this would call NLP model
      await Future.delayed(const Duration(seconds: 1));
      
      final analysis = <String, dynamic>{};
      
      // Extract entities from description
      final entities = _extractEntities(report.description);
      analysis['entities'] = entities;
      
      // Generate triage response
      final triageResponse = _generateTriageResponse(report, entities);
      analysis['triage_response'] = triageResponse;
      
      // Calculate priority score
      final priorityScore = _calculatePriorityScore(report, entities);
      analysis['priority_score'] = priorityScore;
      
      // Generate AI summary
      final summary = _generateAISummary(report, entities);
      analysis['ai_summary'] = summary;
      
      return analysis;
    } catch (e) {
      print('Failed to analyze health report: $e');
      return {};
    }
  }
  
  // Generate action plan for health officials
  static Future<Map<String, dynamic>> generateActionPlan(
    String districtId,
    List<HealthReport> reports,
    Map<String, dynamic> iotData,
  ) async {
    try {
      // Mock AI action plan generation
      await Future.delayed(const Duration(seconds: 3));
      
      final actionPlan = <String, dynamic>{};
      
      // Analyze situation
      final situationAnalysis = _analyzeSituation(reports, iotData);
      actionPlan['situation_analysis'] = situationAnalysis;
      
      // Generate action items
      final actionItems = _generateActionItems(situationAnalysis);
      actionPlan['action_items'] = actionItems;
      
      // Estimate resource requirements
      final resourceRequirements = _estimateResourceRequirements(actionItems);
      actionPlan['resource_requirements'] = resourceRequirements;
      
      // Generate timeline
      final timeline = _generateTimeline(actionItems);
      actionPlan['timeline'] = timeline;
      
      // Calculate success probability
      final successProbability = _calculateSuccessProbability(actionItems, resourceRequirements);
      actionPlan['success_probability'] = successProbability;
      
      return actionPlan;
    } catch (e) {
      print('Failed to generate action plan: $e');
      return {};
    }
  }
  
  // Generate community broadcast message
  static Future<Map<String, dynamic>> generateBroadcastMessage(
    String topic,
    String language,
    String severity,
  ) async {
    try {
      // Mock AI message generation
      await Future.delayed(const Duration(seconds: 2));
      
      final broadcast = <String, dynamic>{};
      
      // Generate message in requested language
      final message = _generateMessage(topic, language, severity);
      broadcast['message'] = message;
      
      // Generate translations
      final translations = _generateTranslations(message, language);
      broadcast['translations'] = translations;
      
      // Generate visual elements
      final visualElements = _generateVisualElements(topic, severity);
      broadcast['visual_elements'] = visualElements;
      
      // Calculate reach estimate
      final reachEstimate = _calculateReachEstimate(severity);
      broadcast['reach_estimate'] = reachEstimate;
      
      return broadcast;
    } catch (e) {
      print('Failed to generate broadcast message: $e');
      return {};
    }
  }
  
  // Predict disease outbreak probability
  static Future<Map<String, dynamic>> predictDiseaseOutbreak(
    String districtId,
    List<HealthReport> recentReports,
    Map<String, dynamic> environmentalData,
  ) async {
    try {
      // Mock outbreak prediction
      await Future.delayed(const Duration(seconds: 2));
      
      final prediction = <String, dynamic>{};
      
      // Calculate outbreak probability
      final probability = _calculateOutbreakProbability(recentReports, environmentalData);
      prediction['outbreak_probability'] = probability;
      
      // Identify potential diseases
      final potentialDiseases = _identifyPotentialDiseases(recentReports);
      prediction['potential_diseases'] = potentialDiseases;
      
      // Generate prevention recommendations
      final preventionRecommendations = _generatePreventionRecommendations(potentialDiseases);
      prediction['prevention_recommendations'] = preventionRecommendations;
      
      // Estimate timeline
      final timeline = _estimateOutbreakTimeline(probability, potentialDiseases);
      prediction['timeline'] = timeline;
      
      return prediction;
    } catch (e) {
      print('Failed to predict disease outbreak: $e');
      return {};
    }
  }
  
  // Helper methods
  static String _extractDistrictFromLocation(String location) {
    // Simple extraction - in real app, this would use geocoding
    if (location.toLowerCase().contains('shillong')) return 'East Khasi Hills';
    if (location.toLowerCase().contains('nongstoin')) return 'West Khasi Hills';
    if (location.toLowerCase().contains('nongpoh')) return 'Ri Bhoi';
    if (location.toLowerCase().contains('jowai')) return 'Jaintia Hills';
    if (location.toLowerCase().contains('tura')) return 'Garo Hills';
    return 'Unknown District';
  }
  
  static double _calculateSeverityScore(List<HealthReport> reports) {
    double totalScore = 0.0;
    for (final report in reports) {
      switch (report.severity) {
        case ReportSeverity.low:
          totalScore += 0.2;
          break;
        case ReportSeverity.medium:
          totalScore += 0.5;
          break;
        case ReportSeverity.high:
          totalScore += 0.8;
          break;
        case ReportSeverity.critical:
          totalScore += 1.0;
          break;
      }
    }
    return (totalScore / reports.length).clamp(0.0, 1.0);
  }
  
  static double _calculateRecencyScore(List<HealthReport> reports) {
    final now = DateTime.now();
    double totalScore = 0.0;
    
    for (final report in reports) {
      final hoursSinceReport = now.difference(report.reportedAt).inHours;
      // More recent reports have higher scores
      final recencyScore = (24.0 - hoursSinceReport.clamp(0, 24)) / 24.0;
      totalScore += recencyScore.clamp(0.0, 1.0);
    }
    
    return (totalScore / reports.length).clamp(0.0, 1.0);
  }
  
  static double _calculateIotScore(Map<String, dynamic> iotData) {
    double score = 0.5; // Base score
    
    // Water quality status from live API or mock
    final wq = iotData['water_quality']?.toString().toUpperCase() ?? '';
    if (wq == 'POOR' || wq == 'UNSAFE' || wq == 'CAUTION') score += 0.3;
    if (wq == 'CRITICAL') score += 0.5;
    
    // TDS from ESP32 sensor
    final tds = (iotData['tds'] as num?)?.toDouble();
    if (tds != null) {
      if (tds > 1000) score += 0.4;
      else if (tds > 500) score += 0.2;
    }
    
    final temperature = (iotData['temperature'] as num?)?.toDouble() ?? 25.0;
    if (temperature > 35) score += 0.3;
    else if (temperature > 30) score += 0.2;
    
    // Turbidity from sensor
    final turbidity = (iotData['turbidity'] as num?)?.toDouble();
    if (turbidity != null && turbidity > 5) score += 0.3;
    
    final humidity = (iotData['humidity'] as num?)?.toDouble() ?? 70.0;
    if (humidity > 85) score += 0.2;
    
    // Combined risk from backend (if live data)
    final combinedRisk = (iotData['combined_risk'] as num?)?.toDouble();
    if (combinedRisk != null) {
      score = (score + combinedRisk) / 2; // Blend with backend risk
    }
    
    return score.clamp(0.0, 1.0);
  }
  
  static Map<String, dynamic> _extractEntities(String description) {
    // Mock entity extraction
    final entities = <String, dynamic>{};
    
    // Extract symptoms
    final symptoms = <String>[];
    if (description.toLowerCase().contains('diarrhea')) symptoms.add('Diarrhea');
    if (description.toLowerCase().contains('vomiting')) symptoms.add('Vomiting');
    if (description.toLowerCase().contains('fever')) symptoms.add('Fever');
    if (description.toLowerCase().contains('nausea')) symptoms.add('Nausea');
    entities['symptoms'] = symptoms;
    
    // Extract locations
    final locations = <String>[];
    if (description.toLowerCase().contains('water')) locations.add('Water Source');
    if (description.toLowerCase().contains('well')) locations.add('Well');
    if (description.toLowerCase().contains('tap')) locations.add('Tap Water');
    entities['locations'] = locations;
    
    // Extract severity indicators
    final severityIndicators = <String>[];
    if (description.toLowerCase().contains('severe')) severityIndicators.add('Severe');
    if (description.toLowerCase().contains('critical')) severityIndicators.add('Critical');
    if (description.toLowerCase().contains('emergency')) severityIndicators.add('Emergency');
    entities['severity_indicators'] = severityIndicators;
    
    return entities;
  }
  
  static String _generateTriageResponse(HealthReport report, Map<String, dynamic> entities) {
    // Mock triage response generation
    final symptoms = entities['symptoms'] as List<String>? ?? [];
    final severity = report.severity;
    
    if (severity == ReportSeverity.critical) {
      return 'CRITICAL: Immediate medical attention required. Contact emergency services and isolate affected individuals.';
    } else if (severity == ReportSeverity.high) {
      return 'HIGH PRIORITY: Urgent medical evaluation needed within 24 hours. Monitor symptoms closely.';
    } else if (symptoms.contains('Diarrhea') && symptoms.contains('Vomiting')) {
      return 'MEDIUM PRIORITY: Likely water-borne illness. Ensure adequate hydration and seek medical care if symptoms worsen.';
    } else {
      return 'LOW PRIORITY: Monitor symptoms and seek medical care if they persist or worsen.';
    }
  }
  
  static double _calculatePriorityScore(HealthReport report, Map<String, dynamic> entities) {
    double score = 0.0;
    
    // Base score from severity
    switch (report.severity) {
      case ReportSeverity.low:
        score = 0.2;
        break;
      case ReportSeverity.medium:
        score = 0.5;
        break;
      case ReportSeverity.high:
        score = 0.8;
        break;
      case ReportSeverity.critical:
        score = 1.0;
        break;
    }
    
    // Adjust based on entities
    final symptoms = entities['symptoms'] as List<String>? ?? [];
    if (symptoms.contains('Diarrhea')) score += 0.1;
    if (symptoms.contains('Vomiting')) score += 0.1;
    if (symptoms.contains('Fever')) score += 0.1;
    
    return score.clamp(0.0, 1.0);
  }
  
  static String _generateAISummary(HealthReport report, Map<String, dynamic> entities) {
    final symptoms = entities['symptoms'] as List<String>? ?? [];
    final locations = entities['locations'] as List<String>? ?? [];
    
    String summary = 'Report analysis indicates ';
    
    if (symptoms.isNotEmpty) {
      summary += 'symptoms: ${symptoms.join(', ')}. ';
    }
    
    if (locations.isNotEmpty) {
      summary += 'Affected areas: ${locations.join(', ')}. ';
    }
    
    summary += 'Severity level: ${report.severity.name.toUpperCase()}. ';
    
    if (report.severity == ReportSeverity.critical || report.severity == ReportSeverity.high) {
      summary += 'Immediate action recommended.';
    } else {
      summary += 'Monitor and follow up as needed.';
    }
    
    return summary;
  }
  
  static Map<String, dynamic> _analyzeSituation(List<HealthReport> reports, Map<String, dynamic> iotData) {
    final wq = iotData['water_quality']?.toString().toUpperCase() ?? '';
    final tds = (iotData['tds'] as num?)?.toDouble();
    final temp = (iotData['temperature'] as num?)?.toDouble() ?? 25.0;
    
    return {
      'total_reports': reports.length,
      'critical_reports': reports.where((r) => r.severity == ReportSeverity.critical).length,
      'high_risk_reports': reports.where((r) => r.severity == ReportSeverity.high).length,
      'water_quality_issue': wq == 'POOR' || wq == 'CRITICAL' || wq == 'UNSAFE' || wq == 'CAUTION' || (tds != null && tds > 500),
      'environmental_risk': temp > 30.0,
      'outbreak_risk': reports.length > 10 && reports.any((r) => r.severity == ReportSeverity.critical),
      'live_sensor_data': iotData['sensor_id'] != null,
      'tds_value': tds,
      'temperature_value': temp,
    };
  }
  
  static List<Map<String, dynamic>> _generateActionItems(Map<String, dynamic> situation) {
    final actionItems = <Map<String, dynamic>>[];
    
    if (situation['water_quality_issue'] == true) {
      actionItems.add({
        'id': 'water_testing',
        'title': 'Deploy Water Testing Teams',
        'description': 'Send teams to test water quality in affected areas',
        'priority': 'high',
        'estimated_duration': '2-4 hours',
        'resources_needed': ['Water testing kits', 'Field teams', 'Transportation'],
      });
    }
    
    if (situation['critical_reports'] > 0) {
      actionItems.add({
        'id': 'emergency_response',
        'title': 'Activate Emergency Response',
        'description': 'Deploy emergency medical teams to critical areas',
        'priority': 'critical',
        'estimated_duration': '1-2 hours',
        'resources_needed': ['Medical teams', 'Emergency supplies', 'Ambulances'],
      });
    }
    
    if (situation['outbreak_risk'] == true) {
      actionItems.add({
        'id': 'containment',
        'title': 'Implement Containment Measures',
        'description': 'Establish containment zones and restrict movement',
        'priority': 'high',
        'estimated_duration': '4-6 hours',
        'resources_needed': ['Security personnel', 'Barriers', 'Communication equipment'],
      });
    }
    
    actionItems.add({
      'id': 'public_awareness',
      'title': 'Launch Public Awareness Campaign',
      'description': 'Inform public about health risks and prevention measures',
      'priority': 'medium',
      'estimated_duration': '2-3 hours',
      'resources_needed': ['Communication team', 'Broadcast equipment', 'Educational materials'],
    });
    
    return actionItems;
  }
  
  static Map<String, dynamic> _estimateResourceRequirements(List<Map<String, dynamic>> actionItems) {
    final resources = <String, int>{};
    
    for (final item in actionItems) {
      final neededResources = item['resources_needed'] as List<String>? ?? [];
      for (final resource in neededResources) {
        resources[resource] = (resources[resource] ?? 0) + 1;
      }
    }
    
    return {
      'total_estimated_cost': actionItems.length * 50000, // Mock cost calculation
      'personnel_required': actionItems.length * 3,
      'equipment_needed': resources,
      'estimated_duration': '${actionItems.length * 2} hours',
    };
  }
  
  static List<Map<String, dynamic>> _generateTimeline(List<Map<String, dynamic>> actionItems) {
    final timeline = <Map<String, dynamic>>[];
    int currentHour = 0;
    
    for (final item in actionItems) {
      final duration = int.tryParse(item['estimated_duration'].toString().split(' ')[0]) ?? 2;
      
      timeline.add({
        'time': 'T+${currentHour}h',
        'action': item['title'],
        'duration': '${duration} hours',
        'status': 'pending',
      });
      
      currentHour += duration;
    }
    
    return timeline;
  }
  
  static double _calculateSuccessProbability(List<Map<String, dynamic>> actionItems, Map<String, dynamic> resources) {
    // Mock success probability calculation
    double baseProbability = 0.8;
    
    // Adjust based on number of action items
    baseProbability -= (actionItems.length - 1) * 0.05;
    
    // Adjust based on resource availability
    final personnelRequired = resources['personnel_required'] as int? ?? 0;
    if (personnelRequired > 10) baseProbability -= 0.1;
    
    return baseProbability.clamp(0.0, 1.0);
  }
  
  static String _generateMessage(String topic, String language, String severity) {
    if (language == 'kha') {
      return _generateKhasiMessage(topic, severity);
    } else {
      return _generateEnglishMessage(topic, severity);
    }
  }
  
  static String _generateEnglishMessage(String topic, String severity) {
    switch (topic.toLowerCase()) {
      case 'water contamination':
        return 'URGENT: Water contamination detected in your area. Please boil all water before drinking and avoid using tap water for cooking. Contact health officials immediately if you experience symptoms.';
      case 'disease outbreak':
        return 'HEALTH ALERT: Disease outbreak reported in your area. Please maintain hygiene, avoid crowded places, and seek medical attention if you experience symptoms.';
      case 'prevention':
        return 'HEALTH TIP: Prevent water-borne diseases by boiling water, washing hands regularly, and maintaining proper hygiene. Stay safe and healthy!';
      default:
        return 'Important health information for your area. Please stay informed and follow health guidelines.';
    }
  }
  
  static String _generateKhasiMessage(String topic, String severity) {
    // Mock Khasi translation - in real app, this would use proper translation service
    switch (topic.toLowerCase()) {
      case 'water contamination':
        return 'BAH KHUB: Ka jingpynshoi ka um ka la pyni ha ka jaka jong phi. Sngewbha ban pyniap ia ka um baroh ka jingduh bad ban ieng ia ka um tap ha ka jingbam. Iapher ia ki nongthoh baing ha ka jingkmen kaba kham shisha lada phi don ki jingpynshoi.';
      case 'disease outbreak':
        return 'JINGKIT KHUB: Ka jingpynshoi ka na ka jingpynshoi ka la pyni ha ka jaka jong phi. Sngewbha ban ieng ia ka jingkmen, ban ieng ia ki jaka kiba don shibun ki briew, bad ban ieng ia ka jingkmen lada phi don ki jingpynshoi.';
      case 'prevention':
        return 'JINGKIT KHUB: Ban ieng ia ki jingpynshoi na ka um da ka jingpyniap ia ka um, ka jingkmen baing, bad ka jingieng ia ka jingkmen. Ieng ia ka jingkmen bad ka jingkmen!';
      default:
        return 'Ki jingkmen kaba kham shisha ha ka jaka jong phi. Sngewbha ban ieng ia ka jingkmen bad ban ieng ia ki jingkmen.';
    }
  }
  
  static Map<String, String> _generateTranslations(String message, String originalLanguage) {
    // Mock translation generation
    if (originalLanguage == 'en') {
      return {
        'kha': 'Ka jingkmen kaba kham shisha ha ka jaka jong phi. Sngewbha ban ieng ia ka jingkmen.',
        'hi': 'आपके क्षेत्र के लिए महत्वपूर्ण स्वास्थ्य जानकारी। कृपया सूचित रहें।',
      };
    } else {
      return {
        'en': 'Important health information for your area. Please stay informed.',
        'hi': 'आपके क्षेत्र के लिए महत्वपूर्ण स्वास्थ्य जानकारी। कृपया सूचित रहें।',
      };
    }
  }
  
  static Map<String, dynamic> _generateVisualElements(String topic, String severity) {
    return {
      'color_scheme': severity == 'critical' ? 'red' : severity == 'high' ? 'orange' : 'blue',
      'icons': ['water_drop', 'warning', 'health'],
      'layout': 'alert',
      'priority': severity,
    };
  }
  
  static int _calculateReachEstimate(String severity) {
    // Mock reach calculation
    switch (severity.toLowerCase()) {
      case 'critical':
        return 50000;
      case 'high':
        return 30000;
      case 'medium':
        return 15000;
      default:
        return 10000;
    }
  }
  
  static double _calculateOutbreakProbability(List<HealthReport> reports, Map<String, dynamic> environmentalData) {
    double probability = 0.0;
    
    // Factor 1: Number of reports
    probability += (reports.length / 20.0).clamp(0.0, 0.4);
    
    // Factor 2: Severity of reports
    final criticalReports = reports.where((r) => r.severity == ReportSeverity.critical).length;
    probability += (criticalReports / 5.0).clamp(0.0, 0.3);
    
    // Factor 3: Environmental conditions
    final temperature = environmentalData['temperature'] as double? ?? 25.0;
    if (temperature > 30) probability += 0.2;
    
    final humidity = environmentalData['humidity'] as double? ?? 70.0;
    if (humidity > 85) probability += 0.1;
    
    return probability.clamp(0.0, 1.0);
  }
  
  static List<String> _identifyPotentialDiseases(List<HealthReport> reports) {
    final diseases = <String>[];
    
    for (final report in reports) {
      final description = report.description.toLowerCase();
      if (description.contains('diarrhea') && description.contains('vomiting')) {
        diseases.add('Gastroenteritis');
      }
      if (description.contains('fever') && description.contains('headache')) {
        diseases.add('Typhoid');
      }
      if (description.contains('jaundice')) {
        diseases.add('Hepatitis A');
      }
    }
    
    return diseases.toSet().toList();
  }
  
  static List<String> _generatePreventionRecommendations(List<String> diseases) {
    final recommendations = <String>[];
    
    if (diseases.contains('Gastroenteritis')) {
      recommendations.add('Boil all drinking water for at least 1 minute');
      recommendations.add('Wash hands frequently with soap and water');
      recommendations.add('Avoid raw or undercooked food');
    }
    
    if (diseases.contains('Typhoid')) {
      recommendations.add('Ensure proper sewage disposal');
      recommendations.add('Vaccinate high-risk individuals');
      recommendations.add('Maintain food hygiene standards');
    }
    
    if (diseases.contains('Hepatitis A')) {
      recommendations.add('Improve sanitation facilities');
      recommendations.add('Educate about proper hygiene practices');
      recommendations.add('Vaccinate vulnerable populations');
    }
    
    return recommendations;
  }
  
  static Map<String, dynamic> _estimateOutbreakTimeline(double probability, List<String> diseases) {
    int daysToOutbreak = 0;
    int peakDuration = 0;
    
    if (probability > 0.8) {
      daysToOutbreak = 1;
      peakDuration = 14;
    } else if (probability > 0.6) {
      daysToOutbreak = 3;
      peakDuration = 21;
    } else if (probability > 0.4) {
      daysToOutbreak = 7;
      peakDuration = 28;
    } else {
      daysToOutbreak = 14;
      peakDuration = 35;
    }
    
    return {
      'days_to_outbreak': daysToOutbreak,
      'peak_duration_days': peakDuration,
      'total_duration_days': peakDuration + 14,
      'intervention_window_days': daysToOutbreak - 1,
    };
  }
}
