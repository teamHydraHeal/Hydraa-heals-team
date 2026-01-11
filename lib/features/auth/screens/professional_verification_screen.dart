import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/models/user_model.dart';

class ProfessionalVerificationScreen extends StatefulWidget {
  const ProfessionalVerificationScreen({super.key});

  @override
  State<ProfessionalVerificationScreen> createState() => _ProfessionalVerificationScreenState();
}

class _ProfessionalVerificationScreenState extends State<ProfessionalVerificationScreen> {
  final TextEditingController _professionalIdController = TextEditingController();
  final TextEditingController _documentTypeController = TextEditingController();
  String _selectedDocumentType = 'ID Card';
  bool _isDocumentUploaded = false;

  final List<String> _documentTypes = [
    'ID Card',
    'License',
    'Certificate',
    'Registration',
  ];

  @override
  void dispose() {
    _professionalIdController.dispose();
    _documentTypeController.dispose();
    super.dispose();
  }

  Future<void> _submitVerification() async {
    if (_professionalIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your professional ID'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.verifyProfessional(
      _professionalIdController.text,
      _selectedDocumentType,
    );

    if (success && mounted) {
      // Request notification permissions
      await _requestNotificationPermissions();
      
      // Navigate to appropriate dashboard
      final user = authProvider.currentUser;
      if (user != null) {
        switch (user.role) {
          case UserRole.healthOfficial:
            context.go('/health-official/dashboard');
            break;
          case UserRole.ashaWorker:
            context.go('/field-worker/dashboard');
            break;
          case UserRole.citizen:
            context.go('/citizen/dashboard');
            break;
        }
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Verification failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _requestNotificationPermissions() async {
    // In a real app, this would request notification permissions
    // For demo purposes, we'll just show a dialog
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Enable Notifications'),
          content: const Text(
            'Jal Guard would like to send you health alerts and updates. This helps you stay informed about critical health situations in your area.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Not Now'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Allow'),
            ),
          ],
        ),
      );
    }
  }

  void _simulateDocumentUpload() {
    setState(() {
      _isDocumentUploaded = true;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Document uploaded successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Professional Verification'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            
            // Header
            Text(
              'Verify Your ${user?.role == UserRole.healthOfficial ? 'Medical' : 'ASHA'} Credentials',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Please provide your professional identification to complete the verification process',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            
            const SizedBox(height: 48),
            
            // Professional ID Field
            TextFormField(
              controller: _professionalIdController,
              decoration: InputDecoration(
                labelText: 'Professional ID',
                hintText: user?.role == UserRole.healthOfficial 
                    ? 'Medical License Number'
                    : 'ASHA Worker ID',
                prefixIcon: const Icon(Icons.badge),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Document Type Dropdown
            DropdownButtonFormField<String>(
              initialValue: _selectedDocumentType,
              decoration: InputDecoration(
                labelText: 'Document Type',
                prefixIcon: const Icon(Icons.description),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                ),
              ),
              items: _documentTypes.map((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedDocumentType = newValue;
                  });
                }
              },
            ),
            
            const SizedBox(height: 24),
            
            // Document Upload Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    _isDocumentUploaded ? Icons.check_circle : Icons.cloud_upload,
                    size: 48,
                    color: _isDocumentUploaded ? Colors.green : Colors.grey,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    _isDocumentUploaded 
                        ? 'Document Uploaded Successfully'
                        : 'Upload Professional Document',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'Upload a clear photo of your professional ID or certificate',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  if (!_isDocumentUploaded)
                    ElevatedButton.icon(
                      onPressed: _simulateDocumentUpload,
                      icon: const Icon(Icons.upload),
                      label: const Text('Upload Document'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Submit Button
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: authProvider.isLoading ? null : _submitVerification,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: authProvider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Submit Verification',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // Demo Information
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withValues(alpha:0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Demo Mode: Professional verification is simulated. In production, this would verify credentials with official databases.',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const Spacer(),
            
            // Footer
            const Center(
              child: Text(
                'Your professional information is secure and encrypted',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
