import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qrzone/controllers/admin_bottom_sheet_controller.dart';
import 'package:qrzone/controllers/bottom_sheet_controller.dart';
import 'package:qrzone/widgets/admin_bottom_sheet.dart';
import 'package:qrzone/widgets/bottom_sheet.dart';

class ScanningScreen extends StatefulWidget {
  const ScanningScreen({super.key});

  @override
  State<ScanningScreen> createState() => _ScanningScreenState();
}

class _ScanningScreenState extends State<ScanningScreen>
    with SingleTickerProviderStateMixin {
  final MobileScannerController _controller = MobileScannerController();

  final BottomSheetController _bottomSheetController = Get.put(
    BottomSheetController(),
  );
  final AdminBottomSheetController _adminBottomSheetController = Get.put(
    AdminBottomSheetController(),
  );

  Barcode? _barcode;
  String? _lastScannedValue;

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );
  }

  Widget _barcodePreview(Barcode? value) {
    if (value == null) {
      return const Text(
        'Scan something!',
        overflow: TextOverflow.fade,
        style: TextStyle(color: Colors.white),
      );
    }

    return Text(
      value.displayValue ?? 'No display value.',
      overflow: TextOverflow.fade,
      style: const TextStyle(color: Colors.white),
    );
  }

  void _handleBarcode(BarcodeCapture barcodes) async {
    if (!mounted) return;

    try {
      final barcode = barcodes.barcodes.firstOrNull;
      if (barcode != null && barcode.displayValue != null) {
        // Prevent showing the bottom sheet for the same scan
        if (_lastScannedValue != barcode.displayValue) {
          setState(() {
            _barcode = barcode;
            _lastScannedValue = barcode.displayValue;
          });

          // Stop the camera before showing the bottom sheet
          await _controller.stop();
          // Stop the animation
          _animationController.stop();

          if (!mounted) return;
          if (_lastScannedValue == null) {
            Fluttertoast.showToast(
              msg: 'No QR code data found',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.red,
              textColor: Colors.white,
            );
          }
          String cleanContent = _lastScannedValue!.trim();
          if (cleanContent.startsWith('"') && cleanContent.endsWith('"')) {
            cleanContent = cleanContent.substring(1, cleanContent.length - 1);
          }
          final parts = cleanContent.split('-');
          print('Split parts: $parts');
          if (parts.length == 2 &&
              parts[0].isNotEmpty &&
              int.tryParse(parts[1]) != null) {
            final orderId = parts[0];
            final personNo = int.parse(parts[1]);

            print(personNo);
            print(personNo.runtimeType);

            if (personNo == 0) {
              _adminBottomSheetController.orderId.value = parts[0];
              _adminBottomSheetController.personNo.value = int.parse(parts[1]);

              log("fetching admin person data");

              await _adminBottomSheetController.initializeWithContent();
              // Show the bottom sheet with the scanned value
              await showModalBottomSheet<bool>(
                context: context,
                backgroundColor: Colors.white,
                barrierColor: Colors.black87,
                showDragHandle: true,
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                  minWidth: MediaQuery.of(context).size.width * 0.9,
                ),
                builder:
                    (context) => AdminBottomSheetWidget(
                      content: _lastScannedValue,
                      show: true,
                    ),
              );

              setState(() {
                _lastScannedValue = null;
              });
              // Restart the camera when the bottom sheet is closed
              _controller.start();
              // Restart the animation
              _animationController.repeat(reverse: true);
            } else {
              log("fetching user person data");
              _bottomSheetController.orderId.value = parts[0];
              _bottomSheetController.personNo.value = int.parse(parts[1]);

              _bottomSheetController.initializeWithContent();
              // Show the bottom sheet with the scanned value
              // Show the bottom sheet with the scanned value
              await showModalBottomSheet<bool>(
                context: context,
                backgroundColor: Colors.transparent,
                builder:
                    (context) => BottomSheetWidget(
                      content: _lastScannedValue,
                      show: true,
                    ),
              );

              setState(() {
                _lastScannedValue = null;
              });
              // Restart the camera when the bottom sheet is closed
              _controller.start();
              // Restart the animation
              _animationController.repeat(reverse: true);
            }
          } else {
            Fluttertoast.showToast(
              msg: 'Invalid QR code format. Expected "order_id-person_no".',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.red,
              textColor: Colors.white,
            );
          }
        }
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error processing QR code: $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scanAreaSize = size.width * 0.8;
    final scanTop = (size.height - scanAreaSize) / 2;

    return Scaffold(
      body: Stack(
        children: [
          MobileScanner(controller: _controller, onDetect: _handleBarcode),

          /// Outline Border
          Positioned(
            top: scanTop,
            left: size.width * 0.1,
            child: Container(
              width: scanAreaSize,
              height: scanAreaSize,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          /// Scanning Line Effect
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Positioned(
                top: scanTop + (scanAreaSize * _animation.value),
                left: size.width * 0.1,
                child: Container(
                  width: scanAreaSize,
                  height: 2,
                  color: Colors.greenAccent,
                ),
              );
            },
          ),
          // Align(
          //   alignment: Alignment.bottomCenter,
          //   child: Container(
          //     alignment: Alignment.bottomCenter,
          //     height: 100,
          //     color: const Color.fromRGBO(0, 0, 0, 0.4),
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //       children: [
          //         Expanded(child: Center(child: _barcodePreview(_barcode))),
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
