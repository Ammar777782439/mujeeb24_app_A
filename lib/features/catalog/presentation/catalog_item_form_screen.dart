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
  final String? businessCurrency;
  final CatalogItem? existingItem;

  const CatalogItemFormScreen({
    super.key,
    required this.catalogProvider,
    required this.businessId,
    required this.catalogId,
    this.businessCurrency,
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
  late final TextEditingController _amountController;
  late final TextEditingController _currencyController;
  late final TextEditingController _unitController;
  String? _availabilityStatus;
  bool _saveInitialOffer = true;
  int _step = 0;
  bool _customItemType = false;

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
        TextEditingController(text: item?.itemType ?? 'product');
    _shortDescController =
        TextEditingController(text: item?.shortDescription ?? '');
    _longDescController =
        TextEditingController(text: item?.longDescription ?? '');

    _selectedPricingMode = item?.pricingMode ?? 'fixed';
    _selectedAvailabilityMode = item?.availabilityMode ?? 'unknown';
    _selectedFulfillmentMode = item?.fulfillmentMode ?? 'manual';
    _selectedStatus = item?.status ?? 'draft';
    _requiresConfirmation = item?.requiresConfirmation ?? false;
    _selectedAttributeSchemaId = item?.attributeSchemaId;
    _amountController = TextEditingController();
    _currencyController = TextEditingController(text: widget.businessCurrency ?? '');
    _unitController = TextEditingController();

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
    _amountController.dispose();
    _currencyController.dispose();
    _unitController.dispose();
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

  void _nextStep() {
    if (_step == 0 && !_formKey.currentState!.validate()) return;
    if (_step == 0 && _itemTypeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختر نوع المنتج أو الخدمة')));
      return;
    }
    if (_step == 1 && _saveInitialOffer) {
      final amount = double.tryParse(_amountController.text.trim());
      final needsAmount = _selectedPricingMode != 'quote_required' &&
          _selectedPricingMode != 'dynamic';
      final needsUnit = ['per_unit', 'per_person', 'per_day']
          .contains(_selectedPricingMode);
      if (_availabilityStatus == null ||
          (needsAmount && (amount == null || amount <= 0)) ||
          (_amountController.text.trim().isNotEmpty && amount == null) ||
          (needsUnit && _unitController.text.trim().isEmpty) ||
          !RegExp(r'^[A-Za-z]{3}$').hasMatch(_currencyController.text.trim())) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('راجع السعر والعملة وحدد حالة التوفر قبل المتابعة')),
        );
        return;
      }
    }
    setState(() => _step++);
  }

  Future<void> _submit() async {
    if (!_isEditing && _step != 2) return;
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
        initialOffer: _saveInitialOffer ? CreateOfferRequest(
          name: 'السعر الأساسي',
          pricingMode: _selectedPricingMode,
          amount: double.tryParse(_amountController.text.trim()),
          currency: _currencyController.text.trim().toUpperCase(),
          pricingUnit: _unitController.text.trim().isEmpty
              ? null : _unitController.text.trim(),
          availabilityMode: _selectedAvailabilityMode,
          availabilityStatus: _availabilityStatus!,
          fulfillmentMode: _selectedFulfillmentMode,
          status: 'active',
        ) : null,
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

            if (!_isEditing) ...[
              Text('الخطوة ' + (_step + 1).toString() + ' من 3',
                style: const TextStyle(color: AppColors.primary,
                  fontWeight: FontWeight.bold)),
              Text(const [
                'ما الذي تقدمه؟', 'السعر والتوفر', 'راجع واحفظ',
              ][_step], style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 18),
            ],
            if (_isEditing || _step == 0) ...[
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

            // Show a human-friendly item type, while preserving its API value.
            if (_isEditing) ...[
              TextFormField(
                controller: _itemTypeController,
                enabled: !isBusy,
                decoration: const InputDecoration(
                  labelText: 'نوع المنتج أو الخدمة',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? strings('required_field') : null,
              ),
            ] else ...[
              DropdownButtonFormField<String>(
                initialValue: 'product',
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'ما الذي تقدمه؟',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'product', child: Text('منتج')),
                  DropdownMenuItem(value: 'service', child: Text('خدمة')),
                  DropdownMenuItem(value: 'consultation', child: Text('استشارة')),
                  DropdownMenuItem(value: 'booking', child: Text('حجز')),
                  DropdownMenuItem(value: 'real_estate', child: Text('عقار')),
                  DropdownMenuItem(value: 'course', child: Text('دورة')),
                  DropdownMenuItem(value: 'subscription', child: Text('اشتراك')),
                  DropdownMenuItem(value: 'custom', child: Text('نوع آخر')),
                ],
                onChanged: isBusy ? null : (value) {
                  if (value == null) return;
                  setState(() {
                    _customItemType = value == 'custom';
                    _itemTypeController.text = _customItemType ? '' : value;
                  });
                },
              ),
              if (_customItemType) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _itemTypeController,
                  decoration: const InputDecoration(
                    labelText: 'اسم النوع', hintText: 'اكتب النوع الذي يناسب نشاطك',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? strings('required_field') : null,
                ),
              ],
            ],
            const SizedBox(height: 16),

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

            ],
            if (_isEditing || _step == 1) ...[
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

            ],
            if (!_isEditing && _step == 1) ...[
              SwitchListTile.adaptive(
                title: const Text('حفظ السعر والتوفر الآن'),
                subtitle: const Text('يمكن تأجيل السعر وسيظل المنتج مسودة'),
                value: _saveInitialOffer,
                onChanged: isBusy ? null : (value) =>
                    setState(() => _saveInitialOffer = value),
              ),
              if (_saveInitialOffer) ...[
                if (_selectedPricingMode != 'quote_required') ...[
                  TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: _selectedPricingMode == 'dynamic'
                          ? 'مبلغ استرشادي (اختياري)' : 'المبلغ *',
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                TextField(
                  controller: _currencyController,
                  maxLength: 3,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'عملة النشاط *', hintText: 'YER أو SAR',
                  ),
                ),
                if (['per_unit', 'per_person', 'per_day'].contains(_selectedPricingMode))
                  TextField(
                    controller: _unitController,
                    decoration: const InputDecoration(
                      labelText: 'السعر لكل ماذا؟ *', hintText: 'قطعة أو ساعة',
                    ),
                  ),
                DropdownButtonFormField<String>(
                  initialValue: _availabilityStatus,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'هل هو متوفر؟ اختر حالته *',
                    border: OutlineInputBorder(),
                  ),
                  items: contract.availabilityStatuses.entries.map((e) =>
                    DropdownMenuItem(
                      value: e.key,
                      child: Text(e.value, overflow: TextOverflow.ellipsis),
                    ),
                  ).toList(),
                  onChanged: isBusy ? null : (value) =>
                      setState(() => _availabilityStatus = value),
                ),
                const SizedBox(height: 16),
              ],
            ],
            if (!_isEditing && _step == 2) ...[
              Text('راجع المعلومات قبل الحفظ',
                style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Card(child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_nameController.text.trim(),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(_itemTypeController.text.trim()),
                    const Divider(),
                    if (_saveInitialOffer) ...[
                      Text('السعر: ' +
                        (_amountController.text.trim().isEmpty
                          ? 'حسب الطلب' : _amountController.text.trim()) +
                        ' ' + _currencyController.text.trim().toUpperCase()),
                      Text('التوفر: ' + contract.labelAvailabilityStatus(
                        _availabilityStatus ?? 'unknown')),
                    ] else
                      const Text('لم يضف السعر الآن'),
                    const Text('يحفظ المنتج مسودة. التنشيط إجراء منفصل.',
                      style: TextStyle(color: AppColors.textMuted)),
                  ],
                ),
              )),
              const SizedBox(height: 20),
            ],
            // Submit Button
            if (!_isEditing && _step > 0)
              OutlinedButton(onPressed: isBusy ? null : () => setState(() => _step--),
                child: const Text('السابق')),
            ElevatedButton(
              onPressed: isBusy ? null : (_isEditing || _step == 2 ? _submit : _nextStep),
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
                          : (_step == 2 ? 'احفظ المنتج' : 'التالي'),
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
