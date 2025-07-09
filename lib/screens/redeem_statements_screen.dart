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
      appBar: AppBar(
        title: const Text("Redeem Statements"),
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
              elevation: 2, // Subtle elevation for a clean look
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  10,
                ), // Gentle rounded corners
                side: BorderSide(
                  color: Colors.grey.shade200,
                  width: 0.8,
                ), // Very thin, light border
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Align content to the start
                  children: [
                    // Top Row: Code and Date/Time
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween, // Distribute space
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          // Allow the Code to take available space
                          child: Text(
                            "Code: ${item.uniqueCode}",
                            style: const TextStyle(
                              // Using default TextStyle
                              fontWeight:
                                  FontWeight.w600, // Semi-bold for prominence
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                            overflow:
                                TextOverflow.ellipsis, // Handle long codes
                          ),
                        ),
                        const SizedBox(width: 8), // Space between code and date
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
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color:
                                    Colors
                                        .green
                                        .shade700, // Emphasize monetary value
                              ),
                            ),
                          ],
                        ),
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
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color:
                                    Colors.blue.shade700, // Emphasize quantity
                              ),
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
