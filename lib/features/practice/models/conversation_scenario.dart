enum Difficulty { easy, medium, hard }

enum Speaker { system, user }

class ConversationTurn {
  final Speaker speaker;
  final String text;

  const ConversationTurn({required this.speaker, required this.text});
}

class ConversationScenario {
  final String id;
  final String title;
  final Difficulty difficulty;
  final List<ConversationTurn> turns;

  const ConversationScenario({
    required this.id,
    required this.title,
    required this.difficulty,
    required this.turns,
  });

  int get userTurnsCount => turns.where((t) => t.speaker == Speaker.user).length;
}

const conversationScenarios = <ConversationScenario>[
  ConversationScenario(
    id: 'easy_help',
    title: 'Asking for Help',
    difficulty: Difficulty.easy,
    turns: [
      ConversationTurn(speaker: Speaker.system, text: 'Hi! Can I help you?'),
      ConversationTurn(speaker: Speaker.user, text: 'Excuse me.'),
      ConversationTurn(speaker: Speaker.system, text: 'Sure. What do you need?'),
      ConversationTurn(speaker: Speaker.user, text: 'Can you help me?'),
      ConversationTurn(speaker: Speaker.system, text: 'Okay. What is the problem?'),
      ConversationTurn(speaker: Speaker.user, text: 'I do not understand.'),
      ConversationTurn(speaker: Speaker.system, text: 'No problem. I will explain.'),
      ConversationTurn(speaker: Speaker.user, text: 'Thank you.'),
      ConversationTurn(speaker: Speaker.system, text: 'Where are you going?'),
      ConversationTurn(speaker: Speaker.user, text: 'Where is the restroom?'),
      ConversationTurn(speaker: Speaker.system, text: 'It is over there.'),
      ConversationTurn(speaker: Speaker.user, text: 'Okay, thank you.'),
      ConversationTurn(speaker: Speaker.system, text: 'Do you need anything else?'),
      ConversationTurn(speaker: Speaker.user, text: 'No, thank you.'),
      ConversationTurn(speaker: Speaker.system, text: 'Alright. Have a nice day!'),
      ConversationTurn(speaker: Speaker.user, text: 'You too.'),
      ConversationTurn(speaker: Speaker.system, text: 'Bye!'),
      ConversationTurn(speaker: Speaker.user, text: 'Goodbye.'),
      ConversationTurn(speaker: Speaker.system, text: 'See you next time!'),
      ConversationTurn(speaker: Speaker.user, text: 'See you.'),
    ],
  ),
  ConversationScenario(
    id: 'med_food',
    title: 'Ordering Food',
    difficulty: Difficulty.medium,
    turns: [
      ConversationTurn(speaker: Speaker.system, text: 'Welcome! What would you like?'),
      ConversationTurn(speaker: Speaker.user, text: 'I would like to order a chicken meal, please.'),
      ConversationTurn(speaker: Speaker.system, text: 'Would you like a drink?'),
      ConversationTurn(speaker: Speaker.user, text: 'Yes, please. A water.'),
      ConversationTurn(speaker: Speaker.system, text: 'For here or to go?'),
      ConversationTurn(speaker: Speaker.user, text: 'To go, please.'),
      ConversationTurn(speaker: Speaker.system, text: 'Anything else?'),
      ConversationTurn(speaker: Speaker.user, text: 'No, thank you.'),
      ConversationTurn(speaker: Speaker.system, text: 'That will be two hundred fifty pesos.'),
      ConversationTurn(speaker: Speaker.user, text: 'Do you accept credit cards or cash only?'),
      ConversationTurn(speaker: Speaker.system, text: 'We accept both.'),
      ConversationTurn(speaker: Speaker.user, text: 'Okay, I will pay by card.'),
      ConversationTurn(speaker: Speaker.system, text: 'Please tap your card.'),
      ConversationTurn(speaker: Speaker.user, text: 'Here you go.'),
      ConversationTurn(speaker: Speaker.system, text: 'Your order will be ready soon.'),
      ConversationTurn(speaker: Speaker.user, text: 'Thank you.'),
      ConversationTurn(speaker: Speaker.system, text: 'Here is your order.'),
      ConversationTurn(speaker: Speaker.user, text: 'Great. Have a nice day.'),
      ConversationTurn(speaker: Speaker.system, text: 'You too!'),
      ConversationTurn(speaker: Speaker.user, text: 'Goodbye.'),
    ],
  ),
  ConversationScenario(
    id: 'hard_support',
    title: 'Customer Support',
    difficulty: Difficulty.hard,
    turns: [
      ConversationTurn(speaker: Speaker.system, text: 'Hello, how can I help today?'),
      ConversationTurn(speaker: Speaker.user, text: 'I would like to report an issue with my billing statement.'),
      ConversationTurn(speaker: Speaker.system, text: 'What seems to be the problem?'),
      ConversationTurn(speaker: Speaker.user, text: 'Before we proceed, I want to confirm the total cost including fees.'),
      ConversationTurn(speaker: Speaker.system, text: 'Sure. Can you share more details?'),
      ConversationTurn(speaker: Speaker.user, text: 'I was charged twice for the same transaction.'),
      ConversationTurn(speaker: Speaker.system, text: 'When did it happen?'),
      ConversationTurn(speaker: Speaker.user, text: 'It happened yesterday around three p m.'),
      ConversationTurn(speaker: Speaker.system, text: 'Do you have a receipt or proof of payment?'),
      ConversationTurn(speaker: Speaker.user, text: 'Yes, I can provide a screenshot.'),
      ConversationTurn(speaker: Speaker.system, text: 'We will investigate and get back to you.'),
      ConversationTurn(speaker: Speaker.user, text: 'Could you explain the process step by step so I can follow?'),
      ConversationTurn(speaker: Speaker.system, text: 'First we verify the charge, then we issue a refund if needed.'),
      ConversationTurn(speaker: Speaker.user, text: 'How long will the refund usually take?'),
      ConversationTurn(speaker: Speaker.system, text: 'Three to five business days.'),
      ConversationTurn(speaker: Speaker.user, text: 'Okay, I understand.'),
      ConversationTurn(speaker: Speaker.system, text: 'Is there anything else I can help with?'),
      ConversationTurn(speaker: Speaker.user, text: 'I appreciate your help. Thank you.'),
      ConversationTurn(speaker: Speaker.system, text: 'You are welcome. Have a good day.'),
      ConversationTurn(speaker: Speaker.user, text: 'You too. Goodbye.'),
    ],
  ),
];
