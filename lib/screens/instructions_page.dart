import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cookify/widgets/animated_gradient_background.dart';
import 'dart:ui';
import 'package:cookify/widgets/indicator.dart';

class DishDetailsPage extends StatefulWidget {
  final String dish;

  DishDetailsPage({required this.dish});

  @override
  State<DishDetailsPage> createState() => _DishDetailsPageState();
}

class _DishDetailsPageState extends State<DishDetailsPage>
    with SingleTickerProviderStateMixin {
  late Future<String> instructionsFuture;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    instructionsFuture = getInstructionsFromAPI(widget.dish);
    _setupAnimation();
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.dish,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: AnimatedGradientBackground(
          colors: [
            Color.fromRGBO(97, 61, 202, 1),
            Color.fromRGBO(87, 96, 242, 1),
            Color.fromRGBO(96, 113, 247, 1),
            Color.fromRGBO(145, 180, 245, 1),
          ],
          child: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: FutureBuilder<String>(
                    future: instructionsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return LoadingIndicator(
                          message: 'Fetching instructions...',
                          colors: [
                            Color.fromRGBO(97, 61, 202, 1),
                            Color.fromRGBO(87, 96, 242, 1),
                            Color.fromRGBO(96, 113, 247, 1),
                            Color.fromRGBO(145, 180, 245, 1),
                          ],
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error: ${snapshot.error}',
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      } else {
                        String instructions = snapshot.data!;
                        return SafeArea(
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Cooking Instructions',
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.indigo[900],
                                        ),
                                      ),
                                      SizedBox(height: 24),
                                      Row(
                                        children: [
                                          Icon(Icons.restaurant_menu,
                                              color: Colors.indigo[700]),
                                          SizedBox(width: 12),
                                          Text(
                                            'Instructions',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.indigo[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 12),
                                      Text(
                                        instructions,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.indigo[900],
                                          height: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                );
              })),
    );
  }
}

Future<String> getInstructionsFromAPI(String dish) async {
  final String endpoint =
      'https://polite-ground-030dc3103.4.azurestaticapps.net/api/v1';
  final String apiKey = 'd0f02e88-ac7f-4813-987d-4cf9a1e60b92';
  final String deploymentName = 'gpt-35-turbo';
  final String apiVersion = '2024-02-01';

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
              'You are a helpful assistant that provides cooking instructions.'
        },
        {
          'role': 'user',
          'content': 'Give detailed instructions on how to cook: $dish'
        }
      ],
    }),
  );

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    String instructions = jsonResponse['choices'][0]['message']['content'];

    print(instructions); // Keep the print statement for debugging

    return instructions;
  } else {
    throw Exception(
        'Failed to get response from Azure OpenAI: ${response.statusCode}');
  }
}
