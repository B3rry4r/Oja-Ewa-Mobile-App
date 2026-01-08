import '../domain/address.dart';

/// Mock address book.
///
/// Replace with API / local storage later.
const mockAddresses = <Address>[
  Address(
    id: 'a1',
    fullName: 'Sanusi Sulat',
    phone: '08102718764',
    country: 'Nigeria',
    state: 'FCT',
    city: 'Abuja',
    postCode: '900187',
    addressLine: 'Royal Anchor',
    isDefault: true,
  ),
];
