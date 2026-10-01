import 'dart:math';
import '../models/db_models.dart';

class MockDbService {
  static final List<DbConnection> defaultConnections = [
    const DbConnection(
      id: 'conn-prod-pg',
      name: 'E-Commerce Prod',
      dialect: DbDialect.postgresql,
      host: 'aws-us-east-1.rds.amazonaws.com',
      port: '5432',
      databaseName: 'ecommerce_production',
      username: 'db_admin',
      isConnected: true,
    ),
    const DbConnection(
      id: 'conn-analytics-mysql',
      name: 'Analytics Warehouse',
      dialect: DbDialect.mysql,
      host: 'analytics-cluster.internal',
      port: '3306',
      databaseName: 'bi_metrics',
      username: 'bi_reader',
      isConnected: false,
    ),
    const DbConnection(
      id: 'conn-local-sqlite',
      name: 'Local App Cache',
      dialect: DbDialect.sqlite,
      host: 'localhost',
      port: '',
      databaseName: 'local_dbspeak.db',
      username: 'app_user',
      isConnected: false,
    ),
  ];

  static List<TableSchema> getSchemasForConnection(DbConnection connection) {
    return [
      const TableSchema(
        name: 'customers',
        rowCount: 14250,
        columns: [
          ColumnInfo(name: 'id', type: 'BIGSERIAL', isPrimaryKey: true, isNullable: false),
          ColumnInfo(name: 'full_name', type: 'VARCHAR(120)', isNullable: false),
          ColumnInfo(name: 'email', type: 'VARCHAR(255)', isNullable: false),
          ColumnInfo(name: 'tier', type: 'VARCHAR(30)', isNullable: false),
          ColumnInfo(name: 'lifetime_spend', type: 'NUMERIC(10,2)', isNullable: false),
          ColumnInfo(name: 'created_at', type: 'TIMESTAMP', isNullable: false),
        ],
      ),
      const TableSchema(
        name: 'orders',
        rowCount: 48920,
        columns: [
          ColumnInfo(name: 'id', type: 'BIGSERIAL', isPrimaryKey: true, isNullable: false),
          ColumnInfo(name: 'customer_id', type: 'BIGINT', isNullable: false),
          ColumnInfo(name: 'status', type: 'VARCHAR(50)', isNullable: false),
          ColumnInfo(name: 'total_amount', type: 'NUMERIC(10,2)', isNullable: false),
          ColumnInfo(name: 'currency', type: 'VARCHAR(3)', isNullable: false),
          ColumnInfo(name: 'ordered_at', type: 'TIMESTAMP', isNullable: false),
        ],
      ),
      const TableSchema(
        name: 'products',
        rowCount: 850,
        columns: [
          ColumnInfo(name: 'id', type: 'BIGSERIAL', isPrimaryKey: true, isNullable: false),
          ColumnInfo(name: 'name', type: 'VARCHAR(200)', isNullable: false),
          ColumnInfo(name: 'category', type: 'VARCHAR(80)', isNullable: false),
          ColumnInfo(name: 'price', type: 'NUMERIC(8,2)', isNullable: false),
          ColumnInfo(name: 'stock_quantity', type: 'INTEGER', isNullable: false),
          ColumnInfo(name: 'is_active', type: 'BOOLEAN', isNullable: false),
        ],
      ),
      const TableSchema(
        name: 'reviews',
        rowCount: 18400,
        columns: [
          ColumnInfo(name: 'id', type: 'BIGSERIAL', isPrimaryKey: true, isNullable: false),
          ColumnInfo(name: 'product_id', type: 'BIGINT', isNullable: false),
          ColumnInfo(name: 'rating', type: 'SMALLINT', isNullable: false),
          ColumnInfo(name: 'comment', type: 'TEXT', isNullable: true),
          ColumnInfo(name: 'created_at', type: 'TIMESTAMP', isNullable: false),
        ],
      ),
    ];
  }

  static const List<String> samplePrompts = [
    'Top 5 customers by lifetime spend',
    'Show products with low stock (less than 20 units)',
    'Count total orders by status',
    'Find orders over \$500 placed this month',
    'Show average product rating grouped by category',
    'List customers who joined in the last 30 days',
  ];

  static Future<QueryRecord> processNaturalLanguageQuery({
    required String prompt,
    required DbConnection connection,
  }) async {
    // Simulate network + AI processing latency
    await Future.delayed(const Duration(milliseconds: 350));

    final normalized = prompt.trim().toLowerCase();
    String sql;
    String explanation;
    List<String> columns;
    List<Map<String, dynamic>> rows;

    if (normalized.contains('top') || normalized.contains('lifetime') || normalized.contains('customer')) {
      sql = '''
SELECT 
    id, 
    full_name, 
    email, 
    tier, 
    lifetime_spend
FROM customers
ORDER BY lifetime_spend DESC
LIMIT 5;''';
      explanation = 'Aggregates top spenders by sorting `lifetime_spend` descending and filtering to the top 5 records.';
      columns = ['id', 'full_name', 'email', 'tier', 'lifetime_spend'];
      rows = [
        {'id': 1042, 'full_name': 'Sarah Jenkins', 'email': 'sarah.j@enterprise.com', 'tier': 'Platinum', 'lifetime_spend': '\$14,820.50'},
        {'id': 2088, 'full_name': 'Marcus Vance', 'email': 'm.vance@techcorp.io', 'tier': 'Platinum', 'lifetime_spend': '\$11,490.00'},
        {'id': 3401, 'full_name': 'Aaliyah Patel', 'email': 'aaliyah@designhub.co', 'tier': 'Gold', 'lifetime_spend': '\$9,750.25'},
        {'id': 4190, 'full_name': 'David O\'Connor', 'email': 'doconnor@cloudsys.net', 'tier': 'Gold', 'lifetime_spend': '\$8,320.00'},
        {'id': 5021, 'full_name': 'Elena Rostova', 'email': 'elena.r@quantum.ai', 'tier': 'Gold', 'lifetime_spend': '\$7,890.80'},
      ];
    } else if (normalized.contains('stock') || normalized.contains('product') || normalized.contains('low')) {
      sql = '''
SELECT 
    id, 
    name, 
    category, 
    price, 
    stock_quantity
FROM products
WHERE stock_quantity < 20 AND is_active = true
ORDER BY stock_quantity ASC;''';
      explanation = 'Filters active products where `stock_quantity` is below threshold (20 units), ordered by lowest remaining inventory.';
      columns = ['id', 'name', 'category', 'price', 'stock_quantity'];
      rows = [
        {'id': 402, 'name': 'UltraWide 38" Curved Monitor', 'category': 'Electronics', 'price': '\$899.99', 'stock_quantity': 2},
        {'id': 189, 'name': 'Wireless Ergonomic Keyboard', 'category': 'Peripherals', 'price': '\$129.50', 'stock_quantity': 5},
        {'id': 751, 'name': 'Noise-Cancelling Studio Headset', 'category': 'Audio', 'price': '\$249.00', 'stock_quantity': 8},
        {'id': 331, 'name': 'USB-C Dual 4K Display Dock', 'category': 'Accessories', 'price': '\$179.99', 'stock_quantity': 12},
        {'id': 620, 'name': 'Mechanical Numpad RGB', 'category': 'Peripherals', 'price': '\$59.00', 'stock_quantity': 14},
      ];
    } else if (normalized.contains('order') && (normalized.contains('status') || normalized.contains('count'))) {
      sql = '''
SELECT 
    status, 
    COUNT(*) AS total_count, 
    ROUND(SUM(total_amount), 2) AS total_revenue
FROM orders
GROUP BY status
ORDER BY total_count DESC;''';
      explanation = 'Groups all orders by their current fulfillment `status`, returning order volume and total revenue.';
      columns = ['status', 'total_count', 'total_revenue'];
      rows = [
        {'status': 'COMPLETED', 'total_count': 38410, 'total_revenue': '\$4,892,150.00'},
        {'status': 'PROCESSING', 'total_count': 4210, 'total_revenue': '\$512,300.75'},
        {'status': 'SHIPPED', 'total_count': 3890, 'total_revenue': '\$429,180.20'},
        {'status': 'PENDING_PAYMENT', 'total_count': 1420, 'total_revenue': '\$160,820.00'},
        {'status': 'REFUNDED', 'total_count': 990, 'total_revenue': '\$118,450.10'},
      ];
    } else if (normalized.contains('500') || normalized.contains('month') || normalized.contains('over')) {
      sql = '''
SELECT 
    id, 
    customer_id, 
    status, 
    total_amount, 
    ordered_at
FROM orders
WHERE total_amount >= 500.00 
  AND ordered_at >= CURRENT_DATE - INTERVAL '30 days'
ORDER BY total_amount DESC;''';
      explanation = 'Retrieves high-value transactions with total exceeding \$500 processed in the rolling 30-day window.';
      columns = ['id', 'customer_id', 'status', 'total_amount', 'ordered_at'];
      rows = [
        {'id': 98214, 'customer_id': 1042, 'status': 'COMPLETED', 'total_amount': '\$3,250.00', 'ordered_at': '2026-09-28 14:22:10'},
        {'id': 98110, 'customer_id': 3401, 'status': 'COMPLETED', 'total_amount': '\$1,899.99', 'ordered_at': '2026-09-25 09:15:33'},
        {'id': 97892, 'customer_id': 2088, 'status': 'PROCESSING', 'total_amount': '\$1,240.00', 'ordered_at': '2026-09-21 16:40:02'},
        {'id': 97650, 'customer_id': 5021, 'status': 'COMPLETED', 'total_amount': '\$780.50', 'ordered_at': '2026-09-18 11:05:49'},
        {'id': 97412, 'customer_id': 4190, 'status': 'SHIPPED', 'total_amount': '\$645.00', 'ordered_at': '2026-09-15 13:30:17'},
      ];
    } else if (normalized.contains('rating') || normalized.contains('category')) {
      sql = '''
SELECT 
    p.category, 
    ROUND(AVG(r.rating), 2) AS avg_rating, 
    COUNT(r.id) AS total_reviews
FROM products p
JOIN reviews r ON r.product_id = p.id
GROUP BY p.category
ORDER BY avg_rating DESC;''';
      explanation = 'Joins `products` and `reviews` tables to compute average star rating and review count by product category.';
      columns = ['category', 'avg_rating', 'total_reviews'];
      rows = [
        {'category': 'Audio', 'avg_rating': 4.82, 'total_reviews': 3840},
        {'category': 'Electronics', 'avg_rating': 4.67, 'total_reviews': 7920},
        {'category': 'Peripherals', 'avg_rating': 4.54, 'total_reviews': 4510},
        {'category': 'Accessories', 'avg_rating': 4.31, 'total_reviews': 2130},
      ];
    } else {
      // Dynamic fallback query based on user's custom prompt
      sql = '''
SELECT 
    id, 
    full_name, 
    email, 
    tier, 
    created_at
FROM customers
WHERE created_at >= CURRENT_DATE - INTERVAL '30 days'
ORDER BY created_at DESC
LIMIT 10;''';
      explanation = 'Parsed query intent for "$prompt". Generated query against `customers` table with time range filter.';
      columns = ['id', 'full_name', 'email', 'tier', 'created_at'];
      rows = [
        {'id': 7812, 'full_name': 'Jonathan Swift', 'email': 'j.swift@example.com', 'tier': 'Standard', 'created_at': '2026-09-29 18:12:00'},
        {'id': 7811, 'full_name': 'Clara Oswald', 'email': 'clara.o@tardis.org', 'tier': 'Gold', 'created_at': '2026-09-27 12:45:19'},
        {'id': 7810, 'full_name': 'Liam Hemsworth', 'email': 'liam.h@hollywood.com', 'tier': 'Standard', 'created_at': '2026-09-24 08:33:55'},
        {'id': 7809, 'full_name': 'Devon Zhao', 'email': 'dzhao@fintech.co', 'tier': 'Platinum', 'created_at': '2026-09-22 15:20:41'},
      ];
    }

    final executionTime = 25 + Random().nextInt(45);
    final result = QueryResult(
      columns: columns,
      rows: rows,
      executionTimeMs: executionTime,
    );

    return QueryRecord(
      id: 'query-${DateTime.now().millisecondsSinceEpoch}',
      prompt: prompt,
      sql: sql,
      explanation: explanation,
      result: result,
      timestamp: DateTime.now(),
    );
  }
}
