class PracticePrompt {
  final String id;
  final String text;
  final bool isPhrase;

  const PracticePrompt({required this.id, required this.text, required this.isPhrase});
}

const defaultPrompts = <PracticePrompt>[
  PracticePrompt(id: 'w1', text: 'pronunciation', isPhrase: false),
  PracticePrompt(id: 'w2', text: 'comfortable', isPhrase: false),
  PracticePrompt(id: 'w3', text: 'development', isPhrase: false),
  PracticePrompt(id: 'p1', text: 'I want to improve my pronunciation', isPhrase: true),
  PracticePrompt(id: 'p2', text: 'Please speak clearly and confidently', isPhrase: true),
  PracticePrompt(id: 'p3', text: 'Today I will practice my English', isPhrase: true),
];
