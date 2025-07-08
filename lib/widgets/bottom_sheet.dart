import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qrzone/controllers/bottom_sheet_controller.dart';

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

    return GestureDetector(
      onTap: () {
        Get.back(); // Use Get.back() to pop the bottom sheet
      },
      child: Container(
        color: Colors.black.withAlpha(89),
        child: GestureDetector(
          onTap: () {}, // Prevent closing when tapping inside
          child: DraggableScrollableSheet(
            initialChildSize: 0.55,
            minChildSize: 0.3,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 20,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.back(); // Use Get.back() to pop the bottom sheet
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          size: 28,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          child: Obx(() {
                            if (controller.isLoading.value) {
                              return const Center(
                                child: Text(
                                  'Loading...',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            } else if (controller.personData.value != null) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (controller
                                          .personData
                                          .value!['cover_charges'] >
                                      0) ...[
                                    _buildSection(
                                      title: 'Cover Charges',
                                      amount:
                                          '₹${controller.personData.value!['cover_charges']}',
                                      balanceTitle: 'Balance Amount',
                                      balanceAmount:
                                          '₹${controller.personData.value!['pending_amount']}',
                                      isRedeemed:
                                          controller
                                              .personData
                                              .value!['pending_amount'] <=
                                          0,
                                      inputWidget: TextField(
                                        controller:
                                            controller.redeemAmountController,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Enter amount',
                                          hintStyle: const TextStyle(
                                            color: Colors.white,
                                          ),
                                          border: const OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(10),
                                            ),
                                          ),
                                          contentPadding: const EdgeInsets.all(
                                            14,
                                          ),
                                          errorText:
                                              controller
                                                  .redeemAmountErrorText, // Use GetX getter for error
                                          errorStyle: const TextStyle(
                                            color: Colors.red,
                                          ),
                                        ),
                                        keyboardType: TextInputType.number,
                                        onChanged:
                                            (value) =>
                                                controller.redeemAmount.value =
                                                    value,
                                      ),
                                      buttonEnabled:
                                          controller
                                              .isRedeemAmountButtonEnabled, // Use GetX getter
                                      onButtonPressed:
                                          controller.handleRedeemAmount,
                                    ),
                                  ],
                                  if (controller
                                          .personData
                                          .value!['free_drinks'] >
                                      0) ...[
                                    _buildSection(
                                      title: 'Free Drinks',
                                      amount:
                                          controller
                                              .personData
                                              .value!['free_drinks']
                                              .toString(),
                                      balanceTitle: 'Pending Drinks',
                                      balanceAmount:
                                          controller
                                              .personData
                                              .value!['pending_drinks']
                                              .toString(),
                                      isRedeemed:
                                          controller
                                              .personData
                                              .value!['pending_drinks'] <=
                                          0,
                                      inputWidget: DropdownButtonFormField<
                                        String
                                      >(
                                        decoration: InputDecoration(
                                          label: const Text(
                                            'Select drinks',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          labelStyle: const TextStyle(
                                            color: Colors.white,
                                          ),
                                          enabledBorder:
                                              const OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(10),
                                                ),
                                                borderSide: BorderSide(
                                                  color: Colors.white,
                                                ),
                                              ),
                                          focusedBorder:
                                              const OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(10),
                                                ),
                                                borderSide: BorderSide(
                                                  color: Colors.white,
                                                ),
                                              ),
                                          border: const OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(10),
                                            ),
                                          ),
                                          contentPadding: const EdgeInsets.all(
                                            14,
                                          ),
                                          errorText:
                                              controller
                                                  .redeemFreeDrinkAmountErrorText, // Use GetX getter for error
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
                                          (controller
                                                  .personData
                                                  .value!['pending_drinks']
                                              as int),
                                          (index) => DropdownMenuItem(
                                            value: '${index + 1}',
                                            child: Text(
                                              '${index + 1}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                        onChanged:
                                            (value) =>
                                                controller
                                                    .redeemFreeDrinkAmount
                                                    .value = value ?? '',
                                        iconEnabledColor: Colors.white,
                                        dropdownColor: Colors.grey[800],
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      buttonEnabled:
                                          controller
                                              .isRedeemFreeDrinksButtonEnabled, // Use GetX getter
                                      onButtonPressed:
                                          controller.handleRedeemFreeDrinks,
                                    ),
                                  ],
                                  if (controller.tableNo.value != null &&
                                      controller.tableNo.value != 0) ...[
                                    _buildSection(
                                      title: 'Table No',
                                      amount:
                                          controller.tableNo.value.toString(),
                                      isSingle: true,
                                    ),
                                  ],
                                ],
                              );
                            } else {
                              return Center(
                                child: Text(
                                  'No data found for Person #${controller.personNo.value}',
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 16,
                                  ),
                                ),
                              );
                            }
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.only(bottom: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12)),
      ),
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
                    style: const TextStyle(fontSize: 17, color: Colors.white),
                  ),
                  Text(
                    amount,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
                      style: const TextStyle(fontSize: 17, color: Colors.white),
                    ),
                    Text(
                      balanceAmount,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
                  Expanded(flex: 7, child: inputWidget),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 3,
                    child: ElevatedButton(
                      onPressed: buttonEnabled ? onButtonPressed : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        disabledBackgroundColor: Colors.grey[900],
                        padding: const EdgeInsets.all(14),
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
