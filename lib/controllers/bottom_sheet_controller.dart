import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

class BottomSheetController extends GetxController {
  // Observables for reactive UI updates
  var isLoading = true.obs;
  var personData = Rx<Map<String, dynamic>?>(null);
  var orderId = Rx<String?>(null);
  var personNo = Rx<int?>(null);
  var tableNo = Rx<int?>(null);
  var redeemAmount = ''.obs;
  var redeemFreeDrinkAmount = ''.obs;

  // TextEditingController for the redeem amount input
  late TextEditingController redeemAmountController;

  final String authToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'; // Consider fetching this securely

  @override
  void onInit() {
    super.onInit();
    redeemAmountController = TextEditingController();
  
    // You can pass content here if the controller is initialized with arguments
    // For now, we'll assume content is passed when `fetchData` is called.
  }

  @override
  void onClose() {
    redeemAmountController.dispose();
    super.onClose();
  }

  // Method to initialize data based on content
  void initializeWithContent(String? content) {
    if (content != null) {
      print('Raw content: "$content"');
      print('content type: "${content.runtimeType}"');
      try {
        String cleanContent = content.trim();
        if (cleanContent.startsWith('"') && cleanContent.endsWith('"')) {
          cleanContent = cleanContent.substring(1, cleanContent.length - 1);
        }
        final parts = cleanContent.split('-');
        print('Split parts: $parts');
        if (parts.length == 2 &&
            parts[0].isNotEmpty &&
            int.tryParse(parts[1]) != null) {
          orderId.value = parts[0];
          personNo.value = int.parse(parts[1]);
          print(
            'Parsed order_id: ${orderId.value}, person_no: ${personNo.value}',
          );
          fetchPersonData(orderId.value!, personNo.value!.toString());
        } else {
          print(
            'Invalid content format: Expected "order_id-person_no", got ${parts.length} parts',
          );
          isLoading.value = false;
          personData.value = null;
          Fluttertoast.showToast(
            msg: 'Invalid QR code format. Expected "order_id-person_no".',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      } catch (e) {
        print('Error parsing content: $e');
        isLoading.value = false;
        personData.value = null;
        Fluttertoast.showToast(
          msg: 'Error processing QR code: $e',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } else {
      print('Content is null');
      isLoading.value = false;
      personData.value = null;
      Fluttertoast.showToast(
        msg: 'No QR code data found',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<void> fetchPersonData(String id, String count) async {
    try {
      isLoading.value = true;

      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'x-auth-token': authToken,
      };
      final response = await http.get(
        Uri.parse(
          'https://whatsapp-nine-chi.vercel.app/api/cover-details/list?order_id=$id',
        ),
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = jsonDecode(response.body);
        final coverData = result['data']?[0];
        tableNo.value =
            coverData?['table_no'] != null
                ? int.parse(coverData['table_no'].toString())
                : null;

        if (coverData?['person_wise_details'] != null) {
          final parsed = jsonDecode(coverData['person_wise_details']) as List;
          final found = parsed.firstWhere(
            (p) => p['person_no'] == int.parse(count),
            orElse: () => null,
          );

          if (found != null) {
            found['pending_amount'] =
                (found['cover_charges'] ?? 0) -
                (found['redeemed_cover_charges'] ?? 0);
            found['pending_drinks'] =
                (found['free_drinks'] ?? 0) -
                (found['redeemed_free_drinks'] ?? 0);
            personData.value = found;
          } else {
            personData.value = null;
          }
        } else {
          personData.value = null;
        }
      } else {
        print(response.statusCode);
        print(response.body);
        personData.value = null;
      }
    } catch (error) {
      print('Error fetching cover-details: $error');
      personData.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateCoverDetails(
    Map<String, dynamic> updateData,
    String type,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(
          'https://whatsapp-nine-chi.vercel.app/api/cover-details/update',
        ),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': authToken,
        },
        body: jsonEncode(updateData),
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        Fluttertoast.showToast(
          msg: '$type Successfully!',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        fetchPersonData(
          orderId.value!,
          personNo.value!.toString(),
        ); // Re-fetch data to update UI
      } else {
        Fluttertoast.showToast(
          msg: 'Failed to update details.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (error) {
      Fluttertoast.showToast(
        msg: 'Something went wrong.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      print('Update Error: $error');
    }
  }

  void handleRedeemAmount() {
    if (redeemAmount.value.isEmpty) return;

    final updateBody = {
      'order_id': orderId.value,
      'person_no': personNo.value,
      'redeemed_cover_charges': int.parse(redeemAmount.value),
      'redeemed_free_drinks': 0,
    };

    updateCoverDetails(updateBody, '₹${redeemAmount.value} Redeemed');
    redeemAmount.value = '';
    redeemAmountController.clear();
  }

  void handleRedeemFreeDrinks() {
    if (redeemFreeDrinkAmount.value.isEmpty) return;

    final updateBody = {
      'order_id': orderId.value,
      'person_no': personNo.value,
      'redeemed_cover_charges': 0,
      'redeemed_free_drinks': int.parse(redeemFreeDrinkAmount.value),
    };

    updateCoverDetails(
      updateBody,
      '${redeemFreeDrinkAmount.value} Drink(s) Redeemed',
    );
    redeemFreeDrinkAmount.value = '';
  }

  // Validation getters for UI
  bool get isRedeemAmountButtonEnabled {
    return redeemAmount.value.isNotEmpty &&
        int.tryParse(redeemAmount.value) != null &&
        int.parse(redeemAmount.value) > 0 &&
        personData.value != null && // Ensure personData is not null
        int.parse(redeemAmount.value) <=
            (personData.value!['pending_amount'] ?? 0);
  }

  String? get redeemAmountErrorText {
    if (redeemAmount.value.isNotEmpty &&
        int.tryParse(redeemAmount.value) != null &&
        personData.value != null &&
        int.parse(redeemAmount.value) >
            (personData.value!['pending_amount'] ?? 0)) {
      return 'Amount cannot be greater than ₹${personData.value!['pending_amount']}';
    }
    return null;
  }

  bool get isRedeemFreeDrinksButtonEnabled {
    return redeemFreeDrinkAmount.value.isNotEmpty &&
        int.tryParse(redeemFreeDrinkAmount.value) != null &&
        int.parse(redeemFreeDrinkAmount.value) > 0 &&
        personData.value != null && // Ensure personData is not null
        int.parse(redeemFreeDrinkAmount.value) <=
            (personData.value!['pending_drinks'] ?? 0);
  }

  String? get redeemFreeDrinkAmountErrorText {
    if (redeemFreeDrinkAmount.value.isNotEmpty &&
        int.tryParse(redeemFreeDrinkAmount.value) != null &&
        personData.value != null &&
        int.parse(redeemFreeDrinkAmount.value) >
            (personData.value!['pending_drinks'] ?? 0)) {
      return 'Cannot redeem more than ${personData.value!['pending_drinks']} drinks';
    }
    return null;
  }
}
