class Card{
  final int id;
  final String cardName;
  final String suit;
  final String url;
  final int folderId;

  const Card({ 
    required this.id, 
    required this.cardName, 
    required this.suit,
    required this.url,
    required this.folderId
  });
}