import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/models/user_model.dart';

class ProfessionalVerificationScreen extends StatefulWidget {
  const ProfessionalVerificationScreen({super.key});

  @override
  State<ProfessionalVerificationScreen> createState() =>
      _ProfessionalVerificationScreenState();
}

class _ProfessionalVerificationScreenState
    extends State<ProfessionalVerificationScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _professionalIdController =
      TextEditingController();
  String _selectedDocumentType = 'ID Card';
  bool _isDocumentUploaded = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  final List<String> _documentTypes = [
    'ID Card',
    'License',
    'Certificate',
    'Registration',
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _professionalIdController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _submitVerification() async {
    if (_professionalIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter your professional ID'),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
      await _requestNotificationPermissions();

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
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _requestNotificationPermissions() async {
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.notifications_active, color: Color(0xFF0D7A57)),
              SizedBox(width: 8),
              Text('Enable Notifications'),
            ],
          ),
          content: const Text(
            'Jal Guard would like to send you health alerts and updates. This helps you stay informed about critical health situations in your area.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Not Now', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D7A57),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child:
                  const Text('Allow', style: TextStyle(color: Colors.white)),
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
      SnackBar(
        content: const Text('Document uploaded successfully'),
        backgroundColor: const Color(0xFF2AA879),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final isHealthOfficial = user?.role == UserRole.healthOfficial;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE8F5E9),
              Color(0xFFFFFFFF),
              Color(0xFFE3F2FD),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Back button
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.arrow_back_ios_new,
                          size: 18, color: Color(0xFF0D7A57)),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Icon
                  Center(
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2AA879), Color(0xFF0D7A57)],
                        ),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0D7A57).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                          isHealthOfficial
                              ? Icons.medical_services
                              : Icons.health_and_safety,
                          size: 45,
                          color: Colors.white),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Header
                  Center(
                    child: Text(
                      'Verify ${isHealthOfficial ? 'Medical' : 'ASHA'} Credentials',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E2C25),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Center(
                    child: Text(
                      'Complete your professional verification',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),

                  const SizedBox(height: 35),

                  // Main Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Professional ID Field
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color:
                                    const Color(0xFF0D7A57).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.badge,
                                  color: Color(0xFF0D7A57)),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Professional ID',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF333333),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _professionalIdController,
                          style: const TextStyle(
                            color: Color(0xFF333333),
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            hintText: isHealthOfficial
                                ? 'Medical License Number'
                                : 'ASHA Worker ID',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            filled: true,
                            fillColor: const Color(0xFFF5F5F5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                  color: Color(0xFF0D7A57), width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 16),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Document Type
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color:
                                    const Color(0xFF0D7A57).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.description,
                                  color: Color(0xFF0D7A57)),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Document Type',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF333333),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        DropdownButtonFormField<String>(
                          value: _selectedDocumentType,
                          style: const TextStyle(
                            color: Color(0xFF333333),
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF5F5F5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                  color: Color(0xFF0D7A57), width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 16),
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
                            color: _isDocumentUploaded
                                ? const Color(0xFFE8F5E9)
                                : const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _isDocumentUploaded
                                  ? const Color(0xFF2AA879).withOpacity(0.3)
                                  : Colors.grey.shade300,
                              width: 1.5,
                              style: _isDocumentUploaded
                                  ? BorderStyle.solid
                                  : BorderStyle.solid,
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _isDocumentUploaded
                                      ? const Color(0xFF2AA879).withOpacity(0.1)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  _isDocumentUploaded
                                      ? Icons.check_circle
                                      : Icons.cloud_upload_outlined,
                                  size: 40,
                                  color: _isDocumentUploaded
                                      ? const Color(0xFF2AA879)
                                      : Colors.grey[500],
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                _isDocumentUploaded
                                    ? 'Document Uploaded'
                                    : 'Upload Document',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: _isDocumentUploaded
                                      ? const Color(0xFF0D7A57)
                                      : const Color(0xFF333333),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Photo of your ID or certificate',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                              if (!_isDocumentUploaded) ...[
                                const SizedBox(height: 14),
                                ElevatedButton.icon(
                                  onPressed: _simulateDocumentUpload,
                                  icon: const Icon(Icons.upload, size: 18),
                                  label: const Text('Choose File'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0D7A57),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Submit Button
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed:
                              authProvider.isLoading ? null : _submitVerification,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D7A57),
                            disabledBackgroundColor: Colors.grey[300],
                            elevation: 8,
                            shadowColor:
                                const Color(0xFF0D7A57).withOpacity(0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: authProvider.isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Submit Verification',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(Icons.verified_user,
                                        color: Colors.white, size: 20),
                                  ],
                                ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Info Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: const Color(0xFF1976D2).withOpacity(0.2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.info_outline,
                              color: Color(0xFF1976D2), size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Demo Mode: Verification is simulated. In production, credentials would be verified with official databases.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Footer
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock_outline,
                            size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 6),
                        Text(
                          'Your information is secure and encrypted',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
