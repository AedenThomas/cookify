// ingredients_page.dart
import 'package:flutter/material.dart';
import 'instructions_page.dart';
import 'package:cookify/widgets/animated_gradient_background.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cookify/utils/image_processing.dart';
import 'package:cookify/widgets/bubbles.dart';
import 'package:cookify/widgets/image_button.dart';
import 'package:cookify/widgets/indicator.dart';
import 'package:cookify/widgets/fade_page_route.dart';
import 'dishes_page.dart';
import 'dart:async';


class IngredientsPage extends StatefulWidget {
  @override
  State<IngredientsPage> createState() => _IngredientsPageState();
}

class _IngredientsPageState extends State<IngredientsPage>
    with TickerProviderStateMixin {
  TextEditingController _ingredientsController = TextEditingController();
  List<Bubble> bubbles = [];
  late AnimationController _backgroundAnimationController;
  late AnimationController _sphereAnimationController;
  List<BurstEffect> burstEffects = [];
  bool isLoading = false;
  late BubbleManager bubbleManager;
  SpherePainter? spherePainter;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _ingredientsController.addListener(_onTextChanged);
    _setupAnimations();
    spherePainter = SpherePainter(
      animation: _sphereAnimationController,
      bubbles: bubbles,
      textStyle: TextStyle(
        color: Colors.black87,
        fontWeight: FontWeight.bold,
      ),
    );

    bubbleManager = BubbleManager(
      bubbles: bubbles,
      onBubbleBurst: _onBubbleBurst,
      context: context,
      vsync: this,
      addBurstEffect: addBurstEffect,
    );

    _timer = Timer.periodic(Duration(milliseconds: 16), (timer) {
      setState(() {}); // Trigger rebuilds for animation
    });
  }

  void _onBubbleBurst(int index) {
    setState(() {
      bubbles.removeAt(index);
      spherePainter = SpherePainter(
        animation: _sphereAnimationController,
        bubbles: bubbles,
        textStyle: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
        ),
      );
    });
  }

  void addBurstEffect(BurstEffect effect) {
    setState(() {
      burstEffects.add(effect);
    });
  }

  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        isLoading = true;
      });

      try {
        final newIngredients =
            await ImageProcessing.processImage(pickedFile.path, context);

        setState(() {
          for (var ingredient in newIngredients) {
            this.bubbles.add(
                  Bubble(
                    ingredient: ingredient,
                    position: Offset(MediaQuery.of(context).size.width / 2,
                        MediaQuery.of(context).size.height / 2),
                    targetPosition: Offset(
                        MediaQuery.of(context).size.width / 2,
                        MediaQuery.of(context).size.height / 2),
                    color: bubbleManager.getBubbleColor(ingredient),
                  ),
                );
          }
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to process image: $e')),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _setupAnimations() {
    _backgroundAnimationController = AnimationController(
      duration: Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);

    _sphereAnimationController = AnimationController(
      duration: Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _ingredientsController.removeListener(_onTextChanged);
    _ingredientsController.dispose();
    _backgroundAnimationController.dispose();
    _sphereAnimationController.dispose();
    burstEffects.forEach((effect) => effect.controller.dispose());
    _timer?.cancel();
    super.dispose();
  }

  void _processInput(String input) {
    final newIngredients = input
        .split(RegExp(r'[,\s]+'))
        .where((ingredient) => ingredient.isNotEmpty)
        .toList();

    setState(() {
      for (var ingredient in newIngredients) {
        this.bubbles.add(
              Bubble(
                ingredient: ingredient,
                position: Offset(MediaQuery.of(context).size.width / 2,
                    MediaQuery.of(context).size.height / 2),
                targetPosition: Offset(MediaQuery.of(context).size.width / 2,
                    MediaQuery.of(context).size.height / 2),
                color: bubbleManager.getBubbleColor(ingredient),
              ),
            );
      }
      _ingredientsController.clear();

      spherePainter = SpherePainter(
        animation: _sphereAnimationController,
        bubbles: bubbles,
        textStyle: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
        ),
      );
    });
  }

  void _onTextChanged() {
    final text = _ingredientsController.text;
    if (text.endsWith(',') || text.endsWith(' ')) {
      _processInput(text.trim());
    }
  }

  void _addIngredient(String ingredient) {
    _processInput(ingredient);
  }

  void _navigateToDishesPage() {
    if (bubbles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please add some ingredients first!')),
      );
    } else {
      Navigator.push(
        context,
        FadePageRoute(
          builder: (context) => DishesPage(
            ingredients: TextEditingController(
                text: bubbles.map((b) => b.ingredient).join(', ')),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle bubbleTextStyle =
        Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            );
    final spherePainter = SpherePainter(
      animation: _sphereAnimationController,
      bubbles: bubbles,
      textStyle: bubbleTextStyle,
    );

    return Scaffold(
      body: GestureDetector(
        onTapDown: (details) => bubbleManager.onTapDown(
          details,
          MediaQuery.of(context).size,
          _sphereAnimationController,
        ),
        child: Stack(children: [
          GestureDetector(
            onTapDown: (details) => bubbleManager.onTapDown(
              details,
              MediaQuery.of(context).size,
              _sphereAnimationController,
            ),
            child: Stack(
              children: [
                AnimatedGradientBackground(
                  colors: const [
                    Color.fromRGBO(97, 61, 202, 1),
                    Color.fromRGBO(87, 96, 242, 1),
                    Color.fromRGBO(96, 113, 247, 1),
                    Color.fromRGBO(145, 180, 245, 1),
                  ],
                  child: Container(),
                ),
                AnimatedBuilder(
                  animation: _sphereAnimationController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: spherePainter,
                      size: Size.infinite,
                    );
                  },
                ),
                ...burstEffects.map((effect) {
                  return AnimatedBuilder(
                    animation: effect.animation,
                    builder: (context, child) =>
                        BurstEffectWidget(effect: effect),
                  );
                }).toList(),
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Column(
                      children: [
                        Container(
                            width: 340,
                            child: RepaintBoundary(
                              child: Container(
                                width: 340,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: TextField(
                                  controller: _ingredientsController,
                                  style: TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: 'Add ingredients',
                                    prefixIcon:
                                        Icon(Icons.add, color: Colors.white70),
                                    hintStyle: TextStyle(color: Colors.white70),
                                    border: InputBorder.none,
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 15),
                                  ),
                                  onSubmitted: _addIngredient,
                                ),
                              ),
                            )),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            buildImageButton(Icons.camera_alt,
                                () => _getImage(ImageSource.camera)),
                            SizedBox(width: 20),
                            buildImageButton(Icons.photo_library,
                                () => _getImage(ImageSource.gallery)),
                          ],
                        ),
                        SizedBox(height: 20),
                        Container(
                          width: 200,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            gradient: LinearGradient(
                              colors: [
                                Color(0x71A0FB),
                                Color(0x2C36ED),
                                Color(0x7170E7)
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 0,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed:
                                _navigateToDishesPage, // Call the new function
                            child: Text(
                              'Find recipes',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isLoading)
            LoadingIndicator(
              message: "Recognizing items...",
              colors: [
                Color.fromRGBO(97, 61, 202, 1),
                Color.fromRGBO(87, 96, 242, 1),
                Color.fromRGBO(96, 113, 247, 1),
                Color.fromRGBO(145, 180, 245, 1),
              ],
            ),
          Center(
            child: AnimatedOpacity(
              opacity: (bubbles.isEmpty && !isLoading) ? 1.0 : 0.0,
              duration: Duration(milliseconds: 300),
              child: Text(
                'Add ingredients to get started',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
