import 'package:equatable/equatable.dart';
import 'package:foundation/foundation.dart';

class CompanySettings extends Equatable {
  final UniqueId id;
  final String name;
  final String? logo;
  final String address;
  final String phone;
  final String email;
  final String taxNumber;
  final Currency currency;
  final DateTime fiscalYearStart;
  final DateTime lastUpdated;

  const CompanySettings({
    required this.id,
    required this.name,
    this.logo,
    required this.address,
    required this.phone,
    required this.email,
    required this.taxNumber,
    this.currency = Currency.usd,
    required this.fiscalYearStart,
    required this.lastUpdated,
  });

  CompanySettings copyWith({
    UniqueId? id,
    String? name,
    String? logo,
    String? address,
    String? phone,
    String? email,
    String? taxNumber,
    Currency? currency,
    DateTime? fiscalYearStart,
    DateTime? lastUpdated,
  }) {
    return CompanySettings(
      id: id ?? this.id,
      name: name ?? this.name,
      logo: logo ?? this.logo,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      taxNumber: taxNumber ?? this.taxNumber,
      currency: currency ?? this.currency,
      fiscalYearStart: fiscalYearStart ?? this.fiscalYearStart,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        logo,
        address,
        phone,
        email,
        taxNumber,
        currency,
        fiscalYearStart,
        lastUpdated,
      ];
}
