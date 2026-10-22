import 'package:flutter/material.dart';

import '../../app/localization/app_localizations.dart';
import '../../app/theme/app_theme.dart';
import '../channels/channel_presentation.dart';

/// Horizontal scrollable bar displaying prioritized communication channel filter chips.
class ChannelFilterBar extends StatelessWidget {
  final String selectedChannel;
  final ValueChanged<String> onChannelSelected;
  final List<ChannelMeta> channels;
  final Map<String, int>? channelCounts;

  const ChannelFilterBar({
    super.key,
    required this.selectedChannel,
    required this.onChannelSelected,
    this.channels = ChannelPresentation.primaryFilterChannels,
    this.channelCounts,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: channels.map((meta) {
          final isSelected =
              selectedChannel == meta.key ||
              (selectedChannel.isEmpty && meta.key == 'all');
          final count = channelCounts?[meta.key];
          final label = meta.localizedName(context);

          return Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: ChoiceChip(
              avatar: Icon(
                meta.icon,
                size: 16,
                color: isSelected ? Colors.white : meta.brandColor,
              ),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label),
                  if (count != null && count > 0) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.25)
                            : meta.brandColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        count.toString(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : meta.brandColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              selected: isSelected,
              onSelected: (_) => onChannelSelected(meta.key),
              selectedColor: meta.key == 'all'
                  ? AppColors.primary
                  : meta.brandColor,
              backgroundColor: AppColors.surfaceCanvas,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.onSurface,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
              side: BorderSide(
                color: isSelected
                    ? Colors.transparent
                    : (meta.key == 'all'
                          ? AppColors.borderHairline
                          : meta.brandColor.withValues(alpha: 0.35)),
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Header bar indicating how many filters are currently active, with an easy "Clear All" action.
class ActiveFiltersHeader extends StatelessWidget {
  final int activeCount;
  final VoidCallback onClear;
  final String? customLabel;

  const ActiveFiltersHeader({
    super.key,
    required this.activeCount,
    required this.onClear,
    this.customLabel,
  });

  @override
  Widget build(BuildContext context) {
    if (activeCount <= 0) {
      return const SizedBox.shrink();
    }

    String strings(String key) => AppStrings.get(key, context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryFixed.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                activeCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              customLabel ?? strings('active_filters'),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          InkWell(
            onTap: onClear,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.filter_alt_off_rounded,
                    size: 14,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    strings('clear_filters'),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Clean empty state widget shown when search/filters return no results,
/// giving the merchant an instant way to reset filters.
class FilterEmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onClearFilters;
  final String? clearButtonText;
  final IconData icon;

  const FilterEmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.onClearFilters,
    this.clearButtonText,
    this.icon = Icons.search_off_rounded,
  });

  @override
  Widget build(BuildContext context) {
    String strings(String key) => AppStrings.get(key, context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderHairline),
              ),
              child: Icon(icon, size: 36, color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
              ),
            ],
            if (onClearFilters != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onClearFilters,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: Text(clearButtonText ?? strings('clear_filters')),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Visual brand badge for a specific channel (e.g. WhatsApp, Telegram, Facebook).
class ChannelBadge extends StatelessWidget {
  final String channel;
  final bool showLabel;
  final double size;

  const ChannelBadge({
    super.key,
    required this.channel,
    this.showLabel = true,
    this.size = 14,
  });

  @override
  Widget build(BuildContext context) {
    final meta = ChannelPresentation.getMeta(channel);
    final label = meta.localizedName(context);

    if (!showLabel) {
      return Container(
        width: size + 8,
        height: size + 8,
        decoration: BoxDecoration(
          color: meta.backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Icon(meta.icon, size: size, color: meta.brandColor),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: meta.backgroundColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: meta.brandColor.withValues(alpha: 0.3),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(meta.icon, size: size, color: meta.brandColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: meta.brandColor,
            ),
          ),
        ],
      ),
    );
  }
}
