import 'package:hugeicons/hugeicons.dart';

/// Single place that maps what an icon *means* in this app to a Hugeicons
/// glyph. Widgets use AppIcons.home, never HugeIcons.* directly, so a
/// wrong or renamed icon is a one-line fix here.
///
/// These names are my best recollection of the free stroke-rounded set.
/// Check each one with your editor's autocomplete (type `HugeIcons.strokeRounded`
/// and browse), and swap any that show a red underline.
typedef AppIcon = List<List<dynamic>>;
abstract final class AppIcons {
  static const home = HugeIcons.strokeRoundedHome09;
  static const favorite = HugeIcons.strokeRoundedFavourite;
  static const cart = HugeIcons.strokeRoundedShoppingCartCheckIn02;
  static const orders = HugeIcons.strokeRoundedFile01;
  static const account = HugeIcons.strokeRoundedUser;
  static const notification = HugeIcons.strokeRoundedNotification01;
  static const search = HugeIcons.strokeRoundedSearch01;
  static const filter = HugeIcons.strokeRoundedFilterHorizontal;
  static const back = HugeIcons.strokeRoundedArrowLeft01;
  static const add = HugeIcons.strokeRoundedAdd01;
  static const delete = HugeIcons.strokeRoundedDelete02;
  static const shoppingBag = HugeIcons.strokeRoundedShoppingBag01;
  static const location = HugeIcons.strokeRoundedLocation01;
  static const card = HugeIcons.strokeRoundedCreditCard;
  static const wallet = HugeIcons.strokeRoundedWallet01;
  static const lock = HugeIcons.strokeRoundedLockPassword;
  static const language = HugeIcons.strokeRoundedGlobe02;
  static const support = HugeIcons.strokeRoundedCustomerSupport;
  static const privacy = HugeIcons.strokeRoundedShield01;
  static const store = HugeIcons.strokeRoundedStore01;
  static const camera = HugeIcons.strokeRoundedCamera01;
  static const email = HugeIcons.strokeRoundedMail01;
  static const phone = HugeIcons.strokeRoundedCall;
  static const delivery = HugeIcons.strokeRoundedDeliverySent01;
  static const promotion = HugeIcons.strokeRoundedDiscountTag01;
  static const chevronRight = HugeIcons.strokeRoundedArrowRight01;
}