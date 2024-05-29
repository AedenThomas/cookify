import 'package:flutter/material.dart';
import 'final_page.dart';

class IngredientsPage extends StatefulWidget {
  @override
  State<IngredientsPage> createState() => _IngredientsPageState();
}

class _IngredientsPageState extends State<IngredientsPage> {
  TextEditingController _ingredientsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Positioned(
              child: Text(
                'What ingredients do you have?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24),
              ),
            ),
            SizedBox(height: 50),
            Container(
              width: 200,
              height: 50,
              child: TextField(
                controller: _ingredientsController,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'Enter ingredients:',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(35),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                //print the ingredients
                print(_ingredientsController.text);

                // Submit button functionality

                // Navigate to the next page
// Navigate to the next page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FinalPage(
                          ingredientsController: _ingredientsController)),
                );
              },
              child: Text('Submit'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(35),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
