import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../presentation/home_bottom_nav/controller/broadcast_controller.dart';
import '../../configs/app_colors.dart';
import 'common_text.dart';

/// Admin broadcast banners shown above the flight search (and anywhere else
/// they're placed). Severity uses the portal's status colour pairs; each
/// banner is dismissible for the session, exactly like the agency portal.
class BroadcastBanner extends StatelessWidget {
  BroadcastBanner({super.key});

  final BroadcastController controller = Get.put(BroadcastController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.messages.isEmpty) return const SizedBox.shrink();
      return Column(
        children: controller.messages
            .map((m) => _BannerCard(
                  message: m,
                  onDismiss: () => controller.dismiss(m.id),
                ))
            .toList(),
      );
    });
  }
}

class _BannerCard extends StatefulWidget {
  const _BannerCard({required this.message, required this.onDismiss});
  final BroadcastMessage message;
  final VoidCallback onDismiss;

  @override
  State<_BannerCard> createState() => _BannerCardState();
}

class _BannerCardState extends State<_BannerCard> {
  static const _colors = {
    'info': (Color(0xFFE7EFFC), Color(0xFF1560B8)),
    'success': (Color(0xFFE5F6EE), Color(0xFF0D7A4F)),
    'warning': (Color(0xFFFDF3DD), Color(0xFF996408)),
    'error': (Color(0xFFFDE9E7), Color(0xFFC2392E)),
  };

  static const _icons = {
    'info': Icons.campaign_rounded,
    'success': Icons.check_circle_rounded,
    'warning': Icons.warning_rounded,
    'error': Icons.error_rounded,
  };

  bool _expanded = false;

  /// Admins often type titles in capitals; show them in sentence case so the
  /// banner doesn't shout.
  static String _sentence(String s) {
    final t = s.trim();
    if (t.isEmpty || t != t.toUpperCase()) return t;
    final lower = t.toLowerCase();
    return lower[0].toUpperCase() + lower.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.message;
    final (bg, fg) = _colors[m.severity] ?? _colors['info']!;
    final long = m.message.length > 110;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: fg),
            Expanded(
              child: InkWell(
                onTap: long ? () => setState(() => _expanded = !_expanded) : null,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 4, 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(_icons[m.severity] ?? Icons.campaign_rounded,
                          size: 18, color: fg),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (m.title.isNotEmpty)
                              CommonText(
                                text: _sentence(m.title),
                                fontSize: 13.0,
                                weight: FontWeight.w700,
                                color: fg,
                              ),
                            if (m.message.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              CommonText(
                                text: m.message.trim(),
                                fontSize: 12.5,
                                lineHeight: 1.35,
                                color: AppColors.appColorTextBlack,
                                maxLines: _expanded ? null : 2,
                                overFlow: _expanded
                                    ? TextOverflow.visible
                                    : TextOverflow.ellipsis,
                              ),
                            ],
                            if (long)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: CommonText(
                                  text: _expanded
                                      ? 'common.showLess'.tr
                                      : 'common.showMore'.tr,
                                  fontSize: 11.5,
                                  weight: FontWeight.w600,
                                  color: fg,
                                ),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: widget.onDismiss,
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints:
                            const BoxConstraints(minWidth: 32, minHeight: 32),
                        icon: Icon(Icons.close_rounded, size: 16, color: fg),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
