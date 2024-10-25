class Answer {
  final int? id;
  final String text;
  final bool correct;

  Answer({
    this.id,
    required this.text,
    required this.correct,
  });

  toJson() {
    return {
      'text': text,
      'correct': correct,
    };
  }
}
