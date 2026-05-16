import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:farmzy/features/maintenance/providers/maintenance_provider.dart';
import 'package:farmzy/features/settings/providers/app_config_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MaintenanceScreen extends ConsumerWidget {
  const MaintenanceScreen({super.key});

  String _t(String key, String fallback) {
    try {
      final translated = key.tr();
      if (translated == key) return fallback;
      return translated;
    } catch (_) {
      return fallback;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maintenanceState = ref.watch(maintenanceProvider);
    final configState = ref.watch(appConfigProvider);
    final isReadOnly = maintenanceState.isReadOnly;

    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      body: Stack(
        children: [
          const _PremiumBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _AnimatedMaintenanceIcon(isReadOnly: isReadOnly)
                        .animate()
                        .fadeIn(duration: 800.ms)
                        .scale(begin: const Offset(0.8, 0.8)),

                    const SizedBox(height: 48),

                    Text(
                      _t('maint_title', 'System Enhancement'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                        height: 1.1,
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),

                    const SizedBox(height: 16),

                    Text(
                      _t('maint_subtitle', 'We are currently optimizing FarmZY services for a better experience.'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 15,
                        height: 1.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ).animate().fadeIn(delay: 400.ms),

                    const SizedBox(height: 48),

                    _PremiumStatusCard(
                      isReadOnly: isReadOnly,
                      t: _t,
                    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.05, end: 0),

                    const SizedBox(height: 40),

                    _GlassActionButton(
                      isLoading: configState.isLoading,
                      onPressed: () => ref.read(appConfigProvider.notifier).fetchConfig(),
                      label: _t('maint_retry_button', 'Retry Connection'),
                    ).animate().fadeIn(delay: 800.ms),

                    const SizedBox(height: 24),

                    _OperationalIndicator(
                      label: _t('maint_system_status', 'Admin Systems Operational'),
                    ).animate().fadeIn(delay: 1000.ms),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedMaintenanceIcon extends StatelessWidget {
  final bool isReadOnly;
  const _AnimatedMaintenanceIcon({required this.isReadOnly});

  @override
  Widget build(BuildContext context) {
    final primaryColor = isReadOnly ? Colors.amber : const Color(0xFF22C55E);

    return SizedBox(
      height: 120,
      width: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Layered Glows
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.15),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
          
          // Main Icon Container
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.08),
                  Colors.white.withOpacity(0.02),
                ],
              ),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Icon(
              isReadOnly ? Icons.visibility_outlined : Icons.auto_awesome_rounded,
              size: 44,
              color: primaryColor.withOpacity(0.9),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(begin: -5, end: 5, duration: 2.seconds, curve: Curves.easeInOut),
        ],
      ),
    );
  }
}

class _PremiumStatusCard extends StatelessWidget {
  final bool isReadOnly;
  final String Function(String, String) t;
  const _PremiumStatusCard({required this.isReadOnly, required this.t});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 320),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // ✅ ALIGN TO LEFT
        children: [
          _StackedSection(
            label: t('maint_status_label', 'Current Status'),
            value: isReadOnly 
                ? t('maint_status_read_only', 'Platform in Read-Only Mode') 
                : t('maint_status_value', 'Maintenance in Progress'),
            isHighlight: true,
            highlightColor: isReadOnly ? Colors.amber : const Color(0xFF22C55E),
          ),
          Divider(height: 1, color: Colors.white.withOpacity(0.05)),
          _StackedSection(
            label: t('maint_affected_label', 'Service Impact'),
            value: isReadOnly 
                ? t('maint_affected_writes', 'New listings and orders are temporarily disabled.') 
                : t('maint_affected_value', 'All marketplace modules are temporarily offline for optimization.'),
          ),
          Divider(height: 1, color: Colors.white.withOpacity(0.05)),
          _StackedSection(
            label: t('maint_return_label', 'Estimated Return'),
            value: t('maint_return_value', '~30 Minutes'),
          ),
        ],
      ),
    );
  }
}

class _StackedSection extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlight;
  final Color? highlightColor;

  const _StackedSection({
    required this.label,
    required this.value,
    this.isHighlight = false,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: Colors.white.withOpacity(0.3),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: isHighlight ? highlightColor : Colors.white.withOpacity(0.8),
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassActionButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  final String label;

  const _GlassActionButton({
    required this.isLoading, 
    required this.onPressed,
    required this.label,
  });

  @override
  State<_GlassActionButton> createState() => _GlassActionButtonState();
}

class _GlassActionButtonState extends State<_GlassActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(_isPressed ? 0.15 : 0.08),
              Colors.white.withOpacity(_isPressed ? 0.08 : 0.03),
            ],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(_isPressed ? 0.2 : 0.1),
          ),
        ),
        child: Center(
          child: widget.isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54),
                )
              : Text(
                  widget.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    letterSpacing: 0.2,
                  ),
                ),
        ),
      ),
    );
  }
}

class _OperationalIndicator extends StatelessWidget {
  final String label;
  const _OperationalIndicator({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: Color(0xFF22C55E),
            shape: BoxShape.circle,
          ),
        ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.seconds),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.3),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _PremiumBackground extends StatelessWidget {
  const _PremiumBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -150,
          left: -50,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF22C55E).withOpacity(0.03),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -100,
          right: -50,
          child: Container(
            width: 350,
            height: 350,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF3B82F6).withOpacity(0.03),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
