import 'package:flutter/material.dart';
import 'package:havka/core/constants/colors.dart';
import 'package:havka/data/models/pfc_data_item.dart';
import '../../core/constants/icons.dart';
import '../../data/models/fridge/user_fridge_model.dart';
import '../../domain/entities/fridge/fridge.dart';
import '../../domain/entities/fridge/user_fridge.dart';
import '../../domain/entities/product/fridge_item.dart';
import '../../domain/entities/product/product.dart';
import '../../domain/repositories/fridge/fridge_repository.dart';
import '../widgets/fridge_item_row.dart';

enum ProductSortType { createdAt, protein, fat, carbs }

class FridgeProvider extends ChangeNotifier {
  final FridgeRepository _fridgeRepository;
  final GlobalKey<AnimatedListState> fridgeItemsAndroidListKey = GlobalKey<AnimatedListState>();
  final GlobalKey<SliverAnimatedListState> fridgeItemsIOSListKey = GlobalKey<SliverAnimatedListState>();

  List<UserFridge> _userFridges = [];
  UserFridge? _currentUserFridge;
  List<FridgeItem> _fridgeItems = [];
  FridgeItem? _createdFridgeItem = null;
  bool _isLoading = false;
  bool _isFridgeItemsLoading = false;

  ProductSortType _sortType = ProductSortType.createdAt;
  ProductSortType get sortType => _sortType;

  bool _isAscending = false;
  bool get isAscending => _isAscending;

  FridgeProvider({
    required FridgeRepository fridgeRepository,
  })
      : _fridgeRepository = fridgeRepository;

  List<UserFridge> get userFridges => _userFridges;
  UserFridge? get currentUserFridge => _currentUserFridge;
  List<FridgeItem> get fridgeItems => _fridgeItems;
  FridgeItem? get createdFridgeItem => _createdFridgeItem;
  bool get isLoading => _isLoading;
  bool get isFridgeItemsLoading => _isFridgeItemsLoading;

  Future<void> fetchUserFridges() async {
    _isLoading = true;
    notifyListeners();

    try {
      _userFridges = await _fridgeRepository.getAllUserFridges();
    } catch (e) {
      debugPrint('Failed to fetch user fridges: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setCurrentUserFridge(UserFridge userFridge) async {
    _currentUserFridge = userFridge;
    await fetchFridgeItems();
    notifyListeners();
  }

  Future<void> fetchFridgeItems() async {
    if (_currentUserFridge == null) return;
    _isFridgeItemsLoading = true;
    notifyListeners();
    try {
      _fridgeItems =
      await _fridgeRepository.getAllFridgeItems(_currentUserFridge!.fridgeId);
      _sortFridgeItems();
    } catch (e) {
      throw('Failed to fetch fridge items: $e');
    } finally {
      _isFridgeItemsLoading = false;
      notifyListeners();
    }
  }

  List<PFCDataItem> getFridgeNutrition() {
    if (_fridgeItems.isEmpty) return [];
    return [
      PFCDataItem(
        value: _fridgeItems.map((e) => e.product.nutrition!.protein!.total ?? 0).reduce((value, element) => value + element),
        label: 'Protein',
        color: HavkaColors.protein,
        icon: HavkaIcons.protein,
      ),
      PFCDataItem(
        value: _fridgeItems.map((e) => e.product.nutrition!.fat!.total ?? 0).reduce((value, element) => value + element),
        label: 'Fat',
        color: HavkaColors.fat,
        icon: HavkaIcons.fat,
      ),
      PFCDataItem(
        value: _fridgeItems.map((e) => e.product.nutrition!.carbs!.total ?? 0).reduce((value, element) => value + element),
        label: 'Carbs',
        color: HavkaColors.carbs,
        icon: HavkaIcons.carbs,
      ),
    ];
  }

  Future<Fridge> createNewFridge() async {
    try {
      final addedFridge = await _fridgeRepository.createNewFridge();
      notifyListeners();
      return addedFridge;
    } catch (e) {
      throw('Failed to add Fridge: $e');
    }
  }

  Future<void> deleteFridge(String id) async {
    try {
      await _fridgeRepository.deleteFridge(id);
      notifyListeners();
    } catch (e) {
      throw('Failed to delete fridge: $e');
    }
  }

  Future<void> createUserFridge(String name, {String? fridgeId}) async {
    try {
      final newUserFridge = await _fridgeRepository.createUserFridge(name, fridgeId);
      _userFridges.add(newUserFridge);
      setCurrentUserFridge(newUserFridge);
      notifyListeners();
    } catch (e) {
      throw('Failed to add UserFridge: $e');
    }
  }

  Future<void> updateUserFridge(UserFridge userFridge) async {
    try {
      final updatedFridge = await _fridgeRepository.updateUserFridge(userFridge);
      final index = _userFridges.indexWhere((f) => f.id == userFridge.id);
      if (index != -1) {
        _userFridges[index] = updatedFridge;
        setCurrentUserFridge(updatedFridge);
        notifyListeners();
      } else {
        throw 'UserFridge with ID ${userFridge.id} not found';
      }
    } catch (e) {
      throw('Failed to update UserFridge: $e');
    }
  }

  Future<void> deleteUserFridge(UserFridge userFridge) async {
    try {
      await _fridgeRepository.deleteUserFridge(userFridge);
      _userFridges.remove(userFridge);
      setCurrentUserFridge(_userFridges.first);
      notifyListeners();
    } catch (e) {
      throw('Failed to delete UserFridge: $e');
    }
  }

  Future<void> createFridgeItem(String fridgeId, String productId) async {
    try {
      _createdFridgeItem = await _fridgeRepository.createFridgeItem(fridgeId, productId);
      _fridgeItems.add(_createdFridgeItem!);
      fridgeItemsAndroidListKey.currentState?.insertItem(0, duration: Duration(milliseconds: 300));
      fridgeItemsIOSListKey.currentState?.insertItem(0, duration: Duration(milliseconds: 300));
      notifyListeners();
    } catch (e) {
      throw('Failed to create FridgeItem: $e');
    }
  }

  Future<void> deleteFridgeItem(FridgeItem fridgeItem) async {
    final index = _fridgeItems.indexOf(fridgeItem);
    try {
      await _fridgeRepository.deleteFridgeItem(fridgeItem.id!);
      _fridgeItems.remove(fridgeItem);

      fridgeItemsAndroidListKey.currentState?.removeItem(
          index,
          (context, animation) => FadeTransition(
            opacity: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(animation),
            child: SizeTransition(
              sizeFactor: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(0, -0.5),
                  end: Offset.zero,
                ).animate(animation),
                child: FridgeItemRow(
                  fridgeItem: fridgeItem,
                ),
              ),
            ),
          ),
          duration: Duration(milliseconds: 300)
      );

      fridgeItemsIOSListKey.currentState?.removeItem(
          index,
              (context, animation) => FadeTransition(
            opacity: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(animation),
            child: SizeTransition(
              sizeFactor: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(0, -0.5),
                  end: Offset.zero,
                ).animate(animation),
                child: FridgeItemRow(
                  fridgeItem: fridgeItem,
                ),
              ),
            ),
          ),
          duration: Duration(milliseconds: 300)
      );
      notifyListeners();
    } catch (e) {
      throw('Failed to delete FridgeItem: $e');
    }
  }

  void setSortType(ProductSortType type) {
    if (_sortType == type) {
      toggleSortOrder();
    } else {
      _sortType = type;
    }
    _sortFridgeItems();
    notifyListeners();
  }

  void resetSortType() {
    _sortType = ProductSortType.createdAt;
    // _isAscending = true;
    _sortFridgeItems();
    notifyListeners();
  }

  void toggleSortOrder() {
    _isAscending = !_isAscending;
    _sortFridgeItems();
    notifyListeners();
  }

  void _sortFridgeItems() {
    _fridgeItems.sort((a, b) {
      int compare;
      switch (_sortType) {
        case ProductSortType.createdAt:
          compare = a.createdAt.compareTo(b.createdAt);
          break;
        case ProductSortType.protein:
          compare = a.product.nutrition!.protein!.total!.compareTo(b.product.nutrition!.protein!.total!);
          break;
        case ProductSortType.fat:
          compare = a.product.nutrition!.fat!.total!.compareTo(b.product.nutrition!.fat!.total!);
          break;
        case ProductSortType.carbs:
          compare = a.product.nutrition!.carbs!.total!.compareTo(b.product.nutrition!.carbs!.total!);
          break;
      }
      return _isAscending ? compare : -compare;
    });
  }
}
