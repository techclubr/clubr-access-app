import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qrzone/colors.dart';
import 'package:qrzone/controllers/bottom_sheet_controller.dart';
import 'package:qrzone/screens/redeem_statements_screen.dart';

class BottomSheetWidget extends StatefulWidget {
  final String? content;
  final bool show;

  const BottomSheetWidget({super.key, this.content, this.show = false});

  @override
  State<BottomSheetWidget> createState() => _BottomSheetWidgetState();
}

class _BottomSheetWidgetState extends State<BottomSheetWidget> {
  final BottomSheetController controller = Get.find<BottomSheetController>();

  @override
  Widget build(BuildContext context) {
    if (!widget.show) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: Text(
                      'Loading...',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  );
                } else if (controller.personData.value != null) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (controller.personData.value!['cover_charges'] >
                          0) ...[
                        _buildSection(
                          title: 'Cover Charges',
                          amount:
                              '₹${controller.personData.value!['cover_charges']}',
                          balanceTitle: 'Balance Amount',
                          balanceAmount:
                              '₹${controller.personData.value!['pending_amount']}',
                          isRedeemed:
                              controller.personData.value!['pending_amount'] <=
                              0,
                          inputWidget: TextField(
                            controller: controller.redeemAmountController,
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
                                  controller
                                      .redeemAmountErrorText, // Use GetX getter for error
                              errorStyle: const TextStyle(color: Colors.red),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged:
                                (value) =>
                                    controller.redeemAmount.value = value,
                          ),
                          buttonEnabled:
                              controller
                                  .isRedeemAmountButtonEnabled, // Use GetX getter
                          onButtonPressed: controller.handleRedeemAmount,
                        ),
                      ],
                      if (controller.personData.value!['free_drinks'] > 0) ...[
                        _buildSection(
                          title: 'Free Drinks',
                          amount:
                              controller.personData.value!['free_drinks']
                                  .toString(),
                          balanceTitle: 'Pending Drinks',
                          balanceAmount:
                              controller.personData.value!['pending_drinks']
                                  .toString(),
                          isRedeemed:
                              controller.personData.value!['pending_drinks'] <=
                              0,
                          inputWidget: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              label: Text(
                                'Select drinks',
                                style: TextStyle(color: storkColor),
                              ),
                              labelStyle: const TextStyle(color: Colors.black),
                              enabledBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                              contentPadding: const EdgeInsets.all(14),
                              errorText:
                                  controller
                                      .redeemFreeDrinkAmountErrorText, // Use GetX getter for error
                              errorStyle: const TextStyle(color: Colors.red),
                            ),
                            value:
                                controller.redeemFreeDrinkAmount.value.isEmpty
                                    ? null
                                    : controller.redeemFreeDrinkAmount.value,
                            items: List.generate(
                              (controller.personData.value!['pending_drinks']
                                  as int),
                              (index) => DropdownMenuItem(
                                value: '${index + 1}',
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            onChanged:
                                (value) =>
                                    controller.redeemFreeDrinkAmount.value =
                                        value ?? '',
                            iconEnabledColor: Colors.white,
                            dropdownColor: Colors.grey[800],
                            style: const TextStyle(color: Colors.white),
                          ),
                          buttonEnabled:
                              controller
                                  .isRedeemFreeDrinksButtonEnabled, // Use GetX getter
                          onButtonPressed: controller.handleRedeemFreeDrinks,
                        ),
                      ],
                      if (controller.tableNo.value != null &&
                          controller.tableNo.value != 0) ...[
                        _buildSection(
                          title: 'Table No',
                          amount: controller.tableNo.value.toString(),
                          isSingle: true,
                        ),
                      ],
                    ],
                  );
                } else {
                  return Center(
                    child: Text(
                      'No data found for Person #${controller.personNo.value}',
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  );
                }
              }),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.to(
                () => RedeemStatementsScreen(
                  orderId: controller.orderId.value ?? "Unknown Order ID",
                ),
              );
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
