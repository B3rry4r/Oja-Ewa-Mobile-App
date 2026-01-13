import 'package:flutter/foundation.dart';

@immutable
class FaqItem {
  const FaqItem({required this.id, required this.question, required this.answer});

  final int id;
  final String question;
  final String answer;

  static FaqItem fromJson(Map<String, dynamic> json) {
    return FaqItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      question: (json['question'] as String?) ?? '',
      answer: (json['answer'] as String?) ?? '',
    );
  }
}
