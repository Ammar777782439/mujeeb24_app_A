import 'package:flutter/material.dart';
import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/models/catalog_models.dart';
import '../providers/catalog_provider.dart';

/// Form screen for creating or editing a CatalogItem.
class CatalogItemFormScreen extends StatefulWidget {
  final CatalogProvider catalogProvider;
  final String businessId;
  final String catalogId;
  final CatalogItem? existingItem;

  const CatalogItemFormScreen({
    super.key,
    required this.catalogProvider,
    required this.businessId,
    required this.catalogId,
    this.existingItem,
  });

  @override
  State<CatalogItemFormScreen> createState() => _CatalogItemFormScreenState();
}

class _AttributeEntryController {
  final TextEditingController keyController;
  final TextEditingController valueController;

  _AttributeEntryController({String key = '', String value = ''})
      : keyController = TextEditingController(text: key),
        valueController = TextEditingController(text: value);

  void dispose() {
    keyController.dispose();
    valueController.dispose();
  }
}

class _CatalogItemFormScreenState extends State<CatalogItemFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _itemTypeController;
  late final TextEditingController _shortDescController;
  late final TextEditingController _longDescController;

  late String _selectedPricingMode;
  late String _selectedAvailabilityMode;
  late String _selectedFulfillmentMode;
  late String _selectedStatus;
  late bool _requiresConfirmation;
  String? _selectedAttributeSchemaId;

  final List<_AttributeEntryController> _attributeControllers = [];

  bool get _isEditing => widget.existingItem != null;

  @override
  void initState() {
    super.initState();
    final item = widget.existingItem;

    _nameController = TextEditingController(text: item?.name ?? '');
    _itemTypeController =
        TextEditingController(text: item?.itemType ?? '');
    _shortDescController =
        TextEditingController(text: item?.shortDescription ?? '');
    _longDescController =
        TextEditingController(text: item?.longDescription ?? '');

    _selectedPricingMode = item?.pricingMode ?? 'fixed';
    _selectedAvailabilityMode = item?.availabilityMode ?? 'stock';
    _selectedFulfillmentMode = item?.fulfillmentMode ?? 'delivery';
    _selectedStatus = item?.status ?? 'draft';
    _requiresConfirmation = item?.requiresConfirmation ?? false;
    _selectedAttributeSchemaId = item?.attributeSchemaId;

    if (item != null && item.attributes.isNotEmpty) {
      item.attributes.forEach((k, v) {
        _attributeControllers.add(
          _AttributeEntryController(key: k, value: v.toString()),
        );
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _itemTypeController.dispose();
    _shortDescController.dispose();
    _longDescController.dispose();
    for (final c in _attributeControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addAttribute() {
    setState(() {
      _attributeControllers.add(_AttributeEntryController());
    });
  }

  void _removeAttribute(int index) {
    setState(() {
      final removed = _attributeControllers.removeAt(index);
      removed.dispose();
    });
  }

  Map<String, dynamic> _collectAttributes() {
    final map = <String, dynamic>{};
    for (final c in _attributeControllers) {
      final key = c.keyController.text.trim();
      final val = c.valueController.text.trim();
      if (key.isNotEmpty) {
        map[key] = val;
      }
    }
    return map;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    String strings(String key) => AppStrings.get(key, context);
    final attributes = _collectAttributes();

    CatalogItem? result;
    if (_isEditing) {
      final updateReq = UpdateCatalogItemRequest(
        name: _nameController.text.trim(),
        itemType: _itemTypeController.text.trim(),
        pricingMode: _selectedPricingMode,
        availabilityMode: _selectedAvailabilityMode,
        fulfillmentMode: _selectedFulfillmentMode,
        status: _selectedStatus,
        requiresConfirmation: _requiresConfirmation,
        shortDescription: _shortDescController.text.trim().isNotEmpty
            ? _shortDescController.text.trim()
            : null,
        longDescription: _longDescController.text.trim().isNotEmpty
            ? _longDescController.text.trim()
            : null,
        attributes: attributes,
      );

      result = await widget.catalogProvider.updateCatalogItem(
        widget.businessId,
        widget.catalogId,
        widget.existingItem!.id,
        updateReq,
        ifMatch: widget.existingItem!.resourceVersion,
      );
    } else {
      final createReq = CreateCatalogItemRequest(
        name: _nameController.text.trim(),
        itemType: _itemTypeController.text.trim(),
        pricingMode: _selectedPricingMode,
        availabilityMode: _selectedAvailabilityMode,
        fulfillmentMode: _selectedFulfillmentMode,
        requiresConfirmation: _requiresConfirmation,
        shortDescription: _shortDescController.text.trim().isNotEmpty
            ? _shortDescController.text.trim()
            : null,
        longDescription: _longDescController.text.trim().isNotEmpty
            ? _longDescController.text.trim()
            : null,
        attributeSchemaId: _selectedAttributeSchemaId,
        attributes: attributes,
      );

      result = await widget.catalogProvider.createCatalogItem(
        widget.businessId,
        widget.catalogId,
        createReq,
      );
    }

    if (mounted) {
      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? strings('item_updated_success')
                  : strings('item_created_success'),
            ),
            backgroundColor: AppColors.statusSuccess,
          ),
        );
        Navigator.of(context).pop(result);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.catalogProvider.actionError ?? strings('request_failed'),
            ),
            backgroundColor: AppColors.statusError,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String strings(String key) => AppStrings.get(key, context);
    final contract = widget.catalogProvider.entityContract;
    final isBusy = widget.catalogProvider.isPerformingAction;
    final schemas = widget.catalogProvider.attributeSchemas;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? strings('edit_item') : strings('create_item'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_isEditing) ...[
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderHairline),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'ID: ${widget.existingItem!.id}\nVersion: ${widget.existingItem!.resourceVersion}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Item Name
            TextFormField(
              controller: _nameController,
              enabled: !isBusy,
              decoration: InputDecoration(
                labelText: '${strings('item_name')} *',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.label_rounded),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return strings('required_field');
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Item Type
            TextFormField(
              controller: _itemTypeController,
              enabled: !isBusy,
              decoration: InputDecoration(
                labelText: '${strings('item_type')} *',
                hintText: strings('item_type_hint'),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.category_rounded),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return strings('required_field');
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Pricing Mode Dropdown
            DropdownButtonFormField<String>(
              initialValue: _selectedPricingMode,
              decoration: InputDecoration(
                labelText: strings('pricing_mode'),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.price_change_rounded),
              ),
              isExpanded: true,
              items: contract.pricingModes.entries.map((e) {
                return DropdownMenuItem(
                  value: e.key,
                  child: Text(
                    '${e.key} - ${e.value}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                );
              }).toList(),
              onChanged: isBusy ? null : (val) {
                if (val != null) setState(() => _selectedPricingMode = val);
              },
            ),
            const SizedBox(height: 16),

            // Availability Mode Dropdown
            DropdownButtonFormField<String>(
              initialValue: _selectedAvailabilityMode,
              decoration: InputDecoration(
                labelText: strings('availability_mode'),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.event_available_rounded),
              ),
              isExpanded: true,
              items: contract.availabilityModes.entries.map((e) {
                return DropdownMenuItem(
                  value: e.key,
                  child: Text(
                    '${e.key} - ${e.value}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                );
              }).toList(),
              onChanged: isBusy ? null : (val) {
                if (val != null) setState(() => _selectedAvailabilityMode = val);
              },
            ),
            const SizedBox(height: 16),

            // Fulfillment Mode Dropdown
            DropdownButtonFormField<String>(
              initialValue: _selectedFulfillmentMode,
              decoration: InputDecoration(
                labelText: strings('fulfillment_mode'),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.local_shipping_rounded),
              ),
              isExpanded: true,
              items: contract.fulfillmentModes.entries.map((e) {
                return DropdownMenuItem(
                  value: e.key,
                  child: Text(
                    '${e.key} - ${e.value}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                );
              }).toList(),
              onChanged: isBusy ? null : (val) {
                if (val != null) setState(() => _selectedFulfillmentMode = val);
              },
            ),
            const SizedBox(height: 16),

            // Status Dropdown (when editing)
            if (_isEditing) ...[
              DropdownButtonFormField<String>(
                initialValue: _selectedStatus,
                decoration: InputDecoration(
                  labelText: strings('customer_status'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.shield_outlined),
                ),
                isExpanded: true,
                items: contract.itemStatuses.entries.map((e) {
                  return DropdownMenuItem(
                    value: e.key,
                    child: Text('${e.key} - ${e.value}'),
                  );
                }).toList(),
                onChanged: isBusy ? null : (val) {
                  if (val != null) setState(() => _selectedStatus = val);
                },
              ),
              const SizedBox(height: 16),
            ],

            // Requires Confirmation Switch
            SwitchListTile.adaptive(
              value: _requiresConfirmation,
              contentPadding: EdgeInsets.zero,
              title: Text(
                strings('requires_confirmation'),
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              subtitle: Text(
                strings('requires_confirmation_subtitle'),
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              onChanged: isBusy ? null : (val) {
                setState(() => _requiresConfirmation = val);
              },
            ),
            const SizedBox(height: 12),

            // Short Description
            TextFormField(
              controller: _shortDescController,
              enabled: !isBusy,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: strings('short_description'),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Long Description
            TextFormField(
              controller: _longDescController,
              enabled: !isBusy,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: strings('long_description'),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Optional Attribute Schema Selector (only on create)
            if (!_isEditing && schemas.isNotEmpty) ...[
              DropdownButtonFormField<String>(
                initialValue: _selectedAttributeSchemaId,
                decoration: InputDecoration(
                  labelText: strings('attribute_schema'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.schema_rounded),
                ),
                isExpanded: true,
                items: [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text(strings('select_attribute_schema')),
                  ),
                  ...schemas.map((s) {
                    return DropdownMenuItem<String>(
                      value: s.id,
                      child: Text('${s.name} (v${s.version})'),
                    );
                  }),
                ],
                onChanged: isBusy ? null : (val) {
                  setState(() => _selectedAttributeSchemaId = val);
                },
              ),
              const SizedBox(height: 16),
            ],

            // Custom Attributes Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  strings('attributes'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                TextButton.icon(
                  onPressed: isBusy ? null : _addAttribute,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text(strings('add_attribute')),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (_attributeControllers.isEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    strings('no_scores'),
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ),
              )
            else
              ...List.generate(_attributeControllers.length, (index) {
                final ctrl = _attributeControllers[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: ctrl.keyController,
                          enabled: !isBusy,
                          decoration: InputDecoration(
                            labelText: strings('attribute_key'),
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: ctrl.valueController,
                          enabled: !isBusy,
                          decoration: InputDecoration(
                            labelText: strings('attribute_value'),
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded,
                            color: AppColors.statusError),
                        onPressed: isBusy ? null : () => _removeAttribute(index),
                      ),
                    ],
                  ),
                );
              }),

            const SizedBox(height: 24),

            // Submit Button
            ElevatedButton(
              onPressed: isBusy ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isBusy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _isEditing
                          ? strings('save_changes')
                          : strings('create_item'),
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
