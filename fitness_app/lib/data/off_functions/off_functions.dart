/// OpenFoodFacts API helpers.
///
/// [OffFunctions] wraps the `openfoodfacts` package with two operations:
/// - [OffFunctions.setUserAgent] — must be called once at app startup to
///   identify the app to the OFF API (required by their terms of service).
/// - [OffFunctions.searchProduct] — searches the OFF database by product name
///   and returns matching [Product] objects with nutrition data.
/// - [OffFunctions.extractIngredients] — uses OCR to extract an ingredient
///   list from a product photo identified by barcode.
///
/// Note: credentials are intentionally empty — OFF allows anonymous read
/// access for most endpoints.
library;

import 'package:openfoodfacts/openfoodfacts.dart';

class OffFunctions {
  static const String _email = '';
  static const String _password = '';
  static const _user = User(userId: _email, password: _password);

  void setUserAgent() {
    OpenFoodAPIConfiguration.userAgent = UserAgent(name: 'fitnessapp');
  }

  Future<List<Product>?>? searchProduct(String name) async {
    ProductSearchQueryConfiguration configuration =
        ProductSearchQueryConfiguration(
            parametersList: [
          SearchTerms(terms: [name])
        ],
            version: ProductQueryVersion.v3,
            country: OpenFoodFactsCountry.USA,
            language: OpenFoodFactsLanguage.ENGLISH);

    SearchResult result =
        await OpenFoodAPIClient.searchProducts(_user, configuration);

    return result.products;
  }

//  getItemSuggestions(String input) async {
  // await OpenFoodAPIClient.getpro
//  }

  Future<String?>? extractIngredients(String barcode) async {
    OcrIngredientsResult result = await OpenFoodAPIClient.extractIngredients(
        _user, barcode, OpenFoodFactsLanguage.ENGLISH);

    if (result.status != 0) {
      //TODO: add error handling
      throw Exception('Cannot be extracted.');
    }
    return result.ingredientsTextFromImage;
  }
}
