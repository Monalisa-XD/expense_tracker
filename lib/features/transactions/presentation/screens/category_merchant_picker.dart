import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/entities.dart';
import '../../../../core/theme/brand_registry.dart';
import '../../../../core/utils/app_icon_resolver.dart';

class CategoryMerchantPicker extends ConsumerStatefulWidget {
  final ValueChanged<Map<String, dynamic>> onPicked;

  const CategoryMerchantPicker({super.key, required this.onPicked});

  @override
  ConsumerState<CategoryMerchantPicker> createState() => _CategoryMerchantPickerState();
}

class _CategoryMerchantPickerState extends ConsumerState<CategoryMerchantPicker> {
  CategoryEntity? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _customMerchantController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    _customMerchantController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedCategory == null) {
      return _buildCategoryGrid();
    } else {
      return _buildMerchantSelector();
    }
  }

  Widget _buildCategoryGrid() {
    // Filter categories to only expense type
    final expenseCats = BrandRegistry.categories.where((c) => c.type == TransactionType.expense).toList();

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Select Category',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 380,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemCount: expenseCats.length,
              itemBuilder: (context, index) {
                final cat = expenseCats[index];
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedCategory = cat;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(cat.colorValue).withOpacity(0.08),
                      border: Border.all(color: Color(cat.colorValue).withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Color(cat.colorValue).withOpacity(0.15),
                          child: Icon(
                            AppIconResolver.resolveCategoryIcon(cat.id),
                            color: Color(cat.colorValue),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            cat.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMerchantSelector() {
    final cat = _selectedCategory!;
    // Filter merchants for the selected category
    final list = BrandRegistry.merchants
        .where((m) => m.categoryId == cat.id)
        .where((m) => m.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _selectedCategory = null;
                    _searchQuery = '';
                    _searchController.clear();
                  });
                },
              ),
              Expanded(
                child: Text(
                  '${cat.name} Merchants',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48), // Spacer to balance back button
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search merchant...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (val) {
              setState(() {
                _searchQuery = val;
              });
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 250,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemCount: list.length + 1, // +1 for Custom Merchant option
              itemBuilder: (context, index) {
                if (index == list.length) {
                  return InkWell(
                    onTap: _showCustomMerchantDialog,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey.withOpacity(0.12),
                            child: const Icon(Icons.add, color: Colors.grey),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Custom Merchant',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final m = list[index];
                return InkWell(
                  onTap: () {
                    widget.onPicked({
                      'category': cat,
                      'merchantId': m.id,
                      'brandKey': m.brandKey,
                      'merchantName': m.name,
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(cat.colorValue).withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        AppIconResolver.resolveTransactionIcon(
                          categoryId: cat.id,
                          brandKey: m.brandKey,
                          merchantName: m.name,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            m.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showCustomMerchantDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Custom Merchant'),
        content: TextField(
          controller: _customMerchantController,
          decoration: const InputDecoration(
            labelText: 'Merchant Name',
            hintText: 'Enter shop name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = _customMerchantController.text.trim();
              if (name.isNotEmpty) {
                Navigator.pop(context); // Close dialog
                widget.onPicked({
                  'category': _selectedCategory!,
                  'merchantId': 'custom',
                  'brandKey': null,
                  'merchantName': name,
                });
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
