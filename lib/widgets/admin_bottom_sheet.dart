import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:qrzone/colors.dart';
import 'package:qrzone/controllers/admin_bottom_sheet_controller.dart';
import 'package:qrzone/screens/redeem_statements_screen.dart';

class AdminBottomSheetWidget extends StatefulWidget {
  final String? content;
  final bool show;

  const AdminBottomSheetWidget({super.key, this.content, this.show = false});

  @override
  State<AdminBottomSheetWidget> createState() => _AdminBottomSheetWidgetState();
}

class _AdminBottomSheetWidgetState extends State<AdminBottomSheetWidget> {
  final AdminBottomSheetController adminSheetController =
      Get.find<AdminBottomSheetController>();

  @override
  Widget build(BuildContext context) {
    if (!widget.show) return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        // color: Colors.white,
        // borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              child: Obx(() {
                if (adminSheetController.isLoading.value) {
                  return const Center(
                    child: Text(
                      'Loading...',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  );
                } else if (adminSheetController.personData.value != null) {
                  print(
                    'Person Data: ${adminSheetController.personData.value}',
                  );
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (adminSheetController
                              .personData
                              .value!['total_cover_charges'] >
                          0) ...[
                        _buildSection(
                          title: 'Cover Charges',
                          amount:
                              '₹${adminSheetController.personData.value!['total_cover_charges']}',
                          balanceTitle: 'Balance Amount',
                          balanceAmount:
                              '₹${adminSheetController.personData.value!['balanceAmount']}',
                          isRedeemed:
                              adminSheetController
                                  .personData
                                  .value!['balanceAmount'] <=
                              0,
                          inputWidget: TextField(
                            controller:
                                adminSheetController.redeemAmountController,
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              hintText: 'Enter amount',
                              hintStyle: TextStyle(
                                color: storkColor,
                                fontSize: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                borderSide: BorderSide(
                                  width: 0.5,
                                  color: storkColor!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                borderSide: BorderSide(
                                  width: 0.5,
                                  color: storkColor!,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                borderSide: BorderSide(
                                  width: 0.5,
                                  color: storkColor!,
                                ),
                              ),

                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              errorText:
                                  adminSheetController
                                      .redeemAmountErrorText, // Use GetX getter for error
                              errorStyle: const TextStyle(color: Colors.red),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged:
                                (value) =>
                                    adminSheetController.redeemAmount.value =
                                        value,
                          ),
                          buttonEnabled:
                              adminSheetController
                                  .isRedeemAmountButtonEnabled, // Use GetX getter
                          onButtonPressed:
                              adminSheetController.handleRedeemAmount,
                        ),
                      ],
                      if (adminSheetController
                              .personData
                              .value!['total_free_drinks'] >
                          0) ...[
                        _buildSection(
                          title: 'Free Drinks',
                          amount:
                              adminSheetController
                                  .personData
                                  .value!['total_free_drinks']
                                  .toString(),
                          balanceTitle: 'Pending Drinks',
                          balanceAmount:
                              adminSheetController
                                  .personData
                                  .value!['pendingDrinks']
                                  .toString(),
                          isRedeemed:
                              adminSheetController
                                  .personData
                                  .value!['pendingDrinks'] <=
                              0,
                          inputWidget: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              label: Text(
                                'Select drinks',
                                style: TextStyle(color: storkColor),
                              ),
                              labelStyle: const TextStyle(color: Colors.black),

                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                              contentPadding: const EdgeInsets.all(14),
                              errorText:
                                  adminSheetController
                                      .redeemFreeDrinkAmountErrorText, // Use GetX getter for error
                              errorStyle: const TextStyle(color: Colors.red),
                            ),
                            value:
                                adminSheetController
                                        .redeemFreeDrinkAmount
                                        .value
                                        .isEmpty
                                    ? null
                                    : adminSheetController
                                        .redeemFreeDrinkAmount
                                        .value,
                            items: List.generate(
                              (adminSheetController
                                      .personData
                                      .value!['pendingDrinks']
                                  as int),
                              (index) => DropdownMenuItem(
                                value: '${index + 1}',
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                            onChanged:
                                (value) =>
                                    adminSheetController
                                        .redeemFreeDrinkAmount
                                        .value = value ?? '',
                            iconEnabledColor: storkColor,
                            dropdownColor: Colors.white,
                            style: const TextStyle(color: Colors.black),
                          ),
                          buttonEnabled:
                              adminSheetController
                                  .isRedeemFreeDrinksButtonEnabled, // Use GetX getter
                          onButtonPressed:
                              adminSheetController.handleRedeemFreeDrinks,
                        ),
                      ],
                      if (adminSheetController.tableNo.value != null &&
                          adminSheetController.tableNo.value != 0) ...[
                        _buildSection(
                          title: 'Table No',
                          amount: adminSheetController.tableNo.value.toString(),
                          isSingle: true,
                        ),
                      ],
                    ],
                  );
                } else {
                  return Center(
                    child: Text(
                      'No data found for Person #${adminSheetController.personNo.value}',
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  );
                }
              }),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.to(() => RedeemStatementsScreen(orderId: adminSheetController.orderId.value!));
            },
            child: const Text(
              "More info →",
              // "Redeem Statements →",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
                decoration: TextDecoration.underline,
                decorationColor: Colors.grey,
              ),
            ),
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }

  // The _buildSection widget remains largely the same, but it no longer accesses
  Widget _buildSection({
    required String title,
    required String amount,
    String? balanceTitle,
    String? balanceAmount,
    bool isRedeemed = false,
    Widget? inputWidget,
    bool buttonEnabled = false,
    VoidCallback? onButtonPressed,
    bool isSingle = false,
  }) {
    // The errorText parameter is removed from _buildSection as it's now handled by the TextField/DropdownButtonFormField directly.
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                  Text(
                    amount,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              if (!isSingle && balanceTitle != null && balanceAmount != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      balanceTitle,
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                    Text(
                      balanceAmount,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          if (!isSingle && isRedeemed)
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                '✅ Amount already fully redeemed.',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (!isSingle && !isRedeemed && inputWidget != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  Expanded(flex: 6, child: inputWidget),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 4,
                    child: ElevatedButton(
                      onPressed: buttonEnabled ? onButtonPressed : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        disabledBackgroundColor: Colors.grey,
                        padding: const EdgeInsets.all(10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Redeem',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
