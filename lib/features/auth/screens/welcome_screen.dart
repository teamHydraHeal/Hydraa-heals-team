import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final AnimationController _slideController;

  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0B5A42),
              Color(0xFF0D7A57),
              Color(0xFF2AA879),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -120,
              right: -80,
              child: _buildAmbientCircle(
                size: 280,
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
            Positioned(
              left: -100,
              bottom: 160,
              child: _buildAmbientCircle(
                size: 240,
                color: Colors.white.withValues(alpha: 0.09),
              ),
            ),
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        _buildBrandBlock(context),
                        const SizedBox(height: 24),
                        _buildMissionCard(context),
                        const SizedBox(height: 16),
                        _buildTrustRow(),
                        const Spacer(),
                        _buildActionButtons(context),
                        const SizedBox(height: 16),
                        Center(
                          child: Text(
                            'Secure data handling and role-based access',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  letterSpacing: 0.1,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmbientCircle({required double size, required Color color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildBrandBlock(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.22),
                ),
              ),
              child: const Icon(
                Icons.water_drop_rounded,
                color: Colors.white,
                size: 34,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Jal Guard',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          'Public Health Command Center for fast water-risk detection and response.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.92),
                height: 1.38,
              ),
        ),
      ],
    );
  }

  Widget _buildMissionCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mission',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Support communities in Meghalaya with predictive alerts, field reporting, multilingual health guidance, and coordinated action planning.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  height: 1.4,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustRow() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: const [
        _TrustChip(icon: Icons.gpp_good_outlined, label: 'Secure Access'),
        _TrustChip(icon: Icons.offline_bolt_outlined, label: 'Offline First'),
        _TrustChip(icon: Icons.language_outlined, label: 'Multilingual'),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        _PrimaryActionButton(
          label: 'Get Started',
          icon: Icons.arrow_forward_rounded,
          isFilled: true,
          onTap: () => context.push('/aadhaar-entry'),
        ),
        const SizedBox(height: 12),
        _PrimaryActionButton(
          label: 'Login',
          icon: Icons.login_rounded,
          isFilled: false,
          onTap: () => context.push('/aadhaar-entry'),
        ),
      ],
    );
  }
}

class _TrustChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _TrustChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isFilled;
  final VoidCallback onTap;

  const _PrimaryActionButton({
    required this.label,
    required this.icon,
    required this.isFilled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isFilled ? Colors.white : Colors.transparent,
          foregroundColor: isFilled ? const Color(0xFF0D7A57) : Colors.white,
          elevation: isFilled ? 2 : 0,
          side: isFilled
              ? null
              : BorderSide(color: Colors.white.withValues(alpha: 0.8), width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
