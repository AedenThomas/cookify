import 'package:dart_openai/openai.dart';
import 'package:flutter/material.dart';

class DishDetailsPage extends StatefulWidget {
  final String dish;

  DishDetailsPage({required this.dish});

  @override
  State<DishDetailsPage> createState() => _DishDetailsPageState();
}

class _DishDetailsPageState extends State<DishDetailsPage> {
  late Future<String> instructionsFuture;

  @override
  void initState() {
    super.initState();
    // Replace this with your API request to get detailed cooking instructions
    instructionsFuture = getInstructionsFromAPI(widget.dish);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.dish)),
      body: FutureBuilder<String>(
        future: instructionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            String instructions = snapshot.data!;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(instructions),
              ),
            );
          }
        },
      ),
    );
  }
}

Future<String> getInstructionsFromAPI(String dish) async {
  OpenAI.apiKey = "";
  OpenAIChatCompletionModel chatCompletion = await OpenAI.instance.chat.create(
    model: "gpt-3.5-turbo",
    messages: [
      OpenAIChatCompletionChoiceMessageModel(
        content: "Give detailed instructions how to cook: $dish",
        role: "user",
      ),
    ],
  );

  OpenAIChatCompletionChoiceMessageModel response =
      chatCompletion.choices.first.message;
  String instructions = response.content;

  print(instructions);

  return instructions;
}
