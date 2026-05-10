import 'package:get/get.dart';
import '../bindings/reels_binding.dart';
import '../views/reels_view.dart';
import '../views/add_reel_view.dart';

class AppRoutes {
  static const String reels = '/reels';
  static const String addReel = '/add-reel';
}

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.reels,
      page: () => const ReelsView(),
      binding: ReelsBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.addReel,
      page: () => const AddReelView(),
      transition: Transition.cupertino,
    ),
  ];
}
