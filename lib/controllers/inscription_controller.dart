import 'dart:convert';
import 'package:alpha_go/models/inscription_trait_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/const_model.dart';
import '../models/inscription_model.dart';

class InscriptionController extends GetxController {
  final inscriptions = <OrdinalInscription>[].obs;
  final isLoading = false.obs;
  final isFetchingMore = false.obs;
  final hasMore = true.obs;
  final int limit = 5;
  int page = 1;


  final selectedInscription = Rx<OrdinalInscription?>(null);
  final traits = <InscriptionTrait>[].obs;
  final isDetailLoading = false.obs;
  final List<OrdinalInscription> fetched = [];

  late String slug;

  Future<void> init(String collectionSlug) async {
    slug = collectionSlug;
    await fetchInscriptions(refresh: true);
  }

  Future<void> fetchInscriptions({bool refresh = false}) async {
    if ((isLoading.value || isFetchingMore.value) && !refresh) return;
    if (!hasMore.value && !refresh) return;

    if (refresh) {
      inscriptions.clear();
      page = 1;
      hasMore.value = true;
      isLoading.value = true;
    } else {
      isFetchingMore.value = true;
    }

    try {
      final url = Uri.parse(
          'https://api.ordiscan.com/v1/collection/$slug/inscriptions?page=$page&limit=$limit');

      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer ${Constants.ordiscanApiKey}'},
      );

      if (response.statusCode == 200) {
        final ids = jsonDecode(response.body)['data'] as List;

        if (ids.isEmpty) {
          hasMore.value = false;
        } else {
          final futures = ids.take(2).map((id) async {
            final detailUrl =
                Uri.parse('https://api.ordiscan.com/v1/inscription/$id');
            final detailResponse = await http.get(detailUrl, headers: {
              'Authorization': 'Bearer ${Constants.ordiscanApiKey}'
            });
            if (detailResponse.statusCode == 200) {
              final data = jsonDecode(detailResponse.body)['data'];
              return OrdinalInscription.fromMap(data);
            }
            return null;
          });

          final results = await Future.wait(futures);
          inscriptions.addAll(results.whereType<OrdinalInscription>());
          page += 1;
        }
      } else {
        throw Exception('Failed to load inscriptions');
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
      isFetchingMore.value = false;
    }
  }

  Future<void> fetchInscriptionDetail(String id) async {
    print('Fetch inscription function started');
    print('Fetching inscription detail for ID: $id');
    isDetailLoading.value = true;
    selectedInscription.value = null;
    traits.clear();

    try {
      final detailUrl =
          Uri.parse('https://api.ordiscan.com/v1/inscription/$id');
      final detailResponse = await http.get(detailUrl,
          headers: {'Authorization': 'Bearer ${Constants.ordiscanApiKey}'});

      if (detailResponse.statusCode == 200) {
        print('Detail Response: ${detailResponse.body}');
        print('Inscription details feteched successfully');
        final data = jsonDecode(detailResponse.body)['data'];
        print('Data: $data');
        print('Data type: ${data.runtimeType}');
        selectedInscription.value = OrdinalInscription.fromMap(data);
        print('Inscription Detail: ${selectedInscription.value}');
      } else {
        print('Inscription detail fetch failed');
        print('Error: ${detailResponse.statusCode}');
        print('Response: ${detailResponse.body}');
        throw Exception('Failed to load inscription detail');
        
      }

      final traitsUrl =
          Uri.parse('https://api.ordiscan.com/v1/inscription/$id/traits');
      final traitsResponse = await http.get(traitsUrl,
          headers: {'Authorization': 'Bearer ${Constants.ordiscanApiKey}'});

      if (traitsResponse.statusCode == 200) {
        final traitsData = jsonDecode(traitsResponse.body)['data'] as List;
        traits.value =
            traitsData.map((e) => InscriptionTrait.fromMap(e)).toList();
      }
    } catch (e) {
      // Get.snackbar("Error", e.toString());

    } finally {
      isDetailLoading.value = false;
    }
  }
}
