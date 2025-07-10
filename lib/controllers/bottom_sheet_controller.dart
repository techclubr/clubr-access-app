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
  var tableNo = Rx<String?>(null);
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

  Future<void> initializeWithContent() async {
    if (orderId.value != null && personNo.value != null) {
      if (personNo.value == 0) {
        await fetchAdminData(orderId.value!);
      } else {
        await fetchUserData(orderId.value!, personNo.value!.toString());
      }
    }
  }

  // Fetches data for regular users (personNo != 0)
  Future<void> fetchUserData(String id, String count) async {
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
                ? coverData['table_no']
                : null;

        if (coverData?['person_wise_details'] != null) {
          final parsed = jsonDecode(coverData['person_wise_details']) as List;
          final found = parsed.firstWhere(
            (p) => p['person_no'] == int.parse(count),
            orElse: () => null,
          );

          if (found != null) {
            found['total_cover_charges'] =
                coverData['total_cover_charges'] ?? 0;
            found['total_free_drinks'] = coverData['total_free_drinks'] ?? 0;
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
      print('Error fetching user cover-details: $error');
      personData.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  // Fetches data for admin (personNo == 0)
  Future<void> fetchAdminData(String id) async {
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

      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = jsonDecode(response.body);
        final coverData = result['data']?[0];
        tableNo.value =
            coverData?['table_no'] != null ? coverData['table_no'] : null;

        final Map<String, dynamic> adminFoundData = {
          "person_no": 0,
        }; // Use 0 for admin

        adminFoundData['total_cover_charges'] =
            coverData['total_cover_charges'] ?? 0;
        adminFoundData['balanceAmount'] =
            (coverData['total_cover_charges'] ?? 0) -
            (coverData['total_amount_redeemed'] ?? 0);
        adminFoundData['total_free_drinks'] =
            coverData['total_free_drinks'] ?? 0;
        adminFoundData['pendingDrinks'] =
            (coverData['total_free_drinks'] ?? 0) -
            (coverData['redeemed_free_drinks'] ?? 0);
        personData.value = adminFoundData;
      } else {
        personData.value = null;
      }
    } catch (error, stackTrace) {
      print('Error fetching admin cover-details: $error');
      print('Stack trace: $stackTrace');
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
        final billingCode = data['data']['billing_code'];

        Get.dialog(
          barrierDismissible: false,
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
        // Re-fetch data to update UI based on whether it's admin or user
        initializeWithContent(); // This will call the correct fetch method
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

  // Validation getters for UI - Adjusted to handle both user and admin data keys
  bool get isRedeemAmountButtonEnabled {
    if (personData.value == null) return false;

    int pendingAmount =
        (personNo.value == 0)
            ? (personData.value!['balanceAmount'] ?? 0) // Admin
            : (personData.value!['pending_amount'] ?? 0); // User

    return redeemAmount.value.isNotEmpty &&
        int.tryParse(redeemAmount.value) != null &&
        int.parse(redeemAmount.value) > 0 &&
        int.parse(redeemAmount.value) <= pendingAmount;
  }

  String? get redeemAmountErrorText {
    if (redeemAmount.value.isNotEmpty &&
        int.tryParse(redeemAmount.value) != null &&
        personData.value != null) {
      int pendingAmount =
          (personNo.value == 0)
              ? (personData.value!['balanceAmount'] ?? 0) // Admin
              : (personData.value!['pending_amount'] ?? 0); // User

      if (int.parse(redeemAmount.value) > pendingAmount) {
        return 'Amount cannot be greater than ₹$pendingAmount';
      }
    }
    return null;
  }

  bool get isRedeemFreeDrinksButtonEnabled {
    if (personData.value == null) return false;

    int pendingDrinks =
        (personNo.value == 0)
            ? (personData.value!['pendingDrinks'] ?? 0) // Admin
            : (personData.value!['pending_drinks'] ?? 0); // User

    return redeemFreeDrinkAmount.value.isNotEmpty &&
        int.tryParse(redeemFreeDrinkAmount.value) != null &&
        int.parse(redeemFreeDrinkAmount.value) > 0 &&
        int.parse(redeemFreeDrinkAmount.value) <= pendingDrinks;
  }

  String? get redeemFreeDrinkAmountErrorText {
    if (redeemFreeDrinkAmount.value.isNotEmpty &&
        int.tryParse(redeemFreeDrinkAmount.value) != null &&
        personData.value != null) {
      int pendingDrinks =
          (personNo.value == 0)
              ? (personData.value!['pendingDrinks'] ?? 0) // Admin
              : (personData.value!['pending_drinks'] ?? 0); // User

      if (int.parse(redeemFreeDrinkAmount.value) > pendingDrinks) {
        return 'Cannot redeem more than $pendingDrinks drinks';
      }
    }
    return null;
  }
}
