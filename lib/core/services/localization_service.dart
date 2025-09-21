import 'dart:convert';
import 'package:flutter/services.dart';

class LocalizationService {
  static LocalizationService? _instance;
  static LocalizationService get instance => _instance ??= LocalizationService._();
  
  LocalizationService._();
  
  Map<String, dynamic> _localizedStrings = {};
  String _currentLanguage = 'en';
  
  String get currentLanguage => _currentLanguage;
  
  Future<void> initialize() async {
    await loadLanguage('en');
  }
  
  Future<void> loadLanguage(String languageCode) async {
    try {
      final String jsonString = await rootBundle.loadString('assets/translations/$languageCode.json');
      _localizedStrings = json.decode(jsonString);
      _currentLanguage = languageCode;
    } catch (e) {
      print('Failed to load language $languageCode: $e');
      // Fallback to English if loading fails
      if (languageCode != 'en') {
        await loadLanguage('en');
      }
    }
  }
  
  String translate(String key, {Map<String, dynamic>? params}) {
    String translation = _localizedStrings[key] ?? key;
    
    // Replace parameters if provided
    if (params != null) {
      params.forEach((paramKey, value) {
        translation = translation.replaceAll('{$paramKey}', value.toString());
      });
    }
    
    return translation;
  }
  
  // Helper methods for common translations
  String get appName => translate('app_name');
  String get welcome => translate('welcome');
  String get login => translate('login');
  String get logout => translate('logout');
  String get register => translate('register');
  String get submit => translate('submit');
  String get cancel => translate('cancel');
  String get save => translate('save');
  String get edit => translate('edit');
  String get delete => translate('delete');
  String get confirm => translate('confirm');
  String get back => translate('back');
  String get next => translate('next');
  String get previous => translate('previous');
  String get done => translate('done');
  String get loading => translate('loading');
  String get error => translate('error');
  String get success => translate('success');
  String get warning => translate('warning');
  String get info => translate('info');
  
  // Health specific translations
  String get healthReport => translate('health_report');
  String get waterQuality => translate('water_quality');
  String get diseaseOutbreak => translate('disease_outbreak');
  String get emergency => translate('emergency');
  String get riskLevel => translate('risk_level');
  String get symptoms => translate('symptoms');
  String get location => translate('location');
  String get severity => translate('severity');
  String get critical => translate('critical');
  String get high => translate('high');
  String get medium => translate('medium');
  String get low => translate('low');
  
  // User roles
  String get healthOfficial => translate('health_official');
  String get ashaWorker => translate('asha_worker');
  String get citizen => translate('citizen');
  
  // Navigation
  String get dashboard => translate('dashboard');
  String get reports => translate('reports');
  String get analytics => translate('analytics');
  String get notifications => translate('notifications');
  String get profile => translate('profile');
  String get settings => translate('settings');
  String get education => translate('education');
  String get broadcast => translate('broadcast');
  
  // AI specific
  String get aiCopilot => translate('ai_copilot');
  String get aiAnalysis => translate('ai_analysis');
  String get actionPlan => translate('action_plan');
  String get generatePlan => translate('generate_plan');
  String get successProbability => translate('success_probability');
  
  // Notifications
  String get healthAlert => translate('health_alert');
  String get reportUpdate => translate('report_update');
  String get systemMessage => translate('system_message');
  
  // Form fields
  String get aadhaarNumber => translate('aadhaar_number');
  String get phoneNumber => translate('phone_number');
  String get email => translate('email');
  String get password => translate('password');
  String get confirmPassword => translate('confirm_password');
  String get fullName => translate('full_name');
  String get address => translate('address');
  String get description => translate('description');
  
  // Validation messages
  String get requiredField => translate('required_field');
  String get invalidFormat => translate('invalid_format');
  String get passwordMismatch => translate('password_mismatch');
  String get invalidCredentials => translate('invalid_credentials');
  
  // Status messages
  String get online => translate('online');
  String get offline => translate('offline');
  String get syncing => translate('syncing');
  String get synced => translate('synced');
  String get pending => translate('pending');
  String get processing => translate('processing');
  String get processed => translate('processed');
  String get verified => translate('verified');
  String get unverified => translate('unverified');
  
  // Time formats
  String get justNow => translate('just_now');
  String get minutesAgo => translate('minutes_ago');
  String get hoursAgo => translate('hours_ago');
  String get daysAgo => translate('days_ago');
  
  // Actions
  String get viewDetails => translate('view_details');
  String get editReport => translate('edit_report');
  String get deleteReport => translate('delete_report');
  String get shareReport => translate('share_report');
  String get downloadReport => translate('download_report');
  String get printReport => translate('print_report');
  
  // Health tips
  String get healthTips => translate('health_tips');
  String get prevention => translate('prevention');
  String get treatment => translate('treatment');
  String get emergencyContacts => translate('emergency_contacts');
  String get waterSafety => translate('water_safety');
  String get hygiene => translate('hygiene');
  String get nutrition => translate('nutrition');
  
  // Map related
  String get map => translate('map');
  String get district => translate('district');
  String get block => translate('block');
  String get village => translate('village');
  String get riskPrediction => translate('risk_prediction');
  String get fieldReports => translate('field_reports');
  
  // Broadcast
  String get communityBroadcast => translate('community_broadcast');
  String get broadcastTopic => translate('broadcast_topic');
  String get broadcastMessage => translate('broadcast_message');
  String get sendBroadcast => translate('send_broadcast');
  String get estimatedReach => translate('estimated_reach');
  
  // Resource management
  String get resources => translate('resources');
  String get personnel => translate('personnel');
  String get equipment => translate('equipment');
  String get supplies => translate('supplies');
  String get vehicles => translate('vehicles');
  String get budget => translate('budget');
  
  // IoT Data
  String get iotData => translate('iot_data');
  String get temperature => translate('temperature');
  String get humidity => translate('humidity');
  String get phLevel => translate('ph_level');
  String get turbidity => translate('turbidity');
  String get chlorineLevel => translate('chlorine_level');
  
  // Risk assessment
  String get riskAssessment => translate('risk_assessment');
  String get outbreakProbability => translate('outbreak_probability');
  String get preventionRecommendations => translate('prevention_recommendations');
  String get interventionWindow => translate('intervention_window');
  
  // Professional verification
  String get professionalVerification => translate('professional_verification');
  String get professionalId => translate('professional_id');
  String get documentType => translate('document_type');
  String get uploadDocument => translate('upload_document');
  String get verificationStatus => translate('verification_status');
  
  // MCP Cards
  String get mcpCard => translate('mcp_card');
  String get patientRecords => translate('patient_records');
  String get vaccinationCard => translate('vaccination_card');
  String get growthChart => translate('growth_chart');
  String get medicalHistory => translate('medical_history');
  
  // Sync and offline
  String get sync => translate('sync');
  String get syncNow => translate('sync_now');
  String get lastSync => translate('last_sync');
  String get pendingSync => translate('pending_sync');
  String get offlineMode => translate('offline_mode');
  String get dataSync => translate('data_sync');
  
  // Privacy and security
  String get privacy => translate('privacy');
  String get security => translate('security');
  String get dataProtection => translate('data_protection');
  String get consent => translate('consent');
  String get dataSharing => translate('data_sharing');
  String get encryption => translate('encryption');
  
  // Help and support
  String get help => translate('help');
  String get support => translate('support');
  String get faq => translate('faq');
  String get contactUs => translate('contact_us');
  String get feedback => translate('feedback');
  String get reportBug => translate('report_bug');
  String get rateApp => translate('rate_app');
  
  // App information
  String get version => translate('version');
  String get buildNumber => translate('build_number');
  String get lastUpdated => translate('last_updated');
  String get termsOfService => translate('terms_of_service');
  String get privacyPolicy => translate('privacy_policy');
  String get about => translate('about');
  
  // Custom translation method with context
  String translateWithContext(String key, String context, {Map<String, dynamic>? params}) {
    final contextKey = '${context}_$key';
    return translate(contextKey, params: params);
  }
  
  // Get all available languages
  List<String> get availableLanguages => ['en', 'kha'];
  
  // Get language display name
  String getLanguageDisplayName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'kha':
        return 'Khasi';
      default:
        return languageCode.toUpperCase();
    }
  }
  
  // Check if translation exists
  bool hasTranslation(String key) {
    return _localizedStrings.containsKey(key);
  }
  
  // Get all translations for a specific context
  Map<String, String> getTranslationsForContext(String context) {
    final Map<String, String> contextTranslations = {};
    _localizedStrings.forEach((key, value) {
      if (key.startsWith('${context}_')) {
        contextTranslations[key] = value.toString();
      }
    });
    return contextTranslations;
  }
}
