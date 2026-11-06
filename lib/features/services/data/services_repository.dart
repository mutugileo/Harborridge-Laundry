import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laundry_ridge/features/services/domain/laundry_service.dart';

abstract class ServicesRepository {
  Future<List<LaundryService>> fetchAvailableServices();
}

class InMemoryServicesRepository implements ServicesRepository {
  @override
  Future<List<LaundryService>> fetchAvailableServices() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return const [
      LaundryService(
        id: 'wash_fold',
        title: 'Wash & Fold',
        description:
            'Everyday clothing washed, tumble dried, and folded neatly.',
        category: ServiceCategory.washAndFold,
        estimatedTurnaroundHours: 24,
        unitPrice: 2.50,
        unitLabel: '/ lb',
        icon: Icons.local_laundry_service_rounded,
      ),
      LaundryService(
        id: 'dry_clean_suit',
        title: 'Premium Dry Clean',
        description:
            'Suits, evening wear, and delicate garments carefully treated.',
        category: ServiceCategory.dryCleaning,
        estimatedTurnaroundHours: 48,
        unitPrice: 12.00,
        unitLabel: '/ item',
        icon: Icons.dry_cleaning_rounded,
      ),
      LaundryService(
        id: 'steam_press',
        title: 'Steam Press & Ironing',
        description:
            'Crisp hand-pressed finish on shirts, blouses, and trousers.',
        category: ServiceCategory.ironing,
        estimatedTurnaroundHours: 12,
        unitPrice: 3.50,
        unitLabel: '/ item',
        icon: Icons.iron_rounded,
      ),
      LaundryService(
        id: 'bedding_duvets',
        title: 'Comforters & Linens',
        description:
            'Deep sanitized cleaning for king/queen duvets and sheets.',
        category: ServiceCategory.bedding,
        estimatedTurnaroundHours: 36,
        unitPrice: 18.00,
        unitLabel: '/ piece',
        icon: Icons.bed_rounded,
      ),
    ];
  }
}

final servicesRepositoryProvider = Provider<ServicesRepository>((ref) {
  return InMemoryServicesRepository();
});
