class AppPolicy {
  final String id;
  final String title;
  final String subtitle;
  final String body;

  const AppPolicy({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.body,
  });
}

/// In-app legal / policy copy for Tripo (demo travel companion).
class AppPolicies {
  AppPolicies._();

  static const List<AppPolicy> all = [
    AppPolicy(
      id: 'privacy',
      title: 'Privacy Policy',
      subtitle: 'How we handle your data',
      body: '''
Last updated: 1 August 2026

Tripo (“we”, “our”, “the app”) respects your privacy. This policy explains what information the app may use and how it is handled.

1. Information we use
• Account details you enter when signing in (demo login may be stored on your device).
• Location data, when you allow it, for weather, map, and compass features.
• Files you choose to save in Docs (stored locally on your device).
• Notes, todos, and split-money data you create (stored locally).

2. How we use information
• To show weather, maps, currency, and travel tools.
• To keep your notes, todos, documents, and trip splits on this device.
• We do not sell your personal information.

3. Storage
Most travel tools in this demo save data on your device (for example SharedPreferences and local files). If you uninstall the app, that local data may be removed.

4. Third-party services
Tripo may call third-party APIs (weather, geocoding, currency rates, maps, flags). Those providers process requests under their own policies.

5. Your choices
• You can deny location permission in system settings.
• You can clear app data or uninstall Tripo to remove local demo data.

6. Contact
For privacy questions about this demo app, use the in-app Profile / Login feedback path or your developer contact.
''',
    ),
    AppPolicy(
      id: 'terms',
      title: 'Terms of Service',
      subtitle: 'Rules for using Tripo',
      body: '''
Last updated: 1 August 2026

By using Tripo you agree to these Terms.

1. The service
Tripo is a travel companion demo for weather, packages, maps, and tools. Features may change, and some data is sample or demo-only.

2. Acceptable use
• Use the app lawfully and respectfully.
• Do not misuse location, documents, or shared split groups to harm others.
• Do not attempt to disrupt APIs or reverse-engineer in a harmful way.

3. Accounts
Demo login is for demonstration. You are responsible for activity on your device.

4. Packages & bookings
Package listings may be illustrative. “Book now” and similar actions are demo flows unless a real booking partner is connected.

5. Availability
We may update, pause, or remove features without notice in this demo build.

6. Limitation of liability
Tripo is provided “as is”. We are not liable for travel decisions, rate accuracy, sensor readings, or third-party outages beyond what the law requires.

7. Changes
We may update these Terms. Continued use after an update means you accept the revised Terms.
''',
    ),
    AppPolicy(
      id: 'cookies',
      title: 'Cookie Policy',
      subtitle: 'Local storage & similar tech',
      body: '''
Last updated: 1 August 2026

Tripo is a mobile app and does not use browser cookies in the usual website sense. We may use similar on-device storage.

1. What we store locally
• Preferences (theme-related settings, last city, login demo state).
• Notes, todos, split groups, and document metadata you create.
• Cached or last-known location when permitted.

2. Why
• To remember your choices and keep tools working offline where possible.

3. Control
Clear app storage or uninstall Tripo to remove local data. System permission settings control location access.
''',
    ),
    AppPolicy(
      id: 'refund',
      title: 'Refund & Cancellation',
      subtitle: 'Demo bookings & payments',
      body: '''
Last updated: 1 August 2026

1. Demo status
Tripo’s package “Book now” and payment-related screens are demonstration flows unless connected to a live payment provider.

2. Real bookings
If a future version processes real payments through a partner, refund and cancellation rules of that partner / hotel / airline will apply. Those rules will be shown at checkout.

3. In-app purchases
If paid features are added later, refunds follow the app store (Google Play / App Store) policies.

4. Split money
Split-money balances are for group tracking on your device and are not bank transfers unless a payment integration is added.
''',
    ),
    AppPolicy(
      id: 'community',
      title: 'Community Guidelines',
      subtitle: 'Be a good travel companion',
      body: '''
Last updated: 1 August 2026

When using shared features (for example split groups or shared notes on a device):

• Be respectful and honest about expenses and memberships.
• Do not harass, spam, or share others’ private documents without consent.
• Keep emergency contacts accurate for your own safety planning.
• Report bugs or misuse through normal app feedback channels.

Violations may lead to feature limits in future versions of Tripo.
''',
    ),
    AppPolicy(
      id: 'permissions',
      title: 'Data & Permissions',
      subtitle: 'Location, files, sensors',
      body: '''
Last updated: 1 August 2026

Tripo may request:

• Location — weather, map, compass place label, nearby context.
• Storage / files — Docs vault uploads you choose.
• Sensors — compass heading (magnetometer).
• Network — live weather, maps, currency, flags, reverse geocoding.

You can revoke permissions in your device settings. Some features will then be limited or offline-only.
''',
    ),
    AppPolicy(
      id: 'about',
      title: 'About Tripo',
      subtitle: 'Version & credits',
      body: '''
Tripo — travel companion demo

Version: 1.0.0

Built for exploring weather, packages, maps, and trip tools (notes, todos, compass, currency, world clock, docs, split money).

Data sources may include Open-Meteo, Frankfurter (ECB rates), OpenStreetMap Nominatim, flagcdn, and map providers as configured in the app.

This build focuses on on-device demo storage. A full cloud database may be connected in a later release.
''',
    ),
  ];

  static AppPolicy? byId(String id) {
    for (final p in all) {
      if (p.id == id) return p;
    }
    return null;
  }
}
