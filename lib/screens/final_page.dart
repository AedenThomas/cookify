import 'package:flutter/material.dart';
import 'package:dart_openai/openai.dart';

import 'dish_details_page.dart';

Future<List<String>> getDishesFromGPT(String ingredients) async {
  OpenAI.apiKey = "";
  List<String> dishes = [];

  OpenAIChatCompletionModel chatCompletion = await OpenAI.instance.chat.create(
    model: "gpt-3.5-turbo",
    messages: [
      OpenAIChatCompletionChoiceMessageModel(
        content: "Suggest dishes based on these ingredients: $ingredients",
        role: "user",
      ),
    ],
  );

  OpenAIChatCompletionChoiceMessageModel response =
      chatCompletion.choices.first.message;

  String dish = response.content;

  dishes = dish.split('\n').map((line) {
    // Remove the numbers and period from the beginning of each line
    return line.replaceAll(RegExp(r'^\d+\.\s*'), '').trim();
  }).toList();

  // Remove empty items from the list
  dishes.removeWhere((item) => item.isEmpty);

  return dishes;
}

class FinalPage extends StatefulWidget {
  final TextEditingController ingredientsController;

  FinalPage({required this.ingredientsController});

  @override
  State<FinalPage> createState() => _FinalPageState();
}

class _FinalPageState extends State<FinalPage> {
  late Future<List<String>> dishesFuture;
  // late String dishesFuture;

  @override
  void initState() {
    super.initState();
    dishesFuture = getDishesFromGPT(widget.ingredientsController.text);
    // dishesFuture = "getDishesFromGPT(widget.ingredientsController.text);";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 60.0),
            child: Text(
              "Choose a dish",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Center(
              child: FutureBuilder<List<String>>(
                future: dishesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    List<String> dishes = snapshot.data!;
                    return ListView.builder(
                      itemCount: dishes.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DishDetailsPage(
                                    dish: dishes[index],
                                  ),
                                ),
                              );
                              // Handle button click
                            },
                            child: Text(
                              dishes[index],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
