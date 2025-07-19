// lib/hive/type_ids.dart

/**
 * HIVE TYPEID REGISTRY
 * 
 * RULES:
 * - Never reuse a typeId once it's been used in production
 * - Use logical groupings with gaps for future expansion
 * - Update this documentation when adding new types
 * 
 * CURRENT ASSIGNMENTS:
 * 0-9:   User & Auth models
 * 10-19: Property & Tenant models  
 * 20-29: Payment models
 * 30-39: Dashboard & Analytics models (future)
 * 40-49: Settings & Configuration models (future)
 * 50+:   Reserved for future expansion
 */

class HiveTypeIds {
  // User models (0-9)
  static const int user = 0;
  
  // Property & Tenant models (10-19) 
  static const int property = 10;
  static const int emergencyContact = 11;
  static const int tenant = 12;
  // 13-19 reserved for future property/tenant related models
  
  // Payment models (20-29)
  static const int payment = 20;
  static const int paymentTenant = 21;
  static const int paymentProperty = 22;
  static const int paymentProcessor = 23;
  // 24-29 reserved for future payment related models
  
  // Future model groups (30+)
  // Dashboard models: 30-39
  // Settings models: 40-49
  // Add new groups with clear ranges...
  
  // Registry for documentation and validation
  static const Map<int, String> _registry = {
    0: 'User',
    10: 'Property', 
    11: 'EmergencyContact',
    12: 'Tenant',
    20: 'Payment',
    21: 'PaymentTenant',
    22: 'PaymentProperty', 
    23: 'PaymentProcessor',
  };
  
  // Add this public getter
  static Map<int, String> get registry => _registry;
  
  // Helper methods
  static void validateRegistry() {
    final ids = _registry.keys.toList();
    final uniqueIds = ids.toSet();
    
    if (ids.length != uniqueIds.length) {
      throw Exception('Duplicate typeIds detected in registry: ${_registry}');
    }
  }
  
  static void printRegistry() {
    print('=== HIVE TYPEID REGISTRY ===');
    final sortedEntries = _registry.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    
    for (final entry in sortedEntries) {
      print('${entry.key.toString().padLeft(2, '0')}: ${entry.value}');
    }
    print('===========================');
  }
  
  static List<int> get usedIds => _registry.keys.toList()..sort();
  static List<int> get availableIds {
    const maxId = 50; // Reasonable limit for now
    final used = usedIds.toSet();
    return List.generate(maxId, (i) => i).where((id) => !used.contains(id)).toList();
  }
}