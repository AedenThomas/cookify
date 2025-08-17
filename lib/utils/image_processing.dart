// image_processing.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class ImageProcessing {
  static Future<List<String>> processImage(
      String imagePath, BuildContext context) async {
    try {
      return await sendImageToGPT4Vision(imagePath);
    } catch (e) {
      print('Error processing image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to process image: $e')),
      );
      return [];
    }
  }

  static Future<List<String>> getImage(
      ImageSource source, BuildContext context) async {
    PermissionStatus status;
    if (source == ImageSource.camera) {
      status = await Permission.camera.status;
      if (!status.isGranted) {
        status = await Permission.camera.request();
      }
    } else {
      status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
      }
    }

    if (status.isGranted) {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        try {
          return await sendImageToGPT4Vision(pickedFile.path);
        } catch (e) {
          print('Error processing image: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to process image: $e')),
          );
          return [];
        }
      }
    } else {
      print('Permission not granted');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission not granted')),
      );
      return [];
    }
    return [];
  }

  static Future<List<String>> sendImageToGPT4Vision(String imagePath) async {
    final apiBase =
        'https://polite-ground-030dc3103.4.azurestaticapps.net/api/v1';
    final deploymentName = 'gpt-4-vision';
    final apiKey =
        'd0f02e88-ac7f-4813-987d-4cf9a1e60b92'; // Replace with your actual API key

    final baseUrl = '$apiBase/openai/deployments/$deploymentName';
    final endpoint = '$baseUrl/chat/completions?api-version=2023-12-01-preview';

    final imageBytes = await File(imagePath).readAsBytes();
    final base64Image = base64Encode(imageBytes);

    final headers = {
      'Content-Type': 'application/json',
      'api-key': apiKey,
    };

    final body = {
      'messages': [
        {
          'role': 'system',
          'content':
              'You are a helpful assistant that identifies things in images. Respond only with a comma-separated list of ingredients, nothing else.'
        },
        {
          'role': 'user',
          'content': [
            {
              'type': 'text',
              'text':
                  'List only the things visible in this image which can be used for cooking. Provide the list as comma-separated values without any additional text or explanation:',
            },
            {
              'type': 'image_url',
              'image_url': {
                'url': 'data:image/jpeg;base64,$base64Image',
              },
            },
          ],
        },
      ],
      'max_tokens': 2000,
    };

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        print('Response: ${response.body}');
        final jsonResponse = json.decode(response.body);
        final content =
            jsonResponse['choices'][0]['message']['content'] as String;
        // Split the content by commas, trim each item, and filter out any empty strings
        print('Content: $content');
        return content
            .split(',')
            .map((String e) => e.trim())
            .where((String e) => e.isNotEmpty)
            .toList();
      } else {
        throw Exception(
            'Failed to get ingredients from image: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in _sendImageToGPT4Vision: $e');
      return []; // Return an empty list in case of error
    }
  }
}
