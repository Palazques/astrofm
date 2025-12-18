import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/design_tokens.dart';

/// Inline error widget with retry button.
/// Displays error message with icon and optional retry callback.
class InlineError extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final Color? color;
  final bool compact;

  const InlineError({
    super.key,
    required this.message,
    this.onRetry,
    this.color,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final errorColor = color ?? Colors.red.shade300;
    
    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded, color: errorColor, size: 16),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              message,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                color: errorColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onRetry,
              child: Text(
                'Retry',
                style: GoogleFonts.syne(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.cosmicPurple,
                ),
              ),
            ),
          ],
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: errorColor.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded, color: errorColor, size: 28),
          const SizedBox(height: 8),
          Text(
            message,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              color: Colors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: Text(
                'Retry',
                style: GoogleFonts.syne(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.cosmicPurple,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A simple error row for sections that failed to load.
class ErrorRow extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorRow({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: Colors.red.shade300, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Retry',
                style: GoogleFonts.syne(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.cosmicPurple,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
