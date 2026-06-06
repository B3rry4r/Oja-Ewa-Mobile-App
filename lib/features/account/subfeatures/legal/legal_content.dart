// WAWUBeauty legal content — rendered in-app (no PDFs / external links).
// Source: "WAWUBeauty Terms, Privacy and FAQ" document.

/// A titled block of body text within a legal document.
class LegalSection {
  const LegalSection(this.heading, this.body);
  final String heading;
  final String body;
}

/// A single question/answer pair.
class FaqEntry {
  const FaqEntry(this.question, this.answer);
  final String question;
  final String answer;
}

/// A category of FAQ entries.
class FaqGroup {
  const FaqGroup(this.category, this.entries);
  final String category;
  final List<FaqEntry> entries;
}

const String kTermsIntro =
    'WAWUBeauty is a product of WAWUAfrica. By accessing or using the WAWUBeauty '
    'platform (website, mobile app, or related services), you agree to these Terms.';

const List<LegalSection> kTermsSections = [
  LegalSection(
    '1. Who can use WAWUBeauty',
    'You must be at least 18 years old to sell on WAWUBeauty. Buyers must be at '
        'least 13 years old with parental consent where required. You are responsible '
        'for all activity under your account.',
  ),
  LegalSection(
    '2. Selling on WAWUBeauty',
    'All products listed must be authentic African creative goods — beauty, fashion, '
        'art, or related handmade or designed items. Mass-produced imports are not '
        'allowed. You warrant that you own the rights to everything you sell.\n\n'
        'WAWUBeauty charges a commission on each completed sale. Delivery costs are '
        'covered by the seller but managed end-to-end by WAWUBeauty. There are no '
        'monthly fees or onboarding fees.',
  ),
  LegalSection(
    '3. Payments and logistics',
    'When a buyer makes a purchase, funds are held securely in escrow. Once the buyer '
        'confirms receipt, your payment is released and available within 24 hours.\n\n'
        'WAWUBeauty partners with logistic partners for pickup and delivery. You do not '
        'need to arrange shipping yourself, but you must ensure products are ready for '
        'pickup within the stated handling time.',
  ),
  LegalSection(
    '4. Badges and verification',
    'WAWUBeauty offers optional paid badges: Black Badge, Gold Badge and Green Badge. '
        'Badges certify experience, brand presence and quality, authenticity, heritage '
        'craftsmanship, or sustainable practices. Badges are non-transferable and '
        'non-refundable. Misrepresentation (e.g., claiming a badge without meeting '
        'standards) may result in permanent account suspension.',
  ),
  LegalSection(
    '5. Prohibited behaviour',
    'You may not sell counterfeit goods, stolen items, prohibited substances, or '
        'anything illegal under Nigerian or international law. You may not manipulate '
        'reviews, harass other users, or attempt to bypass WAWUBeauty payment system.',
  ),
  LegalSection(
    '6. Account suspension and termination',
    'WAWUBeauty reserves the right to suspend or terminate any account for violation '
        'of these Terms, fraud, or repeated customer disputes. You may close your '
        'account at any time by contacting support.',
  ),
  LegalSection(
    '7. Limitation of liability',
    'WAWUBeauty provides the platform "as is." We are not liable for lost profits, '
        'delivery delays beyond our control, or damages arising from your use of the '
        'platform. Our total liability is limited to the fees you paid us in the prior '
        'three months.',
  ),
  LegalSection(
    '8. Changes to these Terms',
    'We may update these Terms from time to time. Continued use of WAWUBeauty after '
        'changes means you accept the new Terms.',
  ),
  LegalSection(
    '9. Contact',
    'For any issues: support@wawubeauty.com or call 07050722222.',
  ),
];

const String kPrivacyIntro =
    'WAWUBeauty (a product of WAWUAfrica) respects your privacy. This policy explains '
    'what data we collect, why we collect it, and how we protect it.';

const List<LegalSection> kPrivacySections = [
  LegalSection(
    '1. What we collect',
    'When you sign up as a seller or buyer, we collect:\n'
        '• Your name, email address, phone number, and delivery address.\n'
        '• Business registration details (for sellers).\n'
        '• Transaction history and payment information.\n'
        '• Communications with support.\n'
        '• Device and usage data (app version, IP address, browser type).',
  ),
  LegalSection(
    '2. Why we collect it',
    'We use your data to:\n'
        '• Create and manage your account.\n'
        '• Process payments and coordinate logistics (we share necessary details with '
        'DHL and GIG Logistics).\n'
        '• Verify badge applications (identity, craft evidence, sustainability records).\n'
        '• Improve the platform and prevent fraud.\n'
        '• Send you important updates about your orders, account, or policy changes.\n'
        '• Provide additional services for sellers or users (trainings, economic and '
        'financial inclusion services in partnership with financial institutions).',
  ),
  LegalSection(
    '3. What we do NOT do',
    'We do not sell your personal data to third parties. We do not share your '
        'financial information beyond what is required to complete payments through our '
        'secure partners.',
  ),
  LegalSection(
    '4. Data retention',
    'We keep your account data for as long as your account is active, plus up to three '
        'years after closure for legal and tax purposes. You may request deletion of '
        'your data by contacting support.',
  ),
  LegalSection(
    '5. Your rights',
    'You have the right to:\n'
        '• Access the personal data we hold about you.\n'
        '• Correct inaccurate information.\n'
        '• Request deletion of your data (subject to legal obligations).\n'
        '• Opt out of non-essential communications.\n\n'
        'To exercise these rights, email privacy@wawubeauty.com.',
  ),
  LegalSection(
    '6. Security',
    'We use encryption and secure servers to protect your data. However, no online '
        'system is 100% secure. You are responsible for keeping your password '
        'confidential.',
  ),
  LegalSection(
    "7. Children's privacy",
    'WAWUBeauty does not knowingly collect data from children under 13. If you believe '
        'a child has provided us with personal information, please contact us.',
  ),
  LegalSection(
    '8. Changes to this policy',
    'We will notify you of significant changes via email or a prominent notice on the '
        'app.',
  ),
  LegalSection(
    '9. Contact',
    'Privacy questions: privacy@wawubeauty.com\n'
        'General support: support@wawubeauty.com or 07050722222.',
  ),
];

const List<FaqGroup> kFaqGroups = [
  FaqGroup('Getting started', [
    FaqEntry(
      'How do I join WAWUBeauty as a seller?',
      'Download the WAWUBeauty app or visit our website. Click "Sell with us" and '
          'complete the registration. Onboarding is free.',
    ),
    FaqEntry(
      'Is there a monthly fee?',
      'No. You pay nothing upfront. WAWUBeauty only takes a commission when you make a '
          'sale.',
    ),
    FaqEntry(
      'What can I sell?',
      'Authentic African beauty, fashion, art, and creative goods. This includes '
          'handmade cosmetics, jewelry, clothing, accessories, skincare, and traditional '
          'crafts. No mass-produced imports.',
    ),
  ]),
  FaqGroup('Selling and payments', [
    FaqEntry(
      'How do I get paid?',
      'When a buyer purchases your product, the money is held securely. Once the buyer '
          'confirms receipt, your payment is released and available within 24 hours.',
    ),
    FaqEntry(
      'Who handles delivery?',
      'WAWUBeauty does. We partner with logistics partners. You only need to have your '
          'product ready for pickup. The delivery cost is covered by you (the seller) but '
          'managed by us.',
    ),
    FaqEntry(
      "What happens if a buyer says they didn't receive the item?",
      'We use live tracking for every delivery. If there is a genuine dispute, our '
          'support team investigates using tracking data. Funds are only released when '
          'delivery is confirmed.',
    ),
  ]),
  FaqGroup('Badges', [
    FaqEntry(
      'What are badges?',
      'Badges are optional yearly certifications that appear on your profile and '
          'products. They build buyer trust. Black Badge, Gold Badge and Green Badge.',
    ),
    FaqEntry(
      'Do I need a badge to sell?',
      'No. Anyone can sell without a badge. Badges are for sellers who want higher '
          'visibility, trust, and premium benefits.',
    ),
    FaqEntry(
      'Can I get more than one badge?',
      'No. You can hold one badge per time after meeting the required KYC. You must '
          'hold a badge for at least three months before applying for a new badge.',
    ),
  ]),
  FaqGroup('Training and equipment', [
    FaqEntry(
      'Is the training free?',
      'Yes. Every seller gets free ALISON-training courses in digital entrepreneurship, '
          'e-commerce, brand storytelling, export compliance, and sustainable production. '
          'Certificate comes at a discounted cost.',
    ),
    FaqEntry(
      'How do I get subsidized equipment?',
      'After you have been actively selling on WAWUBeauty for six months or more, you '
          'can apply for subsidized equipment — industrial sewing machines, beauty '
          'production tools, or solar panels.',
    ),
  ]),
  FaqGroup('Account and support', [
    FaqEntry(
      'How do I close my account?',
      'Email support@wawubeauty.com from the email address linked to your account. We '
          'will process your request within 7 business days.',
    ),
    FaqEntry(
      'What if I forget my password?',
      'Use the "Forgot password" link on the login screen. A reset link will be sent '
          'to your registered email.',
    ),
    FaqEntry(
      'How do I contact a real person?',
      'Call 07050722222 or email support@wawubeauty.com. Our support hours are Monday '
          'to Friday, 9 AM to 6 PM WAT.',
    ),
  ]),
  FaqGroup('Privacy and safety', [
    FaqEntry(
      'Does WAWUBeauty share my data with others?',
      'Only as needed to operate the platform and for socioeconomic and financial '
          'inclusion purposes. We never sell your personal data. Your data will only be '
          'used to improve services and opportunities for you.',
    ),
    FaqEntry(
      'Is my payment information safe?',
      'Yes. We use secure, encrypted payment processing with payment partners. '
          'WAWUBeauty does not store your full card details.',
    ),
  ]),
];
