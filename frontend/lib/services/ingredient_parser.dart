class IngredientParser {
  static List<String> parse(
    String text, {
    bool requireIngredientHeading = false,
  }) {
    var cleaned = text;

    // Normalizar saltos de línea.
    cleaned = cleaned.replaceAll('\r\n', '\n');
    cleaned = cleaned.replaceAll('\r', '\n');

    // Buscar el inicio de la lista de ingredientes.
    final ingredientsStart = RegExp(
      r'\b(ingredients?|ingredientes?|inci)\s*:?',
      caseSensitive: false,
    );

    final match = ingredientsStart.firstMatch(cleaned);

    if (match != null) {
      // Quedarnos únicamente con lo que aparece
      // después de "Ingredientes:", "Ingredients:", etc.
      cleaned = cleaned.substring(match.end);
    } else if (requireIngredientHeading) {
      return [];
    }

    // Separar por:
    // - comas
    // - punto y coma
    // - saltos de línea
    // - diferentes tipos de viñetas
    final rawIngredients = cleaned.split(
      RegExp(r'[,;\n•·▪●◦]+'),
    );

    final List<String> ingredients = [];

    for (final rawIngredient in rawIngredients) {
      var ingredient = rawIngredient.trim();

      // Eliminar espacios repetidos.
      ingredient = ingredient.replaceAll(
        RegExp(r'\s+'),
        ' ',
      );

      // Eliminar caracteres extra al principio/final.
      ingredient = ingredient.replaceAll(
        RegExp(r'^[\s:.;\-]+|[\s:.;\-]+$'),
        '',
      );

      if (ingredient.isEmpty) {
        continue;
      }

      // Ignorar fragmentos demasiado pequeños.
      if (ingredient.length < 2) {
        continue;
      }

      // Evitar duplicados.
      final alreadyExists = ingredients.any(
        (existing) =>
            existing.toLowerCase() == ingredient.toLowerCase(),
      );

      if (!alreadyExists) {
        ingredients.add(ingredient);
      }
    }

    return ingredients;
  }
}
