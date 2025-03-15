// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:carousel_slider/carousel_slider.dart'; // Import CarouselSlider
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Wallet',
//       theme: ThemeData(
//         primarySwatch: Colors.deepPurple,
//         brightness: Brightness.dark,
//         fontFamily: 'Roboto',
//         visualDensity: VisualDensity.adaptivePlatformDensity,  // Make UI more adaptive
//       ),
//       home: WalletPage(),
//     );
//   }
// }
//
// class WalletPage extends StatefulWidget {
//   @override
//   _WalletPageState createState() => _WalletPageState();
// }
//
// class _WalletPageState extends State<WalletPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _cardNumberController = TextEditingController();
//   final _cardHolderNameController = TextEditingController();
//   final _ccvController = TextEditingController();
//   String? _selectedMonth;
//   String? _selectedYear;
//
//   List<String> months = List.generate(12, (index) => (index + 1).toString().padLeft(2, '0'));
//   List<String> years = List.generate(10, (index) => (DateTime.now().year + index).toString());
//
//   List<Map<String, String>> _savedCards = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _loadSavedCards(); // Load saved cards on startup
//   }
//
//   @override
//   void dispose() {
//     _cardNumberController.dispose();
//     _cardHolderNameController.dispose();
//     _ccvController.dispose();
//     super.dispose();
//   }
//
//   // Load from SharedPreferences
//   Future<void> _loadSavedCards() async {
//     final prefs = await SharedPreferences.getInstance();
//     int cardCount = prefs.getInt('cardCount') ?? 0;
//     List<Map<String, String>> loadedCards = [];
//
//     for (int i = 0; i < cardCount; i++) {
//       String? cardNumber = prefs.getString('cardNumber_$i');
//       if (cardNumber != null) {
//         loadedCards.add({
//           'cardNumber': cardNumber,
//           'cardHolderName': prefs.getString('cardHolderName_$i') ?? '',
//           'expiryDate': prefs.getString('expiryDate_$i') ?? '',
//         });
//       }
//     }
//     setState(() {
//       _savedCards = loadedCards;
//     });
//   }
//
//   //Save to Shared Preferences
//   Future<void> _saveCardDetails() async {
//     if (_formKey.currentState!.validate()) {
//       final prefs = await SharedPreferences.getInstance();
//       int cardCount = prefs.getInt('cardCount') ?? 0;
//
//       //Save every value with custom index to not overlap later on
//       await prefs.setString('cardNumber_$cardCount', _cardNumberController.text.replaceAll(' ', ''));
//       await prefs.setString('cardHolderName_$cardCount', _cardHolderNameController.text);
//       await prefs.setString('expiryDate_$cardCount', '$_selectedMonth/$_selectedYear');
//       await prefs.setInt('cardCount', cardCount + 1);
//
//       setState(() {
//         _savedCards.add({
//           'cardNumber': _cardNumberController.text.replaceAll(' ', ''),
//           'cardHolderName': _cardHolderNameController.text,
//           'expiryDate': '$_selectedMonth/$_selectedYear',
//         });
//       });
//
//       //Clear every text field from before
//       _cardNumberController.clear();
//       _cardHolderNameController.clear();
//       _selectedMonth = null;
//       _selectedYear = null;
//
//       Navigator.pop(context);
//       ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Card details saved successfully!', style: TextStyle(color: Colors.white)),
//               backgroundColor: Colors.green));
//     }
//   }
//
//   //Delete card method
//   Future<void> _deleteCard(int index) async {
//     final prefs = await SharedPreferences.getInstance();
//     int cardCount = prefs.getInt('cardCount') ?? 0;
//
//     // Remove data of deleted card, shift card down so there is no spacing
//     for (int i = index; i < cardCount - 1; i++) {
//       await prefs.setString('cardNumber_$i', prefs.getString('cardNumber_${i+1}') ?? '');
//       await prefs.setString('cardHolderName_$i', prefs.getString('cardHolderName_${i+1}') ?? '');
//       await prefs.setString('expiryDate_$i', prefs.getString('expiryDate_${i+1}') ?? '');
//     }
//     //Remove last card as well
//     await prefs.remove('cardNumber_${cardCount - 1}');
//     await prefs.remove('cardHolderName_${cardCount - 1}');
//     await prefs.remove('expiryDate_${cardCount - 1}');
//     await prefs.setInt('cardCount', cardCount - 1);
//
//     _loadSavedCards(); //Load updated sharedprefs data, fix index issue where it can't display anymore
//   }
//
//   //Function for formatting the card
//   String _formatCardNumber(String input) {
//     input = input.replaceAll(RegExp(r'\s+'), ''); // Remove non-digit
//     if (input.length > 16) {
//       input = input.substring(0, 16); //To not crash everything by not allowing over 16
//     }
//     String formatted = '';
//     for (int i = 0; i < input.length; i++) {
//       if (i > 0 && i % 4 == 0) {
//         formatted += ' ';
//       }
//       formatted += input[i];
//     }
//     return formatted;
//   }
//
//   String _maskCardNumber(String cardNumber) {
//     String maskedNumber = '';
//     if (cardNumber.length == 16) {
//       maskedNumber = '**** **** **** ${cardNumber.substring(12)}';
//     }
//     return maskedNumber;
//   }
//
//   //Set selection so the numbers doesn't overlap each other when formatting the card
//   void _onCardNumberChanged(String value) {
//     final cursorPosition = _cardNumberController.selection.base.offset;
//
//     final formattedValue = _formatCardNumber(value);
//
//     _cardNumberController.value = TextEditingValue(
//       text: formattedValue,
//       selection: TextSelection.collapsed(
//         offset: cursorPosition + (formattedValue.length - value.length),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           centerTitle: true,
//           backgroundColor: Colors.deepPurpleAccent,
//           elevation: 0,
//           title: Text('Wallet', style: TextStyle(fontWeight: FontWeight.bold)),
//           actions: [
//             IconButton(
//               icon: Icon(Icons.add),
//               onPressed: () {
//                 showModalBottomSheet( //I use showModal so I can dismiss and re-render, if you are confused try different way to present the form without navigator
//                     context: context,
//                     isScrollControlled: true, //So I can see every value in form, I see that some people have trouble so I set it to true
//                     builder: (BuildContext context) {
//                       return Container(
//                         decoration: BoxDecoration(
//                             borderRadius: BorderRadius.only(
//                               topLeft: Radius.circular(20.0),
//                               topRight: Radius.circular(20.0),
//                             ),
//                             color: Colors.grey[900]), //Dark theme,
//                         padding: EdgeInsets.only(
//                           bottom: MediaQuery.of(context).viewInsets.bottom,
//                         ), //So keyboard doesn't overlap
//                         child: Padding(
//                           padding: const EdgeInsets.all(16.0),
//                           child: _buildAddCardForm(),
//                         ),
//                       );
//                     });
//               },
//             ),
//           ],
//         ),
//         backgroundColor: Colors.black,
//         body: _savedCards.isNotEmpty
//             ? CarouselSlider(
//             options: CarouselOptions(
//               height: MediaQuery.of(context).size.height * 0.3, // 30% of screen height
//               aspectRatio: 16 / 9,
//               viewportFraction: 0.8, // Show 80% of the card at a time
//               initialPage: 0,
//               enableInfiniteScroll: false,
//               reverse: false,
//               autoPlay: false,
//               enlargeCenterPage: true,
//             ),
//             items: _savedCards.map((card) {
//               return Builder(
//                 builder: (BuildContext context) {
//                   return _buildSavedCardView(card, _savedCards.indexOf(card)); // Pass also index so I know which card to delete
//                 },
//               );
//             }).toList())
//             : Center(
//             child: Text("Please add a card", style: TextStyle(color: Colors.white)))
//
//     );
//   }
//
//   //Create the Add card form that popup to add cards
//   Widget _buildAddCardForm() {
//     return Card(
//       elevation: 8,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       color: Colors.grey[900],
//       child: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               TextFormField(
//                 controller: _cardNumberController,
//                 decoration: InputDecoration(
//                   labelText: 'Card Number',
//                   hintText: '4444 3333 2222 1111',
//                   labelStyle: TextStyle(color: Colors.white70),
//                   hintStyle: TextStyle(color: Colors.grey),
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                   focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.deepPurpleAccent)),
//                 ),
//                 style: TextStyle(color: Colors.white),
//                 keyboardType: TextInputType.number,
//                 maxLength: 19,
//                 onChanged: _onCardNumberChanged,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a card number';
//                   }
//                   if (value.replaceAll(' ', '').length != 16) {
//                     return 'Card number must be 16 digits';
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(height: 12),
//               TextFormField(
//                 controller: _cardHolderNameController,
//                 decoration: InputDecoration(
//                   labelText: 'Card Holder Name',
//                   labelStyle: TextStyle(color: Colors.white70),
//                   hintStyle: TextStyle(color: Colors.grey),
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                   focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.deepPurpleAccent)),
//                 ),
//                 style: TextStyle(color: Colors.white),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter the card holder name';
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(height: 12),
//               Row(
//                 children: [
//                   Expanded(
//                     child: DropdownButtonFormField<String>(
//                       value: _selectedMonth,
//                       decoration: InputDecoration(
//                         labelText: 'Expiry Month',
//                         labelStyle: TextStyle(color: Colors.white70),
//                         border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                         focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.deepPurpleAccent)),
//                       ),
//                       dropdownColor: Colors.grey[800],
//                       style: TextStyle(color: Colors.white),
//                       items: months.map((month) {
//                         return DropdownMenuItem(
//                           value: month,
//                           child: Text(month, style: TextStyle(color: Colors.white)),
//                         );
//                       }).toList(),
//                       onChanged: (value) {
//                         setState(() {
//                           _selectedMonth = value;
//                         });
//                       },
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please select a month';
//                         }
//                         return null;
//                       },
//                     ),
//                   ),
//                   SizedBox(width: 16),
//                   Expanded(
//                     child: DropdownButtonFormField<String>(
//                       value: _selectedYear,
//                       decoration: InputDecoration(
//                         labelText: 'Expiry Year',
//                         labelStyle: TextStyle(color: Colors.white70),
//                         border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                         focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.deepPurpleAccent)),
//                       ),
//                       dropdownColor: Colors.grey[800],
//                       style: TextStyle(color: Colors.white),
//                       items: years.map((year) {
//                         return DropdownMenuItem(
//                           value: year,
//                           child: Text(year, style: TextStyle(color: Colors.white)),
//                         );
//                       }).toList(),
//                       onChanged: (value) {
//                         setState(() {
//                           _selectedYear = value;
//                         });
//                       },
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please select a year';
//                         }
//                         return null;
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.deepPurpleAccent,
//                   padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
//                   textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                 ),
//                 onPressed: _saveCardDetails,
//                 child: Text('Save Card', style: TextStyle(color: Colors.white)),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSavedCardView(Map<String, String> card, int index) { //Get back what I needed from shared prefs data
//     String cardNumber = card['cardNumber'] ?? '';
//     String maskedCardNumber = _maskCardNumber(cardNumber);
//
//     return Container(
//         width: double.infinity,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(20.0),
//           color: Colors.deepPurple[400], // Match the example's card color
//         ),
//         padding: EdgeInsets.all(20.0),
//         child: Stack( //I use stack so I can place item in top, but this isn't really needed
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Card Holder Name: ${card['cardHolderName']!}', // I set cardHolder name
//                     style: TextStyle(
//                       color: Colors.white70,
//                       fontSize: 16.0,
//                       fontWeight: FontWeight.w400,
//                     ),
//                   ),
//                   SizedBox(height: 8.0),
//                   Text(
//                     maskedCardNumber, //I call back mast code from before and put it
//                     style: TextStyle(
//                       color: Colors.white70,
//                       fontSize: 16.0,
//                       fontWeight: FontWeight.w400,
//                     ),
//                   ),
//                   SizedBox(height: 8.0),
//                   Text(
//                     'Expiry Date: ${card['expiryDate']!}', //I put expiry date here
//                     style: TextStyle(
//                       color: Colors.white70,
//                       fontSize: 16.0,
//                       fontWeight: FontWeight.w400,
//                     ),
//                   ),
//                 ],
//               ),
//
//               Positioned( //I use position so I can place element in specific spot
//                 top: 0,
//                 right: 0,
//                 child: IconButton( //I made a delete button here
//                   icon: Icon(Icons.delete, color: Colors.white70),
//                   onPressed: () {
//                     _deleteCard(index); //Call delete function from top code
//                   },
//                 ),
//               ),
//             ]));
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carousel_slider/carousel_slider.dart'; // Import CarouselSlider

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wallet Page',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        brightness: Brightness.dark,
        fontFamily: 'Roboto',
        visualDensity: VisualDensity.adaptivePlatformDensity,  // Make UI more adaptive
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
    _loadSavedCards(); // Load saved cards on startup
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderNameController.dispose();
    _ccvController.dispose();
    super.dispose();
  }

  // Load from SharedPreferences
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
        });
      }
    }
    setState(() {
      _savedCards = loadedCards;
    });
  }

  //Save to Shared Preferences
  Future<void> _saveCardDetails() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      int cardCount = prefs.getInt('cardCount') ?? 0;

      //Save every value with custom index to not overlap later on
      await prefs.setString('cardNumber_$cardCount', _cardNumberController.text.replaceAll(' ', ''));
      await prefs.setString('cardHolderName_$cardCount', _cardHolderNameController.text);
      await prefs.setString('expiryDate_$cardCount', '$_selectedMonth/$_selectedYear');
      await prefs.setInt('cardCount', cardCount + 1);

      setState(() {
        _savedCards.add({
          'cardNumber': _cardNumberController.text.replaceAll(' ', ''),
          'cardHolderName': _cardHolderNameController.text,
          'expiryDate': '$_selectedMonth/$_selectedYear',
        });
      });

      //Clear every text field from before
      _cardNumberController.clear();
      _cardHolderNameController.clear();
      _selectedMonth = null;
      _selectedYear = null;

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Card details saved successfully!', style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.green));
    }
  }

  //Delete card method
  Future<void> _deleteCard(int index) async {
    final prefs = await SharedPreferences.getInstance();
    int cardCount = prefs.getInt('cardCount') ?? 0;

    // Remove data of deleted card, shift card down so there is no spacing
    for (int i = index; i < cardCount - 1; i++) {
      await prefs.setString('cardNumber_$i', prefs.getString('cardNumber_${i+1}') ?? '');
      await prefs.setString('cardHolderName_$i', prefs.getString('cardHolderName_${i+1}') ?? '');
      await prefs.setString('expiryDate_$i', prefs.getString('expiryDate_${i+1}') ?? '');
    }
    //Remove last card as well
    await prefs.remove('cardNumber_${cardCount - 1}');
    await prefs.remove('cardHolderName_${cardCount - 1}');
    await prefs.remove('expiryDate_${cardCount - 1}');
    await prefs.setInt('cardCount', cardCount - 1);

    _loadSavedCards(); //Load updated sharedprefs data, fix index issue where it can't display anymore
  }

  //Function for formatting the card
  String _formatCardNumber(String input) {
    input = input.replaceAll(RegExp(r'\s+'), ''); // Remove non-digit
    if (input.length > 16) {
      input = input.substring(0, 16); //To not crash everything by not allowing over 16
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

  //Set selection so the numbers doesn't overlap each other when formatting the card
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
          backgroundColor: Colors.deepPurpleAccent,
          elevation: 0,
          title: Text('Wallet', style: TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                showModalBottomSheet( //I use showModal so I can dismiss and re-render, if you are confused try different way to present the form without navigator
                    context: context,
                    isScrollControlled: true, //So I can see every value in form, I see that some people have trouble so I set it to true
                    builder: (BuildContext context) {
                      return Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20.0),
                              topRight: Radius.circular(20.0),
                            ),
                            color: Colors.grey[900]), //Dark theme,
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ), //So keyboard doesn't overlap
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: _buildAddCardForm(),
                        ),
                      );
                    });
              },
            ),
          ],
        ),
        backgroundColor: Colors.black,
        body: _savedCards.isNotEmpty
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
                  return _buildSavedCardView(card, _savedCards.indexOf(card)); // Pass also index so I know which card to delete
                },
              );
            }).toList())
            : Center(
            child: Text("Please add a card", style: TextStyle(color: Colors.white)))

    );
  }

  //Create the Add card form that popup to add cards
  Widget _buildAddCardForm() {
    return  Padding(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _cardNumberController,
              decoration: InputDecoration(
                labelText: 'Card Number',
                hintText: '4444 3333 2222 1111',
                labelStyle: TextStyle(color: Colors.white70),
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.deepPurpleAccent)),
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
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.deepPurpleAccent)),
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
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.deepPurpleAccent)),
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
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.deepPurpleAccent)),
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
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: _saveCardDetails,
              child: Text('Save Card', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedCardView(Map<String, String> card, int index) { //Get back what I needed from shared prefs data
    String cardNumber = card['cardNumber'] ?? '';
    String maskedCardNumber = _maskCardNumber(cardNumber);

    return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: Colors.deepPurple[400], // Match the example's card color
        ),
        padding: EdgeInsets.all(20.0),
        child: Stack( //I use stack so I can place item in top, but this isn't really needed
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Card Holder Name: ${card['cardHolderName']!}', // I set cardHolder name
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    maskedCardNumber, //I call back mast code from before and put it
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Expiry Date: ${card['expiryDate']!}', //I put expiry date here
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),

              Positioned( //I use position so I can place element in specific spot
                top: 0,
                right: 0,
                child: IconButton( //I made a delete button here
                  icon: Icon(Icons.delete, color: Colors.white70),
                  onPressed: () {
                    _deleteCard(index); //Call delete function from top code
                  },
                ),
              ),
            ]));
  }
}