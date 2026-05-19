import 'package:flutter/material.dart';

class MaintenanceModeScreen extends StatelessWidget {
  final String? message;
  final VoidCallback? onRefresh;

  const MaintenanceModeScreen({
    Key? key,
    this.message,
    this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E1E2C), Color(0xFF0F0F16)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 110,
                  width: 110,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAAD14).withOpacity(0.08),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFAAD14).withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.construction_rounded,
                      size: 48,
                      color: Color(0xFFFAAD14),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Scheduled Maintenance',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message ?? 'We are upgrading our agricultural systems to serve you better. We will be back online shortly. Thank you for your patience!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFA6A6C0),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 48),
                if (onRefresh != null)
                  SizedBox(
                    width: 160,
                    height: 46,
                    child: OutlinedButton(
                      onPressed: onRefresh,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFFAAD14),
                        side: const BorderSide(color: Color(0xFFFAAD14), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.refresh_rounded, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Check Status',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
