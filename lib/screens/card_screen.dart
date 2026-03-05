import 'package:flutter/material.dart';
import '../model/folder_model.dart';
import '../model/card_model.dart';
import '../repositories/card_repository.dart';
import 'modify_card_screen.dart';
import '../screens/delete_confirmation.dart';


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
  List _cards = [];

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  // get all cards by folder id to render to screen
  Future _loadCards() async {
    final cards = await _cardRepository.getCardsByFolderId(folder.id!);

    setState(() {
      _cards = cards;
    });
  }

  // allow user to delete card and ask if this is the action they want to take
  Future _deleteCard(Card card) async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Card?'),
        content: Text(
          'Are you sure you want to delete "${card.cardName}"? '
        ),
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
      await _cardRepository.deleteCard(card.id!);
      _loadCards(); // update card state after deletion
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Card "${card.cardName}" deleted')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Card Organizer'),
        elevation: 0,
      ),
      body: GridView.builder( // display all cards to screen as a card
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
        ),
        itemCount: _cards.length,
        itemBuilder: (context, index) {
          final card = _cards[index];
          
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getSuitIcon(card.cardName),
                  size: 64,
                  color: _getSuitColor(card.cardName),
                ),
                SizedBox(height: 8),
                Text(
                  folder.folderName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                  SizedBox(height: 8),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteCard(card),
                  ),
                ],
              ),
            );
          }
        ),
      );
  }

  IconData _getSuitIcon(String suitName) {
    switch (suitName) {
      case 'Hearts': return Icons.favorite;
      case 'Diamonds': return Icons.change_history;
      case 'Clubs': return Icons.filter_vintage;
      case 'Spades': return Icons.eco;
      default: return Icons.help;
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