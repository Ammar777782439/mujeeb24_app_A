import 'package:flutter/foundation.dart';
import '../../../core/catalog/catalog_repository.dart';
import '../../../core/errors/api_error.dart';
import '../../../core/models/catalog_models.dart';

/// State management provider for Catalog, Items, Variants, Offers, and Entity Contract.
class CatalogProvider extends ChangeNotifier {
  final CatalogRepository catalogRepository;

  CatalogProvider({required this.catalogRepository});

  // ==========================================
  // Catalogs State
  // ==========================================
  List<Catalog> _catalogs = [];
  Catalog? _selectedCatalog;
  bool _isLoadingCatalogs = false;
  String? _catalogsError;
  String _catalogStatusFilter = 'all';

  List<Catalog> get catalogs => _catalogs;
  Catalog? get selectedCatalog => _selectedCatalog;
  bool get isLoadingCatalogs => _isLoadingCatalogs;
  String? get catalogsError => _catalogsError;
  String get catalogStatusFilter => _catalogStatusFilter;

  // ==========================================
  // Catalog Items State
  // ==========================================
  List<CatalogItem> _catalogItems = [];
  CatalogItem? _selectedItem;
  bool _isLoadingItems = false;
  String? _itemsError;
  String _itemStatusFilter = 'all';
  String _itemSearchQuery = '';

  List<CatalogItem> get catalogItems => _catalogItems;
  CatalogItem? get selectedItem => _selectedItem;
  bool get isLoadingItems => _isLoadingItems;
  String? get itemsError => _itemsError;
  String get itemStatusFilter => _itemStatusFilter;
  String get itemSearchQuery => _itemSearchQuery;

  // ==========================================
  // Item Sub-resources: Variants & Offers
  // ==========================================
  List<Variant> _variants = [];
  List<Offer> _offers = [];
  bool _isLoadingItemDetail = false;
  String? _itemDetailError;

  List<Variant> get variants => _variants;
  List<Offer> get offers => _offers;
  bool get isLoadingItemDetail => _isLoadingItemDetail;
  String? get itemDetailError => _itemDetailError;

  // ==========================================
  // Attribute Schemas & Entity Contract
  // ==========================================
  List<AttributeSchema> _attributeSchemas = [];
  CatalogEntityContract _entityContract = CatalogEntityContract.defaults();
  bool _isLoadingContract = false;

  List<AttributeSchema> get attributeSchemas => _attributeSchemas;
  CatalogEntityContract get entityContract => _entityContract;
  bool get isLoadingContract => _isLoadingContract;

  // ==========================================
  // Action State (Mutations)
  // ==========================================
  bool _isPerformingAction = false;
  String? _actionError;

  bool get isPerformingAction => _isPerformingAction;
  String? get actionError => _actionError;

  // ==========================================
  // Catalog Methods
  // ==========================================

  void setCatalogStatusFilter(String status) {
    if (_catalogStatusFilter != status) {
      _catalogStatusFilter = status;
      notifyListeners();
    }
  }

  void selectCatalog(Catalog? catalog) {
    _selectedCatalog = catalog;
    _catalogItems = [];
    _selectedItem = null;
    _variants = [];
    _offers = [];
    notifyListeners();
  }

  Future<void> fetchCatalogs(
    String businessId, {
    bool refresh = false,
    String? status,
  }) async {
    if (businessId.isEmpty) return;
    _isLoadingCatalogs = true;
    _catalogsError = null;
    notifyListeners();

    try {
      final effectiveStatus = status ?? _catalogStatusFilter;
      final page = await catalogRepository.listCatalogs(
        businessId: businessId,
        status: effectiveStatus != 'all' ? effectiveStatus : null,
      );
      _catalogs = page.items;
      if (_selectedCatalog != null) {
        _selectedCatalog = _catalogs.firstWhere(
          (c) => c.id == _selectedCatalog!.id,
          orElse: () => _selectedCatalog!,
        );
      }
    } on ApiErrorEnvelope catch (e) {
      _catalogsError = e.error.message;
    } catch (e) {
      _catalogsError = e.toString();
    } finally {
      _isLoadingCatalogs = false;
      notifyListeners();
    }
  }

  Future<Catalog?> createCatalog(
    String businessId,
    CreateCatalogRequest request,
  ) async {
    _isPerformingAction = true;
    _actionError = null;
    notifyListeners();

    try {
      final created = await catalogRepository.createCatalog(
        businessId: businessId,
        request: request,
      );
      _catalogs = [created, ..._catalogs];
      return created;
    } on ApiErrorEnvelope catch (e) {
      _actionError = e.error.message;
      return null;
    } catch (e) {
      _actionError = e.toString();
      return null;
    } finally {
      _isPerformingAction = false;
      notifyListeners();
    }
  }

  Future<Catalog?> updateCatalog(
    String businessId,
    String catalogId,
    UpdateCatalogRequest request, {
    String? ifMatch,
  }) async {
    _isPerformingAction = true;
    _actionError = null;
    notifyListeners();

    try {
      final updated = await catalogRepository.updateCatalog(
        businessId: businessId,
        catalogId: catalogId,
        request: request,
        ifMatch: ifMatch ?? _selectedCatalog?.resourceVersion,
      );

      final index = _catalogs.indexWhere((c) => c.id == catalogId);
      if (index >= 0) {
        _catalogs[index] = updated;
      }
      if (_selectedCatalog?.id == catalogId) {
        _selectedCatalog = updated;
      }
      return updated;
    } on ApiErrorEnvelope catch (e) {
      _actionError = e.error.message;
      return null;
    } catch (e) {
      _actionError = e.toString();
      return null;
    } finally {
      _isPerformingAction = false;
      notifyListeners();
    }
  }

  // ==========================================
  // Catalog Item Methods
  // ==========================================

  void setItemStatusFilter(String status) {
    if (_itemStatusFilter != status) {
      _itemStatusFilter = status;
      notifyListeners();
    }
  }

  void setItemSearchQuery(String query) {
    _itemSearchQuery = query;
    notifyListeners();
  }

  void selectItem(CatalogItem? item) {
    _selectedItem = item;
    _variants = [];
    _offers = [];
    notifyListeners();
  }

  Future<void> fetchCatalogItems(
    String businessId,
    String catalogId, {
    bool refresh = false,
    String? status,
    String? search,
  }) async {
    if (businessId.isEmpty || catalogId.isEmpty) return;
    _isLoadingItems = true;
    _itemsError = null;
    notifyListeners();

    try {
      final effectiveStatus = status ?? _itemStatusFilter;
      final effectiveSearch = search ?? _itemSearchQuery;

      final page = await catalogRepository.listCatalogItems(
        businessId: businessId,
        catalogId: catalogId,
        status: effectiveStatus != 'all' ? effectiveStatus : null,
        search: effectiveSearch.isNotEmpty ? effectiveSearch : null,
      );
      _catalogItems = page.items;
      if (_selectedItem != null) {
        _selectedItem = _catalogItems.firstWhere(
          (i) => i.id == _selectedItem!.id,
          orElse: () => _selectedItem!,
        );
      }
    } on ApiErrorEnvelope catch (e) {
      _itemsError = e.error.message;
    } catch (e) {
      _itemsError = e.toString();
    } finally {
      _isLoadingItems = false;
      notifyListeners();
    }
  }

  Future<CatalogItem?> createCatalogItem(
    String businessId,
    String catalogId,
    CreateCatalogItemRequest request,
  ) async {
    _isPerformingAction = true;
    _actionError = null;
    notifyListeners();

    try {
      final created = await catalogRepository.createCatalogItem(
        businessId: businessId,
        catalogId: catalogId,
        request: request,
      );
      _catalogItems = [created, ..._catalogItems];
      return created;
    } on ApiErrorEnvelope catch (e) {
      _actionError = e.error.message;
      return null;
    } catch (e) {
      _actionError = e.toString();
      return null;
    } finally {
      _isPerformingAction = false;
      notifyListeners();
    }
  }

  Future<CatalogItem?> updateCatalogItem(
    String businessId,
    String catalogId,
    String itemId,
    UpdateCatalogItemRequest request, {
    String? ifMatch,
  }) async {
    _isPerformingAction = true;
    _actionError = null;
    notifyListeners();

    try {
      final updated = await catalogRepository.updateCatalogItem(
        businessId: businessId,
        catalogId: catalogId,
        itemId: itemId,
        request: request,
        ifMatch: ifMatch ?? _selectedItem?.resourceVersion,
      );

      final index = _catalogItems.indexWhere((i) => i.id == itemId);
      if (index >= 0) {
        _catalogItems[index] = updated;
      }
      if (_selectedItem?.id == itemId) {
        _selectedItem = updated;
      }
      return updated;
    } on ApiErrorEnvelope catch (e) {
      _actionError = e.error.message;
      return null;
    } catch (e) {
      _actionError = e.toString();
      return null;
    } finally {
      _isPerformingAction = false;
      notifyListeners();
    }
  }

  // ==========================================
  // Item Detail & Sub-resources
  // ==========================================

  Future<void> fetchItemDetail(
    String businessId,
    String catalogId,
    String itemId,
  ) async {
    if (businessId.isEmpty || catalogId.isEmpty || itemId.isEmpty) return;
    _isLoadingItemDetail = true;
    _itemDetailError = null;
    notifyListeners();

    try {
      final itemFuture = catalogRepository.getCatalogItem(
        businessId: businessId,
        catalogId: catalogId,
        itemId: itemId,
      );
      final variantsFuture = catalogRepository.listVariants(
        businessId: businessId,
        itemId: itemId,
      );
      final offersFuture = catalogRepository.listOffers(
        businessId: businessId,
        itemId: itemId,
      );

      final results = await Future.wait([
        itemFuture,
        variantsFuture,
        offersFuture,
      ]);

      _selectedItem = results[0] as CatalogItem;
      _variants = (results[1] as VariantPage).items;
      _offers = (results[2] as OfferPage).items;
    } on ApiErrorEnvelope catch (e) {
      _itemDetailError = e.error.message;
    } catch (e) {
      _itemDetailError = e.toString();
    } finally {
      _isLoadingItemDetail = false;
      notifyListeners();
    }
  }

  // ==========================================
  // Variants
  // ==========================================

  Future<Variant?> createVariant(
    String businessId,
    String itemId,
    CreateVariantRequest request,
  ) async {
    _isPerformingAction = true;
    _actionError = null;
    notifyListeners();

    try {
      final created = await catalogRepository.createVariant(
        businessId: businessId,
        itemId: itemId,
        request: request,
      );
      _variants = [..._variants, created];
      return created;
    } on ApiErrorEnvelope catch (e) {
      _actionError = e.error.message;
      return null;
    } catch (e) {
      _actionError = e.toString();
      return null;
    } finally {
      _isPerformingAction = false;
      notifyListeners();
    }
  }

  Future<Variant?> updateVariant(
    String businessId,
    String variantId,
    UpdateVariantRequest request, {
    String? ifMatch,
  }) async {
    _isPerformingAction = true;
    _actionError = null;
    notifyListeners();

    try {
      final currentVariant = _variants.firstWhere(
        (v) => v.id == variantId,
        orElse: () => Variant(
          id: variantId,
          businessId: businessId,
          catalogItemId: '',
          name: '',
          status: 'active',
          resourceVersion: '1',
        ),
      );

      final updated = await catalogRepository.updateVariant(
        businessId: businessId,
        variantId: variantId,
        request: request,
        ifMatch: ifMatch ?? currentVariant.resourceVersion,
      );

      final index = _variants.indexWhere((v) => v.id == variantId);
      if (index >= 0) {
        _variants[index] = updated;
      }
      return updated;
    } on ApiErrorEnvelope catch (e) {
      _actionError = e.error.message;
      return null;
    } catch (e) {
      _actionError = e.toString();
      return null;
    } finally {
      _isPerformingAction = false;
      notifyListeners();
    }
  }

  // ==========================================
  // Offers
  // ==========================================

  Future<Offer?> createOffer(
    String businessId,
    String itemId,
    CreateOfferRequest request,
  ) async {
    _isPerformingAction = true;
    _actionError = null;
    notifyListeners();

    try {
      final created = await catalogRepository.createOffer(
        businessId: businessId,
        itemId: itemId,
        request: request,
      );
      _offers = [..._offers, created];
      return created;
    } on ApiErrorEnvelope catch (e) {
      _actionError = e.error.message;
      return null;
    } catch (e) {
      _actionError = e.toString();
      return null;
    } finally {
      _isPerformingAction = false;
      notifyListeners();
    }
  }

  Future<Offer?> updateOffer(
    String businessId,
    String offerId,
    UpdateOfferRequest request, {
    String? ifMatch,
  }) async {
    _isPerformingAction = true;
    _actionError = null;
    notifyListeners();

    try {
      final currentOffer = _offers.firstWhere(
        (o) => o.id == offerId,
        orElse: () => Offer(
          id: offerId,
          businessId: businessId,
          catalogItemId: '',
          name: '',
          pricingMode: 'fixed',
          priceVerificationStatus: 'unverified',
          availabilityMode: 'stock',
          fulfillmentMode: 'delivery',
          availabilityStatus: 'available',
          status: 'active',
          resourceVersion: '1',
        ),
      );

      final updated = await catalogRepository.updateOffer(
        businessId: businessId,
        offerId: offerId,
        request: request,
        ifMatch: ifMatch ?? currentOffer.resourceVersion,
      );

      final index = _offers.indexWhere((o) => o.id == offerId);
      if (index >= 0) {
        _offers[index] = updated;
      }
      return updated;
    } on ApiErrorEnvelope catch (e) {
      _actionError = e.error.message;
      return null;
    } catch (e) {
      _actionError = e.toString();
      return null;
    } finally {
      _isPerformingAction = false;
      notifyListeners();
    }
  }

  // ==========================================
  // Contract & Schemas
  // ==========================================

  Future<void> fetchEntityContract(String businessId) async {
    if (businessId.isEmpty) return;
    _isLoadingContract = true;
    notifyListeners();

    try {
      final contract = await catalogRepository.getCatalogEntityContract(
        businessId: businessId,
      );
      _entityContract = contract;
    } catch (_) {
      // Keep defaults
    } finally {
      _isLoadingContract = false;
      notifyListeners();
    }
  }

  Future<void> fetchAttributeSchemas(String businessId) async {
    if (businessId.isEmpty) return;
    try {
      final schemas = await catalogRepository.listAttributeSchemas(
        businessId: businessId,
      );
      _attributeSchemas = schemas;
      notifyListeners();
    } catch (_) {
      // Non-critical, ignore
    }
  }
}
