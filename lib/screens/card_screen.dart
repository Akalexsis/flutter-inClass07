import 'package:flutter/material.dart';
import '../model/folder_model.dart';
import '../model/card_model.dart';
import '../repositories/card_repository.dart';
import 'modify_card_screen.dart';


class CardsScreen extends StatefulWidget {
  // accept folder data from Folder screen
  final Folder folder;
  const CardsScreen({super.key, required this.folder});

  @override
  _CardsScreenState createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  // initialize the card repository to perform CRUD operations
  final CardRepository _cardRepository = CardRepository();
  late final Folder folder;
  List<PlayingCard> _playingCards = []; // NOTE: Specifying "playing"Cards because we also use flutter card here as well

  @override
  void initState() {
    super.initState();
    folder = widget.folder; //initialize folder from widget+
    _loadCards();
  }

  // get all cards by folder id to render to screen
  Future<void> _loadCards() async {
    final cards = await _cardRepository.getCardsByFolderId(folder.id!);

    setState(() {
      _playingCards = cards;
    });
  }

  // allow user to delete card and ask if this is the action they want to take
  Future<void> _deleteCard(PlayingCard playingCard) async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Card?'),
        content: Text('Are you sure you want to delete "${playingCard.cardName}"? '),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _cardRepository.deleteCard(playingCard.id!);
      await _loadCards(); // update card state after deletion
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Card "${playingCard.cardName}" deleted')),
      );
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text('Card Organizer'), elevation: 0),
    body: GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: .85,
      ),
      itemCount: _playingCards.length,
      itemBuilder: (context, index) {
        final card = _playingCards[index];
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              card.imageUrl != null
                  ? Image.asset(
                      card.imageUrl!,
                      height: 64,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(_getSuitIcon(card.suit), size: 64, color: _getSuitColor(card.suit)),
                    )
                  : Icon(_getSuitIcon(card.suit), size: 64, color: _getSuitColor(card.suit)),
              SizedBox(height: 8),
              Text(
                card.cardName,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ModifyCardScreen(folder: folder, card: card),
                        ),
                      );
                      await _loadCards();
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteCard(card),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ModifyCardScreen(folder: folder),
          ),
        );
        await _loadCards();
      },
      child: Icon(Icons.add),
    ),
  );
}
  IconData _getSuitIcon(String suitName) {
    switch (suitName) {
      case 'Hearts':
        return Icons.favorite;
      case 'Diamonds':
        return Icons.change_history;
      case 'Clubs':
        return Icons.filter_vintage;
      case 'Spades':
        return Icons.eco;
      default:
        return Icons.help;
    }
  }

  Color _getSuitColor(String suitName) {
    switch (suitName) {
      case 'Hearts':
      case 'Diamonds':
        return Colors.red;
      case 'Clubs':
      case 'Spades':
        return Colors.black;
      default:
        return Colors.grey;
    }
  }
}
