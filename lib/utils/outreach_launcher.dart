import 'package:url_launcher/url_launcher.dart';

/// Builds and launches deep links to native apps for outreach delivery.
class OutreachLauncher {
  /// Opens WhatsApp with [content] pre-filled. If [phone] is provided it
  /// becomes the recipient, otherwise WhatsApp opens its contact picker.
  /// Returns true if the system reported a successful launch.
  static Future<bool> openWhatsApp({
    String? phone,
    required String content,
  }) {
    final digits = phone == null ? '' : _digitsOnly(phone);
    final encoded = Uri.encodeComponent(content);
    final url = digits.isEmpty
        ? 'https://wa.me/?text=$encoded'
        : 'https://wa.me/$digits?text=$encoded';
    return _tryLaunch(Uri.parse(url));
  }

  /// Opens the system mail client with subject and body pre-filled. No
  /// recipient — Google Places does not return business emails.
  static Future<bool> openEmail({
    required String subject,
    required String body,
  }) {
    final url =
        'mailto:?subject=${Uri.encodeQueryComponent(subject)}&body=${Uri.encodeQueryComponent(body)}';
    return _tryLaunch(Uri.parse(url));
  }

  /// Tries to open the Instagram app, falling back to the web app. Instagram
  /// has no reliable deep link to a pre-filled DM, so callers should copy the
  /// message to the clipboard first.
  static Future<bool> openInstagram() async {
    if (await _tryLaunch(Uri.parse('instagram://'))) return true;
    return _tryLaunch(Uri.parse('https://instagram.com'));
  }

  /// Opens the dialer with [phone] pre-filled.
  static Future<bool> openPhone(String phone) {
    final clean = _telSafe(phone);
    return _tryLaunch(Uri.parse('tel:$clean'));
  }

  /// Returns the email subject for [businessName] in [language].
  /// Falls back to English for unsupported language codes.
  static String emailSubjectFor(String businessName, String language) {
    switch (language) {
      case 'es':
        return 'Sobre $businessName';
      case 'pt':
        return 'Sobre $businessName';
      case 'fr':
        return 'À propos de $businessName';
      case 'en':
      default:
        return 'Quick note about $businessName';
    }
  }

  static String _digitsOnly(String phone) =>
      phone.replaceAll(RegExp(r'\D'), '');

  // tel: URIs accept '+' for the country prefix.
  static String _telSafe(String phone) =>
      phone.replaceAll(RegExp(r'[^\d+]'), '');

  static Future<bool> _tryLaunch(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
