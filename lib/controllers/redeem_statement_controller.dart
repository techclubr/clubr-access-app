import 'package:get/get.dart';
import 'package:qrzone/models/redeem_statement_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RedeemStatementController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<RedeemStatement> statements = <RedeemStatement>[].obs;

  Future<void> fetchStatements(String orderId) async {
    isLoading.value = true;
    try {
      final response = await http.get(
        Uri.parse(
          'https://whatsapp-nine-chi.vercel.app/api/cover-details/list-redeem-statements?order_id=$orderId',
        ),
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true && data['data'] != null) {
        final List<RedeemStatement> fetched =
            (data['data'] as List)
                .map((item) => RedeemStatement.fromJson(item))
                .toList();
        statements.value = fetched;
      } else {
        statements.clear();
      }
    } catch (e) {
      print('Error fetching redeem statements: $e');
      statements.clear();
    } finally {
      isLoading.value = false;
    }
  }
}
