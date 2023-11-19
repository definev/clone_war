const challengeData = [
  ChallengeData(
    '1',
    'Grid challenge',
    'Grid challenge is a two-dimensional grid layout challenge',
  ),
  ChallengeData(
    '2',
    'Bubble challenge',
    'Bubble challenge modal effect',
  ),
  ChallengeData(
    '3',
    'Riveo page curl challenge',
    'An animation simulating the turning of a physical page, adding depth and interactivity to digital content.',
  ),
  ChallengeData(
    '4',
    'Shader art coding tutorial',
    'Shader art coding tutorial is a tutorial on how to create a shader art coding effect.',
  ),
  ChallengeData(
    '5',
    'Spring card challenge',
    'Spring card challenge introduce an ergonomic way to interact with a card.',
  ),
  ChallengeData(
    '6',
    'Custom render object',
    'Follow the tutorial to create a custom render object from Flutter team',
  ),
];

class ChallengeData {
  const ChallengeData(this.id, this.title, this.description);

  final String id;
  final String title;
  final String description;
}
