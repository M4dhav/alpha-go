import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:alpha_go/models/mint_ordinal_model.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class MintOrdinalController extends GetxController {
  MintOrdinalModel? inscriptionModel;
  Future<Map<String, dynamic>> pickPictureAndEncode() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.gallery);
    if (photo != null) {
      final Uint8List bytes = await photo.readAsBytes();
      final int size = await photo.length();

      if (size > 395000) {
        return {
          "success": false,
          "message": "File size is too large. Please select a smaller file"
        };
      }

      return {
        "success": true,
        "data": base64Encode(bytes),
        "name": photo.name,
        "size": size,
        "type": "image/${photo.name.split('.').last}"
      };
    } else {
      return {"success": false, "message": "No file selected"};
    }
  }

  Future<Map<String, dynamic>?> pickVideoAndEncode() async {
    final ImagePicker picker = ImagePicker();
    final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      final Uint8List bytes = await video.readAsBytes();
      final int size = await video.length();

      return {
        "data": base64Encode(bytes),
        "name": video.name,
        "size": size,
        "type": "video/${video.name.split('.').last}"
      };
    } else {
      return null;
    }
  }

  ///This function takes inscription data and other information and sends a request to the Ordinals Bot API to inscribe the data.
  Future<void> inscribe(Map<String, dynamic> inscriptionData,
      String userAddress, int feeRate) async {
    final Map<String, dynamic> requestBody = {
      "files": [
        {
          "type": inscriptionData["type"],
          "name": inscriptionData["name"],
          "dataURL":
              "data:${inscriptionData['type']};base64,${inscriptionData['data']}",
          "size": inscriptionData["size"],
        }
      ],
      "receiveAddress": userAddress,
      "lowPostage": true,
      "fee": feeRate
    };

    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    final response = await http.post(
      Uri.parse('https://api.ordinalsbot.com/inscribe'),
      headers: headers,
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      log("Response data: $responseData");
      inscriptionModel =
          MintOrdinalModel.fromJson(responseData as Map<String, dynamic>);
    } else {
      log('Request failed with status: ${response.statusCode}');
      log('Response body: ${response.body}');
    }
  }

  Future<void> fetchOrderDetails(String orderId) async {
    final String url = "https://api.ordinalsbot.com/order?id=$orderId";

    try {
      final response = await http.get(Uri.parse(url), headers: {
        'Accept': 'application/json',
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        log("Order data: $data");
        inscriptionModel!.updateOrderData(data as Map<String, dynamic>);
      } else {
        log("Failed to fetch order. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      log("Error: $e");
    }
  }
}
