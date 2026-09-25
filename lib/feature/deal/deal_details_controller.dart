import 'package:get/get.dart';

import '../../model/deal_model.dart';
import '../../repository/deal_repo.dart';
import '../../service/analytics_service.dart';
import '../../service/api_exception.dart';
import '../../service/cart_service.dart';
import '../../util/log_service.dart';

class DealDetailsController extends GetxController {
  final DealRepo dealRepo;
  final CartService cartService;
  final AnalyticsService analytics;

  DealDetailsController({
    required this.dealRepo,
    required this.cartService,
    required this.analytics,
  });

  late final int dealId;
  late final Worker _cartWorker;

  final _deal = Rxn<DealModel>();
  DealModel? get deal => _deal.value;

  final _quantityLeft = RxnInt();
  int? get quantityLeft => _quantityLeft.value;

  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    // In-app navigation passes the DealModel as an argument, but a deep link
    // (rescu://open/deal?id=42) only carries the id in the query string.
    final passed = Get.arguments;
    if (passed is DealModel) {
      dealId = passed.id;
      _setDeal(passed);
    } else {
      dealId = int.tryParse(Get.parameters['id'] ?? '') ?? -1;
      loadDeal();
    }
    analytics.logEvent('deal_details_view', {
      'deal_id': dealId,
      'source': Get.parameters['source'] ?? 'unknown',
    });
    // Whenever the cart changes, re-check this deal's remaining stock so the
    // details screen never shows stale availability.
    _cartWorker = ever(cartService.itemCount, (_) => _recheckAvailability());
  }

  @override
  void onClose() {
    _cartWorker.dispose();
    super.onClose();
  }

  Future<void> loadDeal() async {
    errorMessage.value = null;
    try {
      _setDeal(await dealRepo.fetchById(dealId));
    } on ApiException catch (e) {
      LogService.error('failed to load deal $dealId', e);
      errorMessage.value = e.message;
    }
  }

  void _setDeal(DealModel deal) {
    _deal.value = deal;
    _quantityLeft.value = deal.quantityLeft;
  }

  Future<void> _recheckAvailability() async {
    if (deal == null) return;
    LogService.log('re-checking availability for deal $dealId');
    final fresh = await dealRepo.fetchById(dealId);
    _quantityLeft.value = fresh.quantityLeft;
  }

  void addToCart() {
    final deal = this.deal;
    if (deal == null) return;
    cartService.add(deal);
    Get.snackbar(
      'Added to bag',
      '${deal.name} — pick up ${deal.pickupWindow.label}',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }
}
