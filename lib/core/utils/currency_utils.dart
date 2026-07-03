/// Maps a shipping country name to an ISO 4217 currency code.
///
/// This mirrors the logic in FlutterwaveService::currencyForCountry() on the API.
/// The source of truth is ALWAYS the server — this is purely for UI display
/// (showing the right symbol before the payment link is created).
///
/// Real-world rationale: the delivery country — not device locale or IP —
/// is used because it is what the user explicitly chose. Same approach as Shopify.
String currencyForCountry(String country) {
  final c = country.trim().toLowerCase();

  // No country chosen yet (e.g. before an address is selected on checkout).
  // This is a Nigeria-first marketplace, so default the DISPLAY to NGN (₦)
  // rather than the USD fallback — an empty country means "unknown", not
  // "foreign". The server still resolves the real charge currency from the
  // delivery country at payment time, so this only affects on-screen symbols.
  if (c.isEmpty) return 'NGN';

  if (['nigeria', 'ng', 'ngn'].contains(c)) return 'NGN';

  if (['united kingdom', 'uk', 'great britain', 'england',
       'scotland', 'wales', 'northern ireland', 'gb'].contains(c)) return 'GBP';

  if (['germany', 'france', 'italy', 'spain', 'netherlands', 'belgium',
       'austria', 'portugal', 'ireland', 'finland', 'greece', 'luxembourg',
       'slovakia', 'slovenia', 'estonia', 'latvia', 'lithuania', 'malta',
       'cyprus', 'eurozone', 'europe'].contains(c)) return 'EUR';

  if (['ghana', 'gh', 'ghs'].contains(c)) return 'GHS';
  if (['kenya', 'ke', 'kes'].contains(c)) return 'KES';
  if (['south africa', 'za', 'zar'].contains(c)) return 'ZAR';
  if (['tanzania', 'tz', 'tzs'].contains(c)) return 'TZS';
  if (['uganda', 'ug', 'ugx'].contains(c)) return 'UGX';
  if (['rwanda', 'rw', 'rwf'].contains(c)) return 'RWF';
  if (['zambia', 'zm', 'zmw'].contains(c)) return 'ZMW';

  // Universal fallback for all other countries
  return 'USD';
}

/// Returns the display symbol for an ISO 4217 currency code.
String currencySymbol(String currency) {
  return switch (currency.toUpperCase()) {
    'NGN' => '₦',
    'GBP' => '£',
    'EUR' => '€',
    'USD' => r'$',
    'GHS' => 'GH₵',
    'KES' => 'KSh',
    'ZAR' => 'R',
    'TZS' => 'TSh',
    'UGX' => 'USh',
    'RWF' => 'RF',
    'ZMW' => 'ZK',
    _ => currency,
  };
}

