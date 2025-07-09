import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

class AdminBottomSheetController extends GetxController {
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

  final String authToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';

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
  Future<void> initializeWithContent() async {
    await fetchAdminPersonData(orderId.value!, personNo.value!.toString());
  }

  Future<void> fetchAdminPersonData(String id, String count) async {
    try {
      isLoading.value = true;
      log("Loading started");

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

      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = jsonDecode(response.body);
        final coverData = result['data']?[0];
        tableNo.value =
            coverData?['table_no'] != null
                ? int.parse(coverData['table_no'].toString())
                : null;

        final found = {"person_no": int.parse(count)};

        found['total_cover_charges'] = coverData['total_cover_charges'] ?? 0;

        found['balanceAmount'] =
            (coverData['total_cover_charges'] ?? 0) -
            (coverData['total_amount_redeemed'] ?? 0);

        found['total_free_drinks'] = coverData['total_free_drinks'] ?? 0;

        found['pendingDrinks'] =
            (coverData['total_free_drinks'] ?? 0) -
            (coverData['redeemed_free_drinks'] ?? 0);
        personData.value = found;
      } else {
        personData.value = null;
      }
    } catch (error, stackTrace) {
      print('Error fetching cover-details: $error');
      print('Stack trace: $stackTrace');
      personData.value = null;
    } finally {
      isLoading.value = false;
      log("Loading completed");
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
        final billingCode = data['data']['billing_code'];

        // Fluttertoast.showToast(
        //   msg: '$type Successfully!',
        //   toastLength: Toast.LENGTH_SHORT,
        //   gravity: ToastGravity.BOTTOM,
        //   backgroundColor: Colors.green,
        //   textColor: Colors.white,
        // );

        Get.dialog(
          AlertDialog(
            title: Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'ID: ',
                    style: TextStyle(fontWeight: FontWeight.normal),
                  ),
                  TextSpan(
                    text: billingCode,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            content: Text('$type Successfully!'),
            actions: [
              FilledButton(
                onPressed: () => Get.back(),
                child: Text(
                  "Done",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
        fetchAdminPersonData(
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
            (personData.value!['balanceAmount'] ?? 0);
  }

  String? get redeemAmountErrorText {
    if (redeemAmount.value.isNotEmpty &&
        int.tryParse(redeemAmount.value) != null &&
        personData.value != null &&
        int.parse(redeemAmount.value) >
            (personData.value!['balanceAmount'] ?? 0)) {
      return 'Amount cannot be greater than ₹${personData.value!['balanceAmount']}';
    }
    return null;
  }

  bool get isRedeemFreeDrinksButtonEnabled {
    return redeemFreeDrinkAmount.value.isNotEmpty &&
        int.tryParse(redeemFreeDrinkAmount.value) != null &&
        int.parse(redeemFreeDrinkAmount.value) > 0 &&
        personData.value != null && // Ensure personData is not null
        int.parse(redeemFreeDrinkAmount.value) <=
            (personData.value!['pendingDrinks'] ?? 0);
  }

  String? get redeemFreeDrinkAmountErrorText {
    if (redeemFreeDrinkAmount.value.isNotEmpty &&
        int.tryParse(redeemFreeDrinkAmount.value) != null &&
        personData.value != null &&
        int.parse(redeemFreeDrinkAmount.value) >
            (personData.value!['pendingDrinks'] ?? 0)) {
      return 'Cannot redeem more than ${personData.value!['pendingDrinks']} drinks';
    }
    return null;
  }
}
