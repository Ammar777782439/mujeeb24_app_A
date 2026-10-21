import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';

/// Representation metadata for communication channels.
/// Distinguishes user-facing brand identities (WhatsApp, Facebook, Telegram, etc.)
/// from backend/technical providers.
@immutable
class ChannelMeta {
  final String key;
  final String nameAr;
  final String nameEn;
  final IconData icon;
  final Color brandColor;
  final Color backgroundColor;

  const ChannelMeta({
    required this.key,
    required this.nameAr,
    required this.nameEn,
    required this.icon,
    required this.brandColor,
    required this.backgroundColor,
  });

  String localizedName(BuildContext context) {
    final locale = Localizations.maybeLocaleOf(context);
    final isAr = locale == null || locale.languageCode == 'ar';
    return isAr ? nameAr : nameEn;
  }
}

/// Helper and registry for all supported communication channels in Mujeeb24.
class ChannelPresentation {
  static const ChannelMeta all = ChannelMeta(
    key: 'all',
    nameAr: 'كافة القنوات',
    nameEn: 'All Channels',
    icon: Icons.hub_outlined,
    brandColor: AppColors.primary,
    backgroundColor: AppColors.surfaceContainerLow,
  );

  static const ChannelMeta whatsapp = ChannelMeta(
    key: 'whatsapp',
    nameAr: 'واتساب',
    nameEn: 'WhatsApp',
    icon: Icons.chat_bubble_rounded,
    brandColor: AppColors.channelWhatsapp,
    backgroundColor: Color(0x1F25D366),
  );

  static const ChannelMeta facebook = ChannelMeta(
    key: 'facebook',
    nameAr: 'فيسبوك',
    nameEn: 'Facebook',
    icon: Icons.facebook,
    brandColor: AppColors.channelFacebook,
    backgroundColor: Color(0x1F1877F2),
  );

  static const ChannelMeta telegram = ChannelMeta(
    key: 'telegram',
    nameAr: 'تليجرام',
    nameEn: 'Telegram',
    icon: Icons.send_rounded,
    brandColor: AppColors.channelTelegram,
    backgroundColor: Color(0x1F229ED9),
  );

  static const ChannelMeta instagram = ChannelMeta(
    key: 'instagram',
    nameAr: 'إنستغرام',
    nameEn: 'Instagram',
    icon: Icons.camera_alt_rounded,
    brandColor: AppColors.channelInstagram,
    backgroundColor: Color(0x1FE1306C),
  );

  static const ChannelMeta sms = ChannelMeta(
    key: 'sms',
    nameAr: 'رسائل نصية',
    nameEn: 'SMS',
    icon: Icons.sms_rounded,
    brandColor: Color(0xFF0284C7),
    backgroundColor: Color(0x1F0284C7),
  );

  static const ChannelMeta webhook = ChannelMeta(
    key: 'webhook',
    nameAr: 'ويب هوك',
    nameEn: 'Webhook',
    icon: Icons.webhook_rounded,
    brandColor: Color(0xFF6366F1),
    backgroundColor: Color(0x1F6366F1),
  );

  static const ChannelMeta unknown = ChannelMeta(
    key: 'other',
    nameAr: 'قناة أخرى',
    nameEn: 'Other Channel',
    icon: Icons.public_rounded,
    brandColor: AppColors.outline,
    backgroundColor: AppColors.surfaceContainerLow,
  );

  /// Primary social channels prominently prioritized in merchant filters
  static const List<ChannelMeta> primaryFilterChannels = [
    all,
    whatsapp,
    facebook,
    telegram,
    instagram,
  ];

  /// Comprehensive list of all supported channels
  static const List<ChannelMeta> allSupportedChannels = [
    all,
    whatsapp,
    facebook,
    telegram,
    instagram,
    sms,
    webhook,
  ];

  /// Maps a channel string to its ChannelMeta
  static ChannelMeta getMeta(String? channel) {
    if (channel == null || channel.isEmpty || channel == 'all') {
      return all;
    }
    final normalized = channel.trim().toLowerCase();
    switch (normalized) {
      case 'whatsapp':
        return whatsapp;
      case 'facebook':
      case 'meta':
        return facebook;
      case 'telegram':
        return telegram;
      case 'instagram':
        return instagram;
      case 'sms':
      case 'twilio':
        return sms;
      case 'webhook':
      case 'custom':
        return webhook;
      default:
        return unknown;
    }
  }

  /// Returns user-facing brand name
  static String getDisplayName(String? channel, {bool isArabic = true}) {
    final meta = getMeta(channel);
    return isArabic ? meta.nameAr : meta.nameEn;
  }

  /// Returns brand icon
  static IconData getIcon(String? channel) {
    return getMeta(channel).icon;
  }

  /// Returns brand primary color
  static Color getBrandColor(String? channel) {
    return getMeta(channel).brandColor;
  }

  /// Returns soft background container color
  static Color getBackgroundColor(String? channel) {
    return getMeta(channel).backgroundColor;
  }
}
