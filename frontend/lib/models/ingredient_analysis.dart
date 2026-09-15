class IngredientAnalysisItem {
  final String inputName;
  final bool found;

  final String? inciName;
  final String? commonName;
  final String? description;
  final String? category;
  final String? evidenceLevel;

  final List<String> functions;
  final List<String> skinTypes;
  final List<String> precautions;

  IngredientAnalysisItem({
    required this.inputName,
    required this.found,
    this.inciName,
    this.commonName,
    this.description,
    this.category,
    this.evidenceLevel,
    this.functions = const [],
    this.skinTypes = const [],
    this.precautions = const [],
  });

  factory IngredientAnalysisItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return IngredientAnalysisItem(
      inputName: json['input_name'] as String,
      found: json['found'] as bool,
      inciName: json['inci_name'] as String?,
      commonName: json['common_name'] as String?,
      description: json['description'] as String?,
      category: json['category'] as String?,
      evidenceLevel: json['evidence_level'] as String?,
      functions: List<String>.from(
        json['functions'] ?? [],
      ),
      skinTypes: List<String>.from(
        json['skin_types'] ?? [],
      ),
      precautions: List<String>.from(
        json['precautions'] ?? [],
      ),
    );
  }
}


class IngredientAnalysisResponse {
  final int totalIngredients;
  final int foundIngredients;
  final int notFoundIngredients;

  final List<IngredientAnalysisItem> ingredients;

  IngredientAnalysisResponse({
    required this.totalIngredients,
    required this.foundIngredients,
    required this.notFoundIngredients,
    required this.ingredients,
  });

  factory IngredientAnalysisResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return IngredientAnalysisResponse(
      totalIngredients:
          json['total_ingredients'] as int,
      foundIngredients:
          json['found_ingredients'] as int,
      notFoundIngredients:
          json['not_found_ingredients'] as int,
      ingredients:
          (json['ingredients'] as List)
              .map(
                (item) =>
                    IngredientAnalysisItem.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList(),
    );
  }
}