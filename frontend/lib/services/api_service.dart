import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/ingredient_analysis.dart';


class ApiService {

  static const String baseUrl =
      /*'http://127.0.0.1:8000';*/
      "http://192.168.40.2:8000";


  Future<IngredientAnalysisResponse>
      analyzeIngredients(
    List<String> ingredients,
  ) async {

    final response = await http.post(
      Uri.parse(
        '$baseUrl/ingredients/analyze',
      ),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'ingredients': ingredients,
      }),
    );


    if (response.statusCode != 200) {
      throw Exception(
        'API error: ${response.statusCode}',
      );
    }


    final data = jsonDecode(
      response.body,
    );


    return IngredientAnalysisResponse
        .fromJson(data);
  }
}