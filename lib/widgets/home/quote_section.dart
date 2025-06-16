import 'package:flutter/material.dart';
import '../../services/quote_service.dart';

class QuoteSection extends StatelessWidget {
  final Future<Quote> quoteFuture;

  const QuoteSection({Key? key, required this.quoteFuture}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Quote>(
      future: quoteFuture,
      builder: (c, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Text(
            'Error loading quote',
            style: TextStyle(color: Colors.red),
          );
        }
        final q = snap.data!;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "today’s quote",
                    style: TextStyle(
                      fontFamily: 'lufga-regular',
                      fontSize: 18,
                      color: Colors.black54,
                    ),
                  ),
                  Icon(
                    Icons.format_quote_rounded,
                    size: 40,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                q.text.toLowerCase(),
                style: const TextStyle(
                  fontFamily: 'lufga-light-italic',
                  fontSize: 20,
                  color: Color(0xFF473623),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '- ${q.author}',
                style: const TextStyle(
                  fontFamily: 'lufga-semi-bold',
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
