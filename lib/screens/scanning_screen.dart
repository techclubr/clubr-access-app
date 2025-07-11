import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qrzone/controllers/bottom_sheet_controller.dart';
import 'package:qrzone/widgets/bottom_sheet.dart';

class ScanningScreen extends StatefulWidget {
  const ScanningScreen({super.key});

  @override
  State<ScanningScreen> createState() => _ScanningScreenState();
}

class _ScanningScreenState extends State<ScanningScreen>
    with SingleTickerProviderStateMixin {
  final MobileScannerController _controller = MobileScannerController(
    torchEnabled: true,
  );

  // Use a single BottomSheetController now
  final BottomSheetController _bottomSheetController = Get.put(
    BottomSheetController(),
  );

  Barcode? _barcode;
  String? _lastScannedValue;
  bool _isProcessingBarcode = false; // Add a flag to prevent multiple triggers

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
    if (!mounted || _isProcessingBarcode) return; // Prevent re-entry

    _isProcessingBarcode = true;

    // remove the last scanned value and controller
    _bottomSheetController.clearControllerValues();

    try {
      final barcode = barcodes.barcodes.firstOrNull;
      if (barcode != null && barcode.displayValue != null) {
        // Prevent showing the bottom sheet for the same scan
        if (_lastScannedValue != barcode.displayValue) {
          setState(() {
            _barcode = barcode;
            _lastScannedValue = barcode.displayValue;
          });

          // Stop the camera before showing any UI
          await _controller.stop();
          // Stop the animation
          _animationController.stop();

          if (!mounted) {
            _isProcessingBarcode = false; // Reset flag
            return;
          }

          if (_lastScannedValue == null) {
            Fluttertoast.showToast(
              msg: 'No QR code data found',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.red,
              textColor: Colors.white,
            );
            _isProcessingBarcode = false; // Reset flag
            _controller.start(); // Restart camera
            _animationController.repeat(reverse: true); // Restart animation
            return;
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

            // Set the orderId and personNo in the single controller
            _bottomSheetController.orderId.value = orderId;
            _bottomSheetController.personNo.value = personNo;

            log("fetching data for person: $personNo");

            await _bottomSheetController.initializeWithContent();

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
                  (context) => BottomSheetWidget(
                    // Always use BottomSheetWidget
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
            // Invalid QR code format: Show popup, stop camera and animation
            await showDialog<void>(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext dialogContext) {
                return AlertDialog(
                  title: const Text('Invalid QR Code'),
                  content: const Text(
                    'This QR code is not valid. Please scan a valid Clubr QR code.',
                  ),
                  actions: <Widget>[
                    FilledButton(
                      child: const Text('OK'),
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                      },
                    ),
                  ],
                );
              },
            );

            _controller.start();
            _animationController.repeat(reverse: true);
            _lastScannedValue = null;
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
      _controller.start(); // Restart camera even on error
      _animationController.repeat(reverse: true); // Restart animation on error
    } finally {
      _isProcessingBarcode = false; // Reset flag in finally block
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
      appBar: AppBar(
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Image.asset(
          "assets/icons/header-logo.png",
          fit: BoxFit.cover,
          height: 36,
        ),
        backgroundColor: Colors.black,
      ),
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
        ],
      ),
    );
  }
}
