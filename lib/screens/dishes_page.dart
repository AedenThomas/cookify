import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'instructions_page.dart'; // Assuming you have this page
import 'package:flutter/services.dart';
import 'package:cookify/widgets/animated_gradient_background.dart';
import 'package:cookify/widgets/indicator.dart';
import 'package:cookify/widgets/button.dart';
import 'package:cookify/widgets/fade_page_route.dart';

Future<List<String>> getDishesFromGPT(String ingredients) async {
  final String endpoint =
      'https://polite-ground-030dc3103.4.azurestaticapps.net/api/v1';
  final String apiKey =
      'd0f02e88-ac7f-4813-987d-4cf9a1e60b92'; // Replace with your actual API key
  final String deploymentName = 'gpt-35-turbo';
  final String apiVersion = '2024-02-01';
  print("Ingredients: ");
  print(ingredients);
  final response = await http.post(
    Uri.parse(
        '$endpoint/openai/deployments/$deploymentName/chat/completions?api-version=$apiVersion'),
    headers: {
      'Content-Type': 'application/json',
      'api-key': apiKey,
    },
    body: jsonEncode({
      'messages': [
        {
          'role': 'system',
          'content':
              'You are a helpful assistant that suggests dishes based on ingredients. Respond with a JSON object containing an array of dish names under the key "dishes".'
        },
        {
          'role': 'user',
          'content':
              'Suggest dishes based on only these ingredients and no other ingredient: $ingredients. If no dishes can be made using only these ingredients and if I havent provided any ingredients, return an empty array. Return the response as a JSON object with the dishes in an array under the key "dishes".'
        }
      ],
    }),
  );

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    String content = jsonResponse['choices'][0]['message']['content'];
    print(content);
    Map<String, dynamic> parsedContent = jsonDecode(content);

    List<dynamic> dishes = parsedContent['dishes'];

    return dishes.map((dish) => dish.toString()).toList();
  } else {
    throw Exception(
        'Failed to get response from Azure OpenAI: ${response.statusCode}');
  }
}

class DishesPage extends StatefulWidget {
  final TextEditingController ingredients;

  DishesPage({required this.ingredients});

  @override
  _DishesPageState createState() => _DishesPageState();
}

class _DishesPageState extends State<DishesPage>
    with SingleTickerProviderStateMixin {
  late Future<List<String>> dishesFuture;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    dishesFuture = getDishesFromGPT(widget.ingredients.text);
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _fadeAnimation =
        Tween<double>(begin: 1.0, end: 0.0).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              ),
              systemOverlayStyle: SystemUiOverlayStyle.dark,
            ),
            body: AnimatedGradientBackground(
              colors: const [
                Color.fromRGBO(52, 55, 229, 1),
                Color.fromRGBO(71, 71, 227, 1),
                Color.fromRGBO(83, 82, 228, 1),
                Color.fromRGBO(106, 106, 229, 1),
              ],
              child: FutureBuilder<List<String>>(
                future: dishesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return LoadingIndicator(
                      message: 'Fetching dishes...',
                      colors: const [
                        Color.fromRGBO(52, 55, 229, 1),
                        Color.fromRGBO(71, 71, 227, 1),
                        Color.fromRGBO(83, 82, 228, 1),
                        Color.fromRGBO(106, 106, 229, 1),
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return _buildErrorWidget(snapshot.error.toString());
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildNoDishesWidget();
                  } else {
                    return _buildDishesListWidget(snapshot.data!);
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60, color: Colors.red),
          SizedBox(height: 20),
          Text(
            'Oops! Something went wrong.',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          SizedBox(height: 10),
          Text(
            error,
            style: TextStyle(color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          ModernButton(
            text: 'Try Again',
            onPressed: () {
              setState(() {
                dishesFuture = getDishesFromGPT(widget.ingredients.text);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNoDishesWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sentiment_dissatisfied, size: 60, color: Colors.orange),
          SizedBox(height: 20),
          Text(
            'No dishes found',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          SizedBox(height: 10),
          Text(
            'We couldn\'t find any dishes with the given ingredients.',
            style: TextStyle(color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          ModernButton(
            text: 'Go Back',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildDishesListWidget(List<String> dishes) {
    return SafeArea(
      child: Column(
        children: [
          SizedBox(height: 20),
          Text(
            "Choose a dish",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              shadows: [
                Shadow(
                  blurRadius: 10.0,
                  color: Colors.black.withOpacity(0.1),
                  offset: Offset(2.0, 2.0),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 20),
              itemCount: dishes.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ModernButton(
                    text: dishes[index],
                    onPressed: () {
                      Navigator.push(
                        context,
                        FadePageRoute(
                          builder: (context) => DishDetailsPage(
                            dish: dishes[index],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
