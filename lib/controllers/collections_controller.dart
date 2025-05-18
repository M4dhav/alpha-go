import 'dart:convert';
import 'package:alpha_go/models/collection_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/const_model.dart';

class CollectionController extends GetxController {
  final RxList<OrdinalCollectionModel> collections =
      <OrdinalCollectionModel>[].obs;
  final isLoading = false.obs;
  final isFetchingMore = false.obs;
  final hasMore = true.obs;
  final int limit = 20;
  int page = 1;

  final String baseUrl = 'https://api.ordiscan.com/v1/collections';
  final String apiKey = Constants.ordiscanApiKey;

  Future<void> fetchCollections({bool refresh = false}) async {
    if ((isLoading.value || isFetchingMore.value) && !refresh) return;
    if (!hasMore.value && !refresh) return;

    if (refresh) {
      page = 1;
      collections.clear();
      hasMore.value = true;
      isLoading.value = true;
    } else {
      isFetchingMore.value = true;
    }

    try {
      final uri = Uri.parse(baseUrl).replace(queryParameters: {
        'limit': '$limit',
        'page': '$page',
      });

      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $apiKey'},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List data = json['data'];

        if (data.isEmpty) {
          hasMore.value = false;
        } else {
          collections.addAll(
              data.map((e) => OrdinalCollectionModel.fromMap(e)).toList());
          page += 1;
        }
      } else {
        throw Exception("Failed to load collections");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
      isFetchingMore.value = false;
    }
  }
}
