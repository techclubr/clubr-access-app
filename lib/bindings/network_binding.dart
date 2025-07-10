import 'package:get/get.dart';
import '../controllers/network_controller.dart';

class NetworkBinding extends Bindings {
  @override
  void dependencies() {
    // Use Get.put to create and initialize the controller immediately.
    // Set permanent: true to ensure it's not removed from memory,
    // as network connectivity is a concern for the entire app lifecycle.
    Get.put<NetworkController>(NetworkController(), permanent: true);
  }
}