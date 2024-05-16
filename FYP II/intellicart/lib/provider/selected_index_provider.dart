import 'package:get/get.dart';

class SelectedIndexController extends GetxController {
  var selectedIndex = 0.obs;

  void setIndex(int index) {
    selectedIndex.value = index;
  }
}