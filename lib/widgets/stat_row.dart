import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  const StatRow({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (color ?? Theme.of(context).colorScheme.primary).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color ?? Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color ?? Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}