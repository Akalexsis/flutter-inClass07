import 'package:flutter/material.dart';
import '../model/folder_model.dart';
import '../model/card_model.dart';
import '../repositories/card_repository.dart';

class ModifyCardScreen extends StatefulWidget {
  final Folder folder;
  final PlayingCard? card;

  const ModifyCardScreen({super.key, required this.folder, this.card});

  @override
  _ModifyCardScreenState createState() => _ModifyCardScreenState();
}

class _ModifyCardScreenState extends State<ModifyCardScreen> {
  final CardRepository _cardRepository = CardRepository();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late String _selectedSuit;

  final List<String> _suits = ['Hearts', 'Diamonds', 'Clubs', 'Spades'];

  bool get _isEditing => widget.card != null;

  // generates asset path from card name + suit
  String _buildImageUrl(String cardName, String suit) {
    const valueMap = {
      'Ace': 'A',
      '2': '2',
      '3': '3',
      '4': '4',
      '5': '5',
      '6': '6',
      '7': '7',
      '8': '8',
      '9': '9',
      '10': '0',
      'Jack': 'J',
      'Queen': 'Q',
      'King': 'K',
    };
    const suitMap = {
      'Hearts': 'H',
      'Diamonds': 'D',
      'Clubs': 'C',
      'Spades': 'S',
    };

    final value = valueMap[cardName] ?? cardName;
    final suitCode = suitMap[suit] ?? suit;
    return 'assets/cards/$value$suitCode.png';
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.card?.cardName ?? '');
    _selectedSuit = widget.card?.suit ?? widget.folder.folderName;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

 Future<void> _save() async {
  if (!_formKey.currentState!.validate()) return;

  final cardName = _nameController.text.trim();
  final imageUrl = _buildImageUrl(cardName, _selectedSuit);

  // map suit name to its folder id
  const suitFolderMap = {
    'Hearts': 1,
    'Diamonds': 2,
    'Clubs': 3,
    'Spades': 4,
  };
  final newFolderId = suitFolderMap[_selectedSuit]!;

  if (_isEditing) {
    final updated = widget.card!.copyWith(
      cardName: cardName,
      suit: _selectedSuit,
      imageUrl: imageUrl,
      folderId: newFolderId,  // update folder too
    );
    await _cardRepository.updateCard(updated);
  } else {
    final newCard = PlayingCard(
      cardName: cardName,
      suit: _selectedSuit,
      imageUrl: imageUrl,
      folderId: newFolderId,  // use mapped folder
    );
    await _cardRepository.insertCard(newCard);
  }

  if (!mounted) return;
  Navigator.pop(context);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // add this line
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Card' : 'Add Card'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Card Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter a card name'
                    : null,
              ),
              SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedSuit,
                decoration: InputDecoration(
                  labelText: 'Suit',
                  border: OutlineInputBorder(),
                ),
                items: _suits
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedSuit = value!),
              ),
              SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _save,
                      child: Text(_isEditing ? 'Save Changes' : 'Add Card'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
