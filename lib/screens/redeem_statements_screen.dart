import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/redeem_statement_controller.dart';

class RedeemStatementsScreen extends StatefulWidget {
  final String orderId;

  const RedeemStatementsScreen({super.key, required this.orderId});

  @override
  State<RedeemStatementsScreen> createState() => _RedeemStatementsScreenState();
}

class _RedeemStatementsScreenState extends State<RedeemStatementsScreen> {
  final RedeemStatementController controller = Get.put(
    RedeemStatementController(),
  );

  @override
  void initState() {
    super.initState();
    controller.fetchStatements(widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Redeem Statements", style: TextStyle(fontSize: 15)),
            Text("ID: ${widget.orderId}"),
          ],
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.statements.isEmpty) {
          return const Center(child: Text("No redeem statements found."));
        }

        // Assuming 'controller' and 'Statement' class are defined elsewhere
        // Make sure your Statement class has uniqueCode, redeemedCoverCharges,
        // redeemedFreeDrinks, and createdAt properties.
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.statements.length,
          itemBuilder: (context, index) {
            final item = controller.statements[index];
            return Card(
              color: Colors.white,
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          // Allow the Code to take available space
                          child: Text(
                            "Code: ${item.uniqueCode}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          // Date and Time stacked
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              DateFormat(
                                'MMM dd, yyyy',
                              ).format(item.createdAt), // Date part
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              DateFormat(
                                'hh:mm a',
                              ).format(item.createdAt), // Time part
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(
                      height: 18,
                      thickness: 0.8,
                      color: Colors.grey,
                    ), // Subtle separator
                    // Middle Section: Charges and Drinks
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween, // Space out details
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (item.redeemedCoverCharges > 0)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Cover Charges",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "₹${item.redeemedCoverCharges}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                    ),
                                  ),
                                ],
                              ),
                            if (item.redeemedFreeDrinks > 0)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "Free Drinks",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${item.redeemedFreeDrinks}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                    // You can add more rows here for additional details if needed
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
