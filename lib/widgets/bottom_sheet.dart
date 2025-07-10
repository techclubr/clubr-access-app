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
                  // Determine if it's an admin view based on personNo
                  bool isAdminView = controller.personNo.value == 0;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // if (controller.tableNo.value != null &&
                      //     controller.tableNo.value != 0) ...[
                      // Text(
                      //       "Table No: ${controller.tableNo.value ?? 'N/A'}",
                      //       style: const TextStyle(
                      //         fontSize: 14,
                      //         fontWeight: FontWeight.w500,
                      //         color: Colors.grey,
                      //       ),
                      //     ),
                      // ],
                      // SizedBox(height: 10),
                      if (isAdminView
                          ? controller
                                  .personData
                                  .value!['total_cover_charges'] >
                              0
                          : controller.personData.value!['cover_charges'] >
                              0) ...[
                        controller.personData.value!["total_cover_charges"] <= 0
                            ? SizedBox.shrink()
                            : _buildSection(
                              title: 'Cover Charges',
                              amount:
                                  isAdminView
                                      ? '₹${controller.personData.value!['total_cover_charges']}'
                                      : '₹${controller.personData.value!['cover_charges']}',
                              balanceTitle: 'Balance Amount',
                              balanceAmount:
                                  isAdminView
                                      ? '₹${controller.personData.value!['balanceAmount']}'
                                      : '₹${controller.personData.value!['pending_amount']}',
                              isRedeemed:
                                  isAdminView
                                      ? controller
                                              .personData
                                              .value!['balanceAmount'] <=
                                          0
                                      : controller
                                              .personData
                                              .value!['pending_amount'] <=
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
                                  errorText: controller.redeemAmountErrorText,
                                  errorStyle: const TextStyle(
                                    color: Colors.red,
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged:
                                    (value) =>
                                        controller.redeemAmount.value = value,
                              ),
                              buttonEnabled:
                                  controller.isRedeemAmountButtonEnabled,
                              onButtonPressed: controller.handleRedeemAmount,
                            ),
                      ],
                      if (isAdminView
                          ? controller.personData.value!['total_free_drinks'] >
                              0
                          : controller.personData.value!['free_drinks'] >
                              0) ...[
                        controller.personData.value!["total_free_drinks"] <= 0
                            ? SizedBox.shrink()
                            : _buildSection(
                              title: 'Free Drinks',
                              amount:
                                  isAdminView
                                      ? controller
                                          .personData
                                          .value!['total_free_drinks']
                                          .toString()
                                      : controller
                                          .personData
                                          .value!['free_drinks']
                                          .toString(),
                              balanceTitle: 'Pending Drinks',
                              balanceAmount:
                                  isAdminView
                                      ? controller
                                          .personData
                                          .value!['pendingDrinks']
                                          .toString()
                                      : controller
                                          .personData
                                          .value!['pending_drinks']
                                          .toString(),
                              isRedeemed:
                                  isAdminView
                                      ? controller
                                              .personData
                                              .value!['pendingDrinks'] <=
                                          0
                                      : controller
                                              .personData
                                              .value!['pending_drinks'] <=
                                          0,
                              inputWidget: DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  label: Text(
                                    'Select drinks',
                                    style: TextStyle(color: storkColor),
                                  ),
                                  labelStyle: const TextStyle(
                                    color: Colors.black,
                                  ),
                                  enabledBorder: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  border: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.all(14),
                                  errorText:
                                      controller.redeemFreeDrinkAmountErrorText,
                                  errorStyle: const TextStyle(
                                    color: Colors.red,
                                  ),
                                ),
                                value:
                                    controller
                                            .redeemFreeDrinkAmount
                                            .value
                                            .isEmpty
                                        ? null
                                        : controller
                                            .redeemFreeDrinkAmount
                                            .value,
                                items: List.generate(
                                  (isAdminView
                                      ? controller
                                              .personData
                                              .value!['pendingDrinks']
                                          as int
                                      : controller
                                              .personData
                                              .value!['pending_drinks']
                                          as int),
                                  (index) => DropdownMenuItem(
                                    value: '${index + 1}',
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                                onChanged:
                                    (value) =>
                                        controller.redeemFreeDrinkAmount.value =
                                            value ?? '',
                                iconEnabledColor: Colors.grey,
                                dropdownColor: Colors.white,
                                style: const TextStyle(color: Colors.white),
                              ),
                              buttonEnabled:
                                  controller.isRedeemFreeDrinksButtonEnabled,
                              onButtonPressed:
                                  controller.handleRedeemFreeDrinks,
                            ),
                      ],
                    ],
                  );
                } else {
                  return Center(
                    child: Text(
                      'Something went wrong. Please try again.',
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  );
                }
              }),
            ),
          ),
          Divider(),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Table No: ${controller.tableNo.value ?? 'N/A'}",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      "ID: ${controller.orderId.value ?? 'N/A'}",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                  ],
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }

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
    return (!isSingle && isRedeemed)
        ? const Padding(
          padding: EdgeInsets.only(top: 10),
          child: Text(
            '✅ Amount already fully redeemed.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        )
        : Padding(
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
                  if (!isSingle &&
                      balanceTitle != null &&
                      balanceAmount != null)
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
