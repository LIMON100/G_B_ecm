import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wallet Page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WalletPage(),
    );
  }
}

class WalletPage extends StatefulWidget {
  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cardHolderNameController = TextEditingController();
  final _ccvController = TextEditingController();
  String? _selectedMonth;
  String? _selectedYear;

  List<String> months = List.generate(12, (index) => (index + 1).toString().padLeft(2, '0'));
  List<String> years = List.generate(10, (index) => (DateTime.now().year + index).toString());

  // Variable to store saved card details
  Map<String, String>? _savedCard;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderNameController.dispose();
    _ccvController.dispose();
    super.dispose();
  }

  void _saveCardDetails() {
    if (_formKey.currentState!.validate()) {
      // Save card details locally
      setState(() {
        _savedCard = {
          'cardNumber': _cardNumberController.text.replaceAll(' ', ''),
          'cardHolderName': _cardHolderNameController.text,
          'expiryDate': '$_selectedMonth/$_selectedYear',
          'ccv': _ccvController.text,
        };
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Card details saved successfully!')),
      );
    }
  }

  String _formatCardNumber(String input) {
    // Remove all non-digit characters
    input = input.replaceAll(RegExp(r'[^0-9]'), '');
    // Limit to 16 digits
    if (input.length > 16) {
      input = input.substring(0, 16);
    }
    // Add a space after every 4 digits
    String formatted = '';
    for (int i = 0; i < input.length; i++) {
      if (i > 0 && i % 4 == 0) {
        formatted += ' ';
      }
      formatted += input[i];
    }
    return formatted;
  }

  void _onCardNumberChanged(String value) {
    // Get the current cursor position
    final cursorPosition = _cardNumberController.selection.base.offset;

    // Format the card number
    final formattedValue = _formatCardNumber(value);

    // Update the text and cursor position
    _cardNumberController.value = TextEditingValue(
      text: formattedValue,
      selection: TextSelection.collapsed(
        offset: cursorPosition + (formattedValue.length - value.length),
      ),
    );
  }

  void _navigateToAddCard() {
    // Clear the form and navigate to the add card screen
    _cardNumberController.clear();
    _cardHolderNameController.clear();
    _ccvController.clear();
    _selectedMonth = null;
    _selectedYear = null;

    setState(() {
      _savedCard = null; // Reset saved card to show the form
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.orange,
        title: Text('Wallet'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _savedCard == null
            ? _buildAddCardForm() // Show the add card form if no card is saved
            : _buildSavedCardView(), // Show the saved card details if a card is saved
      ),
    );
  }

  Widget _buildAddCardForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _cardNumberController,
            decoration: InputDecoration(
              labelText: 'Card Number',
              hintText: '4444 3333 2222 1111',
            ),
            keyboardType: TextInputType.number,
            maxLength: 19, // 16 digits + 3 spaces
            onChanged: _onCardNumberChanged,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a card number';
              }
              if (value.replaceAll(' ', '').length != 16) {
                return 'Card number must be 16 digits';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _cardHolderNameController,
            decoration: InputDecoration(
              labelText: 'Card Holder Name',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the card holder name';
              }
              return null;
            },
          ),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedMonth,
                  decoration: InputDecoration(
                    labelText: 'Expiry Month',
                  ),
                  items: months.map((month) {
                    return DropdownMenuItem(
                      value: month,
                      child: Text(month),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedMonth = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a month';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedYear,
                  decoration: InputDecoration(
                    labelText: 'Expiry Year',
                  ),
                  items: years.map((year) {
                    return DropdownMenuItem(
                      value: year,
                      child: Text(year),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedYear = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a year';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          TextFormField(
            controller: _ccvController,
            decoration: InputDecoration(
              labelText: 'CCV',
            ),
            keyboardType: TextInputType.number,
            maxLength: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the CCV';
              }
              if (value.length != 3) {
                return 'CCV must be 3 digits';
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _saveCardDetails,
            child: Text('Save Card'),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedCardView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Card Number: ${_savedCard!['cardNumber']}'),
        Text('Card Holder Name: ${_savedCard!['cardHolderName']}'),
        Text('Expiry Date: ${_savedCard!['expiryDate']}'),
        Text('CCV: ${_savedCard!['ccv']}'),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: _navigateToAddCard,
          child: Text('Add New Card'),
        ),
      ],
    );
  }
}