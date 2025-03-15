import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carousel_slider/carousel_slider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wallet Page',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        brightness: Brightness.dark,
        fontFamily: 'Roboto',
        visualDensity: VisualDensity.adaptivePlatformDensity,
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

  List<Map<String, String>> _savedCards = [];

  @override
  void initState() {
    super.initState();
    _loadSavedCards();
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderNameController.dispose();
    _ccvController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedCards() async {
    final prefs = await SharedPreferences.getInstance();
    int cardCount = prefs.getInt('cardCount') ?? 0;
    List<Map<String, String>> loadedCards = [];

    for (int i = 0; i < cardCount; i++) {
      String? cardNumber = prefs.getString('cardNumber_$i');
      if (cardNumber != null) {
        loadedCards.add({
          'cardNumber': cardNumber,
          'cardHolderName': prefs.getString('cardHolderName_$i') ?? '',
          'expiryDate': prefs.getString('expiryDate_$i') ?? '',
          'ccv': prefs.getString('ccv_$i') ?? ''
        });
      }
    }
    setState(() {
      _savedCards = loadedCards;
    });
  }

  Future<void> _saveCardDetails(BuildContext modalContext) async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      int cardCount = prefs.getInt('cardCount') ?? 0;

      await prefs.setString('cardNumber_$cardCount', _cardNumberController.text.replaceAll(' ', ''));
      await prefs.setString('cardHolderName_$cardCount', _cardHolderNameController.text);
      await prefs.setString('expiryDate_$cardCount', '$_selectedMonth/$_selectedYear');
      await prefs.setString('ccv_$cardCount', _ccvController.text); //save ccv form

      setState(() {
        _savedCards.add({
          'cardNumber': _cardNumberController.text.replaceAll(' ', ''),
          'cardHolderName': _cardHolderNameController.text,
          'expiryDate': '$_selectedMonth/$_selectedYear',
          'ccv':  _ccvController.text,
        });
      });

      _cardNumberController.clear();
      _cardHolderNameController.clear();
      _ccvController.clear();

      _selectedMonth = null;
      _selectedYear = null;


      ScaffoldMessenger.of(modalContext).showSnackBar( //Use snackbar here as well

        SnackBar(content: Text('Card details saved successfully!', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.green),
      );

      Navigator.pop(modalContext); // Close the modal sheet if its valid
    }
  }

  Future<void> _deleteCard(int index) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Delete"),
          content: Text("Are you sure you want to delete this card?"),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Delete"),
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog

                final prefs = await SharedPreferences.getInstance();
                int cardCount = prefs.getInt('cardCount') ?? 0;

                // Shift cards after the deleted index
                for (int i = index; i < cardCount - 1; i++) {
                  await prefs.setString('cardNumber_$i', prefs.getString('cardNumber_${i + 1}') ?? '');
                  await prefs.setString('cardHolderName_$i', prefs.getString('cardHolderName_${i + 1}') ?? '');
                  await prefs.setString('expiryDate_$i', prefs.getString('expiryDate_${i + 1}') ?? '');
                  await prefs.setString('ccv_$i', prefs.getString('ccv_${i + 1}') ?? ''); // also shift ccv here

                }

                // Remove the last card's data
                await prefs.remove('cardNumber_${cardCount - 1}');
                await prefs.remove('cardHolderName_${cardCount - 1}');
                await prefs.remove('expiryDate_${cardCount - 1}');
                await prefs.remove('ccv_${cardCount - 1}'); //remvoe form last one

                await prefs.setInt('cardCount', cardCount - 1);

                setState(() {
                  _loadSavedCards(); // Refresh the card list
                });
              },
            ),
          ],
        );
      },
    );
  }

  String _formatCardNumber(String input) {
    input = input.replaceAll(RegExp(r'\s+'), '');
    if (input.length > 16) {
      input = input.substring(0, 16);
    }
    String formatted = '';
    for (int i = 0; i < input.length; i++) {
      if (i > 0 && i % 4 == 0) {
        formatted += ' ';
      }
      formatted += input[i];
    }
    return formatted;
  }

  String _maskCardNumber(String cardNumber) {
    String maskedNumber = '';
    if (cardNumber.length == 16) {
      maskedNumber = '**** **** **** ${cardNumber.substring(12)}';
    }
    return maskedNumber;
  }

  void _onCardNumberChanged(String value) {
    final cursorPosition = _cardNumberController.selection.base.offset;

    final formattedValue = _formatCardNumber(value);

    _cardNumberController.value = TextEditingValue(
      text: formattedValue,
      selection: TextSelection.collapsed(
        offset: cursorPosition + (formattedValue.length - value.length),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.orange,
          elevation: 0,
          title: Text('Wallet', style: TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                showGeneralDialog(
                  context: context,
                  barrierLabel: "Add Card",
                  barrierDismissible: true,
                  transitionDuration: Duration(milliseconds: 200),
                  barrierColor: Colors.black.withOpacity(0.5),
                  pageBuilder: (BuildContext context, Animation animation, Animation secondaryAnimation) {
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        return SafeArea(
                          child: Align(
                            alignment: Alignment.center,
                            child: Material(
                              color: Colors.transparent,
                              child: Container(
                                width: constraints.maxWidth * 0.8,
                                height: constraints.maxHeight * 0.7,
                                decoration: BoxDecoration(
                                  color: Colors.grey[900],
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                padding: const EdgeInsets.all(16.0),
                                child: SingleChildScrollView(
                                  child: _buildAddCardForm(context), // Pass context to _buildAddCardForm
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
        backgroundColor: Colors.orange[100],
        body: Padding(
          padding: const EdgeInsets.only(top: 24.0), // Add top padding here (the space)
          child: _savedCards.isNotEmpty
              ? CarouselSlider(
              options: CarouselOptions(
                height: MediaQuery.of(context).size.height * 0.3, // 30% of screen height
                aspectRatio: 16 / 9,
                viewportFraction: 0.8, // Show 80% of the card at a time
                initialPage: 0,
                enableInfiniteScroll: false,
                reverse: false,
                autoPlay: false,
                enlargeCenterPage: true,
              ),
              items: _savedCards.map((card) {
                return Builder(
                  builder: (BuildContext context) {
                    return _buildSavedCardView(card, _savedCards.indexOf(card));
                  },
                );
              }).toList())
              : Center(
              child: Text("Please add a card", style: TextStyle(color: Colors.white))),
        )

    );
  }

  //CCV form addition
  Widget _buildAddCardForm(BuildContext modalContext) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _cardNumberController,
              decoration: InputDecoration(
                labelText: 'Card Number',
                hintText: '4444 3333 2222 1111',
                labelStyle: TextStyle(color: Colors.white70),
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
              ),
              style: TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              maxLength: 19,
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
            SizedBox(height: 12),
            TextFormField(
              controller: _cardHolderNameController,
              decoration: InputDecoration(
                labelText: 'Card Holder Name',
                labelStyle: TextStyle(color: Colors.white70),
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
              ),
              style: TextStyle(color: Colors.white),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the card holder name';
                }
                return null;
              },
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedMonth,
                    decoration: InputDecoration(
                      labelText: 'Expiry Month',
                      labelStyle: TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
                    ),
                    dropdownColor: Colors.grey[800],
                    style: TextStyle(color: Colors.white),
                    items: months.map((month) {
                      return DropdownMenuItem(
                        value: month,
                        child: Text(month, style: TextStyle(color: Colors.white)),
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
                      labelStyle: TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
                    ),
                    dropdownColor: Colors.grey[800],
                    style: TextStyle(color: Colors.white),
                    items: years.map((year) {
                      return DropdownMenuItem(
                        value: year,
                        child: Text(year, style: TextStyle(color: Colors.white)),
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
            SizedBox(height: 12),
            TextFormField(
              controller: _ccvController,
              decoration: InputDecoration(
                labelText: 'CCV',
                labelStyle: TextStyle(color: Colors.white70),
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
              ),
              style: TextStyle(color: Colors.white),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => _saveCardDetails(modalContext),
              child: Text('Save Card', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedCardView(Map<String, String> card, int index) {
    String cardNumber = card['cardNumber'] ?? '';
    String maskedCardNumber = _maskCardNumber(cardNumber);
    String ccv = card['ccv'] ?? "";

    return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: Colors.orange[700],
        ),
        padding: EdgeInsets.all(20.0),
        child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${card['cardHolderName']!}',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    maskedCardNumber,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Expiry Date: ${card['expiryDate']!}',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),

              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: Icon(Icons.delete, color: Colors.white70),
                  onPressed: () {
                    _deleteCard(index);
                  },
                ),
              ),
            ]));
  }
}