import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_text_field.dart';
import '../widgets/glass_card.dart';
import '../widgets/page_header.dart';
import '../widgets/pill_button.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(
            title: 'Contact Us',
            subtitle: 'We are here to help you and your family',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                // Quick contact tiles
                Row(
                  children: const [
                    Expanded(child: _InfoTile(icon: Icons.phone_rounded, title: 'Call', value: '+880 1XXX-XXXXXX')),
                    SizedBox(width: 14),
                    Expanded(child: _InfoTile(icon: Icons.mail_rounded, title: 'Email', value: 'care@sahaara.com')),
                  ],
                ),
                const SizedBox(height: 14),
                const _InfoTile(
                    icon: Icons.location_on_rounded, title: 'Visit', value: 'Dhaka, Bangladesh', wide: true),
                const SizedBox(height: 22),
                GlassCard(
                  radius: 40,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Send us a message', style: AppTheme.heading(22)),
                      const SizedBox(height: 18),
                      const AppTextField(label: 'Your name', icon: Icons.person_outline_rounded),
                      const SizedBox(height: 12),
                      const AppTextField(
                          label: 'Email',
                          icon: Icons.mail_outline_rounded,
                          keyboardType: TextInputType.emailAddress),
                      const SizedBox(height: 12),
                      const AppTextField(
                          label: 'How can we help?',
                          icon: Icons.chat_bubble_outline_rounded,
                          maxLines: 4),
                      const SizedBox(height: 20),
                      PillButton(
                        label: 'SEND MESSAGE',
                        icon: Icons.send_rounded,
                        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Message sent (prototype)',
                                style: AppTheme.body(14, color: AppColors.sand)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool wide;
  const _InfoTile(
      {required this.icon, required this.title, required this.value, this.wide = false});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 28,
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: wide ? double.infinity : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: const BoxDecoration(color: AppColors.maroon, shape: BoxShape.circle),
              child: Icon(icon, size: 16, color: AppColors.sand),
            ),
            const SizedBox(height: 10),
            Text(title.toUpperCase(), style: AppTheme.label()),
            const SizedBox(height: 2),
            Text(value,
                style: AppTheme.body(13.5, weight: FontWeight.w600),
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
