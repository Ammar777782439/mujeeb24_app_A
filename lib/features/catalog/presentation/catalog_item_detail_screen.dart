import 'package:flutter/material.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/models/catalog_models.dart';
import '../providers/catalog_provider.dart';
import 'catalog_item_form_screen.dart';

/// Screen displaying complete details for a CatalogItem, its Variants, and Offers.
class CatalogItemDetailScreen extends StatefulWidget {
  final CatalogProvider catalogProvider;
  final String businessId;
  final String catalogId;
  final String itemId;

  const CatalogItemDetailScreen({
    super.key,
    required this.catalogProvider,
    required this.businessId,
    required this.catalogId,
    required this.itemId,
  });

  @override
  State<CatalogItemDetailScreen> createState() =>
      _CatalogItemDetailScreenState();
}

class _CatalogItemDetailScreenState extends State<CatalogItemDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDetails();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDetails() async {
    await widget.catalogProvider.fetchItemDetail(
      widget.businessId,
      widget.catalogId,
      widget.itemId,
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return AppColors.statusSuccess;
      case 'draft':
        return AppColors.statusWarning;
      case 'inactive':
      case 'expired':
        return AppColors.statusError;
      case 'archived':
      default:
        return AppColors.textMuted;
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status) {
      case 'active':
        return AppColors.statusSuccessContainer;
      case 'draft':
        return AppColors.statusWarningContainer;
      case 'inactive':
      case 'expired':
        return AppColors.statusErrorContainer;
      case 'archived':
      default:
        return AppColors.surfaceSubtle;
    }
  }

  Color _getAvailabilityColor(String status) {
    switch (status) {
      case 'available':
        return AppColors.statusSuccess;
      case 'unavailable':
        return AppColors.statusError;
      case 'requires_check':
      case 'unknown':
      case 'stale':
      default:
        return AppColors.statusWarning;
    }
  }

  Color _getPriceVerificationColor(String status) {
    switch (status) {
      case 'verified':
        return AppColors.statusSuccess;
      case 'unverified':
      case 'stale':
        return AppColors.statusWarning;
      case 'rejected':
      default:
        return AppColors.statusError;
    }
  }

  // ==========================================
  // Variant Dialogs
  // ==========================================

  void _showAddVariantDialog() {
    final nameController = TextEditingController();
    final attrKeyController = TextEditingController();
    final attrValueController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        String strings(String key) => AppStrings.get(key, context);
        return AlertDialog(
          title: Text(strings('add_variant')),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: '${strings('variant_name')} *',
                      border: const OutlineInputBorder(),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return strings('required_field');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: attrKeyController,
                          decoration: InputDecoration(
                            labelText: strings('attribute_key'),
                            hintText: 'e.g. size',
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: attrValueController,
                          decoration: InputDecoration(
                            labelText: strings('attribute_value'),
                            hintText: 'e.g. XL',
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(strings('cancel_action')),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                Navigator.of(ctx).pop();

                final attributes = <String, dynamic>{};
                if (attrKeyController.text.trim().isNotEmpty) {
                  attributes[attrKeyController.text.trim()] =
                      attrValueController.text.trim();
                }

                final created = await widget.catalogProvider.createVariant(
                  widget.businessId,
                  widget.itemId,
                  CreateVariantRequest(
                    name: nameController.text.trim(),
                    attributes: attributes,
                  ),
                );

                if (mounted) {
                  if (created != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(strings('variant_created_success')),
                        backgroundColor: AppColors.statusSuccess,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          widget.catalogProvider.actionError ??
                              strings('request_failed'),
                        ),
                        backgroundColor: AppColors.statusError,
                      ),
                    );
                  }
                }
              },
              child: Text(strings('add_variant')),
            ),
          ],
        );
      },
    );
  }

  void _showEditVariantDialog(Variant variant) {
    final nameController = TextEditingController(text: variant.name);
    String selectedStatus = variant.status;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        String strings(String key) => AppStrings.get(key, context);
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(strings('edit_variant')),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: '${strings('variant_name')} *',
                          border: const OutlineInputBorder(),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return strings('required_field');
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: selectedStatus,
                        decoration: InputDecoration(
                          labelText: strings('customer_status'),
                          border: const OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'active',
                            child: Text(strings('status_active')),
                          ),
                          DropdownMenuItem(
                            value: 'inactive',
                            child: Text(strings('status_inactive')),
                          ),
                          DropdownMenuItem(
                            value: 'archived',
                            child: Text(strings('status_archived')),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => selectedStatus = val);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(strings('cancel_action')),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    Navigator.of(ctx).pop();
                    final messenger = ScaffoldMessenger.of(context);

                    final updated = await widget.catalogProvider.updateVariant(
                      widget.businessId,
                      variant.id,
                      UpdateVariantRequest(
                        name: nameController.text.trim(),
                        status: selectedStatus,
                      ),
                      ifMatch: variant.resourceVersion,
                    );

                    if (!mounted) return;
                    if (updated != null) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(strings('variant_updated_success')),
                          backgroundColor: AppColors.statusSuccess,
                        ),
                      );
                    } else {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            widget.catalogProvider.actionError ??
                                strings('request_failed'),
                          ),
                          backgroundColor: AppColors.statusError,
                        ),
                      );
                    }
                  },
                  child: Text(strings('save_changes')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ==========================================
  // Offer Dialogs
  // ==========================================

  void _showAddOfferDialog() {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final currencyController = TextEditingController(text: 'SAR');
    final pricingUnitController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    String pricingMode =
        widget.catalogProvider.selectedItem?.pricingMode ?? 'fixed';
    String availabilityMode =
        widget.catalogProvider.selectedItem?.availabilityMode ?? 'stock';
    String availabilityStatus = 'available';
    String fulfillmentMode =
        widget.catalogProvider.selectedItem?.fulfillmentMode ?? 'delivery';
    String? selectedVariantId;

    showDialog(
      context: context,
      builder: (ctx) {
        String strings(String key) => AppStrings.get(key, context);
        final contract = widget.catalogProvider.entityContract;
        final variants = widget.catalogProvider.variants;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(strings('add_offer')),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: '${strings('offer_name')} *',
                          border: const OutlineInputBorder(),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return strings('required_field');
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: amountController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: InputDecoration(
                                labelText: strings('price_amount'),
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: currencyController,
                              decoration: InputDecoration(
                                labelText: strings('currency'),
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: pricingUnitController,
                        decoration: InputDecoration(
                          labelText: strings('pricing_unit'),
                          hintText: 'e.g. piece, hour',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (variants.isNotEmpty) ...[
                        DropdownButtonFormField<String>(
                          initialValue: selectedVariantId,
                          decoration: InputDecoration(
                            labelText: strings('linked_variant'),
                            border: const OutlineInputBorder(),
                          ),
                          isExpanded: true,
                          items: [
                            DropdownMenuItem<String>(
                              value: null,
                              child: Text(strings('all_transactions')),
                            ),
                            ...variants.map((v) {
                              return DropdownMenuItem<String>(
                                value: v.id,
                                child: Text(v.name),
                              );
                            }),
                          ],
                          onChanged: (val) {
                            setDialogState(() => selectedVariantId = val);
                          },
                        ),
                        const SizedBox(height: 12),
                      ],
                      DropdownButtonFormField<String>(
                        initialValue: availabilityStatus,
                        decoration: InputDecoration(
                          labelText: strings('availability_status'),
                          border: const OutlineInputBorder(),
                        ),
                        isExpanded: true,
                        items: contract.availabilityStatuses.entries.map((e) {
                          return DropdownMenuItem(
                            value: e.key,
                            child: Text('${e.key} - ${e.value}'),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => availabilityStatus = val);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(strings('cancel_action')),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    Navigator.of(ctx).pop();
                    final messenger = ScaffoldMessenger.of(context);

                    final amount = double.tryParse(
                      amountController.text.trim(),
                    );
                    final created = await widget.catalogProvider.createOffer(
                      widget.businessId,
                      widget.itemId,
                      CreateOfferRequest(
                        name: nameController.text.trim(),
                        pricingMode: pricingMode,
                        amount: amount,
                        currency: currencyController.text.trim().isNotEmpty
                            ? currencyController.text.trim()
                            : 'SAR',
                        pricingUnit:
                            pricingUnitController.text.trim().isNotEmpty
                            ? pricingUnitController.text.trim()
                            : null,
                        availabilityMode: availabilityMode,
                        availabilityStatus: availabilityStatus,
                        fulfillmentMode: fulfillmentMode,
                        variantId: selectedVariantId,
                        status: 'active',
                      ),
                    );

                    if (!mounted) return;
                    if (created != null) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(strings('offer_created_success')),
                          backgroundColor: AppColors.statusSuccess,
                        ),
                      );
                    } else {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            widget.catalogProvider.actionError ??
                                strings('request_failed'),
                          ),
                          backgroundColor: AppColors.statusError,
                        ),
                      );
                    }
                  },
                  child: Text(strings('add_offer')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditOfferDialog(Offer offer) {
    final nameController = TextEditingController(text: offer.name);
    final amountController = TextEditingController(
      text: offer.amount?.toString() ?? '',
    );
    String selectedAvailabilityStatus = offer.availabilityStatus;
    String selectedStatus = offer.status;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        String strings(String key) => AppStrings.get(key, context);
        final contract = widget.catalogProvider.entityContract;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(strings('edit_offer')),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: '${strings('offer_name')} *',
                          border: const OutlineInputBorder(),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return strings('required_field');
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: strings('price_amount'),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: selectedAvailabilityStatus,
                        decoration: InputDecoration(
                          labelText: strings('availability_status'),
                          border: const OutlineInputBorder(),
                        ),
                        isExpanded: true,
                        items: contract.availabilityStatuses.entries.map((e) {
                          return DropdownMenuItem(
                            value: e.key,
                            child: Text('${e.key} - ${e.value}'),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(
                              () => selectedAvailabilityStatus = val,
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: selectedStatus,
                        decoration: InputDecoration(
                          labelText: strings('customer_status'),
                          border: const OutlineInputBorder(),
                        ),
                        isExpanded: true,
                        items: contract.offerStatuses.entries.map((e) {
                          return DropdownMenuItem(
                            value: e.key,
                            child: Text('${e.key} - ${e.value}'),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => selectedStatus = val);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(strings('cancel_action')),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    Navigator.of(ctx).pop();
                    final messenger = ScaffoldMessenger.of(context);

                    final amount = double.tryParse(
                      amountController.text.trim(),
                    );
                    final updated = await widget.catalogProvider.updateOffer(
                      widget.businessId,
                      offer.id,
                      UpdateOfferRequest(
                        name: nameController.text.trim(),
                        amount: amount,
                        availabilityStatus: selectedAvailabilityStatus,
                        status: selectedStatus,
                      ),
                      ifMatch: offer.resourceVersion,
                    );

                    if (!mounted) return;
                    if (updated != null) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(strings('offer_updated_success')),
                          backgroundColor: AppColors.statusSuccess,
                        ),
                      );
                    } else {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            widget.catalogProvider.actionError ??
                                strings('request_failed'),
                          ),
                          backgroundColor: AppColors.statusError,
                        ),
                      );
                    }
                  },
                  child: Text(strings('save_changes')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String strings(String key) => AppStrings.get(key, context);
    final provider = widget.catalogProvider;

    return ListenableBuilder(
      listenable: provider,
      builder: (context, _) {
        final item = provider.selectedItem;
        final variants = provider.variants;
        final offers = provider.offers;
        final contract = provider.entityContract;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              item?.name ?? strings('catalog_items_title'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            actions: [
              if (item != null)
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: strings('edit_item'),
                  onPressed: () async {
                    final updated = await Navigator.of(context)
                        .push<CatalogItem>(
                          MaterialPageRoute(
                            builder: (_) => CatalogItemFormScreen(
                              catalogProvider: provider,
                              businessId: widget.businessId,
                              catalogId: widget.catalogId,
                              existingItem: item,
                            ),
                          ),
                        );
                    if (updated != null) {
                      _loadDetails();
                    }
                  },
                ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                tooltip: strings('refresh'),
                onPressed: provider.isLoadingItemDetail ? null : _loadDetails,
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: strings('overview_tab')),
                Tab(text: '${strings('variants_tab')} (${variants.length})'),
                Tab(text: '${strings('offers_tab')} (${offers.length})'),
              ],
            ),
          ),
          body: provider.isLoadingItemDetail && item == null
              ? const Center(child: CircularProgressIndicator())
              : provider.itemDetailError != null && item == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          size: 48,
                          color: AppColors.statusError,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          provider.itemDetailError!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadDetails,
                          child: Text(strings('retry')),
                        ),
                      ],
                    ),
                  ),
                )
              : item == null
              ? Center(child: Text(strings('no_items')))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(item, contract, strings),
                    _buildVariantsTab(variants, contract, strings),
                    _buildOffersTab(offers, contract, strings),
                  ],
                ),
        );
      },
    );
  }

  // ==========================================
  // Tab 1: Overview
  // ==========================================

  Widget _buildOverviewTab(
    CatalogItem item,
    CatalogEntityContract contract,
    String Function(String) strings,
  ) {
    final statusColor = _getStatusColor(item.status);
    final statusBg = _getStatusBgColor(item.status);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Main Info Card
        Card(
          elevation: 0,
          color: AppColors.surfaceCanvas,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.borderHairline),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        contract.labelItemStatus(item.status),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${strings('item_type')}: ${item.itemType}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                if (item.shortDescription != null &&
                    item.shortDescription!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    item.shortDescription!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
                if (item.longDescription != null &&
                    item.longDescription!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Text(
                    item.longDescription!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Modes Card
        Card(
          elevation: 0,
          color: AppColors.surfaceCanvas,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.borderHairline),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  strings('pricing_mode'),
                  contract.labelPricingMode(item.pricingMode),
                  Icons.price_change_rounded,
                ),
                const Divider(height: 16),
                _buildInfoRow(
                  strings('availability_mode'),
                  contract.labelAvailabilityMode(item.availabilityMode),
                  Icons.event_available_rounded,
                ),
                const Divider(height: 16),
                _buildInfoRow(
                  strings('fulfillment_mode'),
                  contract.labelFulfillmentMode(item.fulfillmentMode),
                  Icons.local_shipping_rounded,
                ),
                const Divider(height: 16),
                _buildInfoRow(
                  strings('requires_confirmation'),
                  item.requiresConfirmation
                      ? strings('status_pending')
                      : strings('status_approved'),
                  Icons.verified_user_rounded,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Custom Attributes Card
        Card(
          elevation: 0,
          color: AppColors.surfaceCanvas,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.borderHairline),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings('attributes'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                if (item.attributes.isEmpty)
                  Text(
                    strings('no_attributions'),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  )
                else
                  ...item.attributes.entries.map((e) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceSubtle,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              e.key,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              e.value?.toString() ?? '',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // Tab 2: Variants
  // ==========================================

  Widget _buildVariantsTab(
    List<Variant> variants,
    CatalogEntityContract contract,
    String Function(String) strings,
  ) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddVariantDialog,
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(strings('add_variant')),
      ),
      body: variants.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.style_outlined,
                    size: 48,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    strings('no_variants'),
                    style: const TextStyle(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _showAddVariantDialog,
                    icon: const Icon(Icons.add_rounded),
                    label: Text(strings('add_variant')),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
              itemCount: variants.length,
              separatorBuilder: (_, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final v = variants[index];
                final statusColor = _getStatusColor(v.status);
                final statusBg = _getStatusBgColor(v.status);
                final statusLabel = contract.labelVariantStatus(v.status);

                return Card(
                  elevation: 0,
                  color: AppColors.surfaceCanvas,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.borderHairline),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              v.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSurface,
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusBg,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    statusLabel,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: statusColor,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 18,
                                  ),
                                  tooltip: strings('edit_variant'),
                                  onPressed: () => _showEditVariantDialog(v),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (v.attributes.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: v.attributes.entries.map((attr) {
                              return Chip(
                                label: Text(
                                  '${attr.key}: ${attr.value}',
                                  style: const TextStyle(fontSize: 10),
                                ),
                                padding: EdgeInsets.zero,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  // ==========================================
  // Tab 3: Offers
  // ==========================================

  Widget _buildOffersTab(
    List<Offer> offers,
    CatalogEntityContract contract,
    String Function(String) strings,
  ) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddOfferDialog,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(strings('add_offer')),
      ),
      body: offers.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.local_offer_outlined,
                    size: 48,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    strings('no_offers'),
                    style: const TextStyle(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _showAddOfferDialog,
                    icon: const Icon(Icons.add_rounded),
                    label: Text(strings('add_offer')),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
              itemCount: offers.length,
              separatorBuilder: (_, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final offer = offers[index];
                final statusColor = _getStatusColor(offer.status);
                final statusBg = _getStatusBgColor(offer.status);
                final statusLabel = contract.labelOfferStatus(offer.status);

                final availColor = _getAvailabilityColor(
                  offer.availabilityStatus,
                );
                final availLabel = contract.labelAvailabilityStatus(
                  offer.availabilityStatus,
                );

                final priceVerifColor = _getPriceVerificationColor(
                  offer.priceVerificationStatus,
                );
                final priceVerifLabel = contract.labelPriceVerification(
                  offer.priceVerificationStatus,
                );

                return Card(
                  elevation: 0,
                  color: AppColors.surfaceCanvas,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.borderHairline),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                offer.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusBg,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    statusLabel,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: statusColor,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 18,
                                  ),
                                  tooltip: strings('edit_offer'),
                                  onPressed: () => _showEditOfferDialog(offer),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              offer.amount != null
                                  ? '${offer.amount!.toStringAsFixed(2)} ${offer.currency ?? 'SAR'}'
                                  : strings('pricing_mode'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            if (offer.pricingUnit != null &&
                                offer.pricingUnit!.isNotEmpty) ...[
                              Text(
                                ' / ${offer.pricingUnit!}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: availColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${strings('availability_status')}: $availLabel',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: availColor,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: priceVerifColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${strings('price_verification')}: $priceVerifLabel',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: priceVerifColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
