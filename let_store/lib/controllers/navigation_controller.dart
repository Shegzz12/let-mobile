import 'package:get/get.dart';

class NavigationController extends GetxController {
  RxInt currentIndex = 0.obs;

  void changeIndex(index) {
    currentIndex.value = index;
  }
}
