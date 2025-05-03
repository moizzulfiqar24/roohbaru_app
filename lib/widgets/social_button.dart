import 'package:flutter/material.dart';

class SocialButton extends StatelessWidget {
  final String assetPath;
  final VoidCallback? onTap;

  const SocialButton({
    super.key,
    required this.assetPath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300, width: 1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Image.asset(assetPath, height: 24, width: 24),
          ),
        ),
      ),
    );
  }
}
