import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/auth_provider.dart';

class AadhaarEntryScreen extends StatefulWidget {
  const AadhaarEntryScreen({super.key});

  @override
  State<AadhaarEntryScreen> createState() => _AadhaarEntryScreenState();
}

class _AadhaarEntryScreenState extends State<AadhaarEntryScreen> {
  final TextEditingController _aadhaarController = TextEditingController();
  final FocusNode _aadhaarFocusNode = FocusNode();
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _aadhaarController.addListener(_validateAadhaar);
  }

  @override
  void dispose() {
    _aadhaarController.dispose();
    _aadhaarFocusNode.dispose();
    super.dispose();
  }

  void _validateAadhaar() {
    final text = _aadhaarController.text.replaceAll(' ', '');
    setState(() {
      _isValid = text.length == 12 && RegExp(r'^\d{12}$').hasMatch(text);
    });
  }

  String _formatAadhaar(String value) {
    // Remove all non-digits
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    
    // Limit to 12 digits
    final limited = digitsOnly.length > 12 ? digitsOnly.substring(0, 12) : digitsOnly;
    
    // Add spaces every 4 digits
    final formatted = limited.replaceAllMapped(
      RegExp(r'(\d{4})'),
      (match) => '${match.group(1)} ',
    ).trim();
    
    return formatted;
  }

  Future<void> _requestOtp() async {
    if (!_isValid) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final aadhaarNumber = _aadhaarController.text.replaceAll(' ', '');
    
    final success = await authProvider.sendOtp(aadhaarNumber);
    
    if (success && mounted) {
      context.push('/otp-verification');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Failed to send OTP'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aadhaar Login'),
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
            const Text(
              'Enter your 12-digit Aadhaar number',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            
            const SizedBox(height: 8),
            
            const Text(
              'We\'ll send you an OTP to verify your identity',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            
            const SizedBox(height: 48),
            
            // Aadhaar Input Field
            TextFormField(
              controller: _aadhaarController,
              focusNode: _aadhaarFocusNode,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(12),
              ],
              onChanged: (value) {
                final formatted = _formatAadhaar(value);
                if (formatted != value) {
                  _aadhaarController.value = TextEditingValue(
                    text: formatted,
                    selection: TextSelection.collapsed(offset: formatted.length),
                  );
                }
              },
              decoration: InputDecoration(
                labelText: 'Aadhaar Number',
                hintText: '1234 5678 9012',
                prefixIcon: const Icon(Icons.credit_card),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                helperText: 'For demo, use any 12-digit number',
                helperStyle: const TextStyle(color: Colors.grey),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Request OTP Button
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: authProvider.isLoading || !_isValid
                        ? null
                        : _requestOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isValid 
                          ? const Color(0xFF2E7D32)
                          : Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: authProvider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Request OTP',
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
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Demo Mode: Use any 12-digit number to proceed. The system will simulate user roles based on the last digit.',
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
                'Your Aadhaar number is secure and encrypted',
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
