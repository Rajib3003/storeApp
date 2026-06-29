class TableConfig {
  static const Map<String, List<String>> editableFields = {
    "categories": [
      "category_name",
    ],

    "brands": [
      "brand_name",
    ],

    "colors": [
      "color_name",
    ],

    "sizes": [
      "size_name",
    ],

    "roles": [
      "role_name",
      "permissions",
    ],

    "expense_categories": [
      "name",
    ],
    'suppliers': [
      'supplier_name',
      'phone',
      'address',
      'total_due',
    ],
    'customers': [
      'customer_name',
      'phone',
      'address',
      'total_due',
    ],
    'products': [
      'photo',
      'name',
      'category_id',
      'brand_id',
      'size_id',
      'color_id',
      'purchase_price',
      'selling_price',
      'stock',
      'low_stock_alert',
    ],
  };
}