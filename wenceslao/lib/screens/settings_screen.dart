import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../provider/app_state_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppStateProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color bgColor = isDark ? const Color(0xFF0B0F19) : const Color(0xFFF1F5F9);
    final Color cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final Color labelColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final Color textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final Color subtitleColor = isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: isDark ? Colors.white : const Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: GoogleFonts.outfit(
            color: textColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // --- Student Info Card ---
          if (provider.currentStudent != null) ...[
            _SectionHeader(label: 'ACCOUNT', labelColor: labelColor),
            const SizedBox(height: 8),
            _SettingsCard(
              cardColor: cardColor,
              borderColor: borderColor,
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      provider.currentStudent!.name.substring(0, 1).toUpperCase(),
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          provider.currentStudent!.name,
                          style: GoogleFonts.outfit(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          provider.currentStudent!.email,
                          style: GoogleFonts.inter(
                            color: subtitleColor,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'ID: ${provider.currentStudent!.id}',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF818CF8),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // --- Appearance Section ---
          _SectionHeader(label: 'APPEARANCE', labelColor: labelColor),
          const SizedBox(height: 8),
          _SettingsCard(
            cardColor: cardColor,
            borderColor: borderColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.palette_outlined, color: Color(0xFF818CF8), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Theme Mode', style: GoogleFonts.inter(color: textColor, fontWeight: FontWeight.w600, fontSize: 14)),
                          Text('Choose your preferred appearance', style: GoogleFonts.inter(color: subtitleColor, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Theme Selector
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      _ThemeOption(
                        label: 'System',
                        icon: Icons.brightness_auto_rounded,
                        isSelected: provider.themeMode == ThemeMode.system,
                        isDark: isDark,
                        onTap: () => provider.setThemeMode(ThemeMode.system),
                      ),
                      _ThemeOption(
                        label: 'Light',
                        icon: Icons.light_mode_rounded,
                        isSelected: provider.themeMode == ThemeMode.light,
                        isDark: isDark,
                        onTap: () => provider.setThemeMode(ThemeMode.light),
                      ),
                      _ThemeOption(
                        label: 'Dark',
                        icon: Icons.dark_mode_rounded,
                        isSelected: provider.themeMode == ThemeMode.dark,
                        isDark: isDark,
                        onTap: () => provider.setThemeMode(ThemeMode.dark),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // --- Data & Connectivity Section ---
          _SectionHeader(label: 'DATA & CONNECTIVITY', labelColor: labelColor),
          const SizedBox(height: 8),
          _SettingsCard(
            cardColor: cardColor,
            borderColor: borderColor,
            child: _SettingsTile(
              icon: Icons.cloud_outlined,
              iconBgColor: provider.firebaseMode
                  ? const Color(0xFF10B981).withValues(alpha: 0.1)
                  : const Color(0xFFF59E0B).withValues(alpha: 0.1),
              iconColor: provider.firebaseMode ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
              title: 'Firebase Mode',
              subtitle: provider.firebaseMode
                  ? 'Connected to live database'
                  : 'Using offline demo data',
              textColor: textColor,
              subtitleColor: subtitleColor,
              trailing: Switch(
                value: provider.firebaseMode,
                activeThumbColor: const Color(0xFF6366F1),
                onChanged: (val) => provider.setDatabaseMode(val),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // --- Notifications Section ---
          _SectionHeader(label: 'NOTIFICATIONS', labelColor: labelColor),
          const SizedBox(height: 8),
          _SettingsCard(
            cardColor: cardColor,
            borderColor: borderColor,
            child: _SettingsTile(
              icon: Icons.notifications_none_rounded,
              iconBgColor: const Color(0xFF6366F1).withValues(alpha: 0.1),
              iconColor: const Color(0xFF818CF8),
              title: 'Study Reminders',
              subtitle: 'Get notified about upcoming due tasks',
              textColor: textColor,
              subtitleColor: subtitleColor,
              trailing: Switch(
                value: provider.studyReminders,
                activeThumbColor: const Color(0xFF6366F1),
                onChanged: (val) => provider.setStudyReminders(val),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // --- About Section ---
          _SectionHeader(label: 'ABOUT', labelColor: labelColor),
          const SizedBox(height: 8),
          _SettingsCard(
            cardColor: cardColor,
            borderColor: borderColor,
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.info_outline_rounded,
                  iconBgColor: const Color(0xFF6366F1).withValues(alpha: 0.1),
                  iconColor: const Color(0xFF818CF8),
                  title: 'App Version',
                  subtitle: 'ScoreRecord v1.0.0',
                  textColor: textColor,
                  subtitleColor: subtitleColor,
                  trailing: null,
                ),
                Divider(color: borderColor, height: 1),
                _SettingsTile(
                  icon: Icons.school_rounded,
                  iconBgColor: const Color(0xFF10B981).withValues(alpha: 0.1),
                  iconColor: const Color(0xFF10B981),
                  title: 'Purpose',
                  subtitle: 'Academic grade tracker & study planner',
                  textColor: textColor,
                  subtitleColor: subtitleColor,
                  trailing: null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helper Widgets
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final String label;
  final Color labelColor;
  const _SectionHeader({required this.label, required this.labelColor});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.inter(
        color: labelColor,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final Widget child;
  final Color cardColor;
  final Color borderColor;
  const _SettingsCard({required this.child, required this.cardColor, required this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Color textColor;
  final Color subtitleColor;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.textColor,
    required this.subtitleColor,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(color: textColor, fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle, style: GoogleFonts.inter(color: subtitleColor, fontSize: 12)),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF6366F1) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? Colors.white
                    : (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
