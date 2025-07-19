// lib/hive/hive_registry.dart

import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';
import '../models/tenant.dart';  
import '../models/payment_model.dart';
import 'type_ids.dart';

class HiveRegistry {
  static bool _isInitialized = false;
  
  static void registerAllAdapters() {
    // Prevent duplicate registration
    if (_isInitialized) {
      print('HiveRegistry: Already initialized, skipping registration');
      return;
    }
    
    try {
      // Validate our registry first
      HiveTypeIds.validateRegistry();
      
      print('HiveRegistry: Registering adapters...');
      
      // Register User models (0-9)
      _registerAdapter(HiveTypeIds.user, UserAdapter(), 'User');
      
      // Register Property & Tenant models (10-19)
      _registerAdapter(HiveTypeIds.property, PropertyAdapter(), 'Property');
      _registerAdapter(HiveTypeIds.emergencyContact, EmergencyContactAdapter(), 'EmergencyContact');
      _registerAdapter(HiveTypeIds.tenant, TenantAdapter(), 'Tenant');
      
      // Register Payment models (20-29)
      _registerAdapter(HiveTypeIds.payment, PaymentAdapter(), 'Payment');
      _registerAdapter(HiveTypeIds.paymentTenant, PaymentTenantAdapter(), 'PaymentTenant');
      _registerAdapter(HiveTypeIds.paymentProperty, PaymentPropertyAdapter(), 'PaymentProperty');
      _registerAdapter(HiveTypeIds.paymentProcessor, PaymentProcessorAdapter(), 'PaymentProcessor');
      
      _isInitialized = true;
      print('HiveRegistry: All adapters registered successfully');
      
      // Optional: Print registry for debugging
      if (const bool.fromEnvironment('dart.vm.product') == false) {
        HiveTypeIds.printRegistry();
      }
      
    } catch (e) {
      print('HiveRegistry: Error during registration: $e');
      rethrow;
    }
  }
  
  static void _registerAdapter<T>(int typeId, TypeAdapter<T> adapter, String name) {
    if (!Hive.isAdapterRegistered(typeId)) {
      Hive.registerAdapter(adapter);
      print('HiveRegistry: Registered $name (typeId: $typeId)');
    } else {
      print('HiveRegistry: $name (typeId: $typeId) already registered');
    }
  }
  
  // Helper method to check registration status
  static bool get isInitialized => _isInitialized;
  
  // Method to force re-registration (use with caution)
  static void forceReset() {
    _isInitialized = false;
    print('HiveRegistry: Reset forced - adapters can be registered again');
  }
  
  // Debug method to check all registrations
static void checkRegistrations() {
  print('=== HIVE REGISTRATION STATUS ===');
  for (final entry in HiveTypeIds.registry.entries) {
    final isRegistered = Hive.isAdapterRegistered(entry.key);
    print('${entry.key.toString().padLeft(2, '0')}: ${entry.value} - ${isRegistered ? '✅' : '❌'}');
  }
  print('===============================');
}
}