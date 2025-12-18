import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/design_tokens.dart';

/// Card for connecting music streaming services.
class ServiceConnectCard extends StatelessWidget {
  /// Name of the service (e.g., "Spotify", "Apple Music").
  final String serviceName;

  /// Whether the service is connected.
  final bool isConnected;

  /// Callback when the connect/disconnect button is pressed.
  final VoidCallback onTap;

  /// Whether a connection is in progress.
  final bool isLoading;

  /// Icon or logo widget for the service.
  final Widget? icon;

  /// Primary color for the service.
  final Color serviceColor;

  const ServiceConnectCard({
    super.key,
    required this.serviceName,
    required this.isConnected,
    required this.onTap,
    this.isLoading = false,
    this.icon,
    this.serviceColor = AppColors.hotPink,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isConnected
              ? serviceColor.withAlpha(26)
              : Colors.white.withAlpha(8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isConnected
                ? serviceColor.withAlpha(128)
                : Colors.white.withAlpha(26),
            width: isConnected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Service icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: serviceColor.withAlpha(38),
                borderRadius: BorderRadius.circular(14),
              ),
              child: icon ??
                  Icon(
                    Icons.music_note,
                    color: serviceColor,
                    size: 28,
                  ),
            ),
            const SizedBox(width: 16),

            // Service name and status
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    serviceName,
                    style: GoogleFonts.syne(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isConnected ? 'Connected' : 'Tap to connect',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      color: isConnected
                          ? serviceColor
                          : Colors.white.withAlpha(128),
                    ),
                  ),
                ],
              ),
            ),

            // Connect/Connected indicator
            if (isLoading)
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(serviceColor),
                ),
              )
            else if (isConnected)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: serviceColor.withAlpha(51),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  color: serviceColor,
                  size: 16,
                ),
              )
            else
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white.withAlpha(102),
                size: 16,
              ),
          ],
        ),
      ),
    );
  }
}

/// Spotify service card with proper branding.
class SpotifyConnectCard extends StatelessWidget {
  final bool isConnected;
  final VoidCallback onTap;
  final bool isLoading;

  const SpotifyConnectCard({
    super.key,
    required this.isConnected,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ServiceConnectCard(
      serviceName: 'Spotify',
      isConnected: isConnected,
      onTap: onTap,
      isLoading: isLoading,
      serviceColor: const Color(0xFF1DB954),
      icon: Center(
        child: Text(
          '♫',
          style: TextStyle(
            fontSize: 28,
            color: const Color(0xFF1DB954),
          ),
        ),
      ),
    );
  }
}

/// Apple Music service card with proper branding.
class AppleMusicConnectCard extends StatelessWidget {
  final bool isConnected;
  final VoidCallback onTap;
  final bool isLoading;

  const AppleMusicConnectCard({
    super.key,
    required this.isConnected,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ServiceConnectCard(
      serviceName: 'Apple Music',
      isConnected: isConnected,
      onTap: onTap,
      isLoading: isLoading,
      serviceColor: const Color(0xFFFC3C44),
      icon: Center(
        child: Text(
          '♪',
          style: TextStyle(
            fontSize: 28,
            color: const Color(0xFFFC3C44),
          ),
        ),
      ),
    );
  }
}
