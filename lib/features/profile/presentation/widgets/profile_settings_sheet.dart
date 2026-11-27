import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/ai_gateway_service.dart';
import '../../../../core/services/local_settings_service.dart';
import '../../../../core/services/supabase_auth_service.dart';

class ProfileSettingsSheet extends ConsumerStatefulWidget {
  const ProfileSettingsSheet({super.key});

  @override
  ConsumerState<ProfileSettingsSheet> createState() =>
      _ProfileSettingsSheetState();
}

class _ProfileSettingsSheetState extends ConsumerState<ProfileSettingsSheet> {
  late AiProviderType _selectedProvider;
  late TextEditingController _keyController;
  bool _obscureKey = true;
  bool _isTesting = false;
  String? _testMessage;
  bool _testSuccess = false;

  @override
  void initState() {
    super.initState();
    final current = ref.read(aiSettingsProvider);
    _selectedProvider = current.provider;
    _keyController = TextEditingController(text: current.apiKey);
  }

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _testKey() async {
    HapticFeedback.selectionClick();
    setState(() {
      _isTesting = true;
      _testMessage = null;
    });

    final result = await AiGatewayService.testConnection(
      provider: _selectedProvider,
      apiKey: _keyController.text,
    );

    if (!mounted) return;
    setState(() {
      _isTesting = false;
      _testSuccess = result.isSuccess;
      _testMessage = result.message;
    });
  }

  Future<void> _saveKey() async {
    HapticFeedback.mediumImpact();
    AiGatewayService.clearModelCache();
    await ref.read(aiSettingsProvider.notifier).updateSettings(
          provider: _selectedProvider,
          apiKey: _keyController.text,
        );
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: context.appColors.charcoal,
        behavior: SnackBarBehavior.floating,
        content: Text(
          _keyController.text.trim().isEmpty
              ? 'API key cleared. Running in offline curated mode.'
              : '${_selectedProvider.shortLabel} API key saved securely on device.',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Future<void> _launchKeyConsole() async {
    final uri = Uri.parse(_selectedProvider.keyConsoleUrl);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);
    final language = ref.watch(languageProvider);
    final user = SupabaseAuthService.currentUser;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      decoration: BoxDecoration(
        color: colors.cream,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(20, 14, 20, 20 + bottomInset),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.mutedBrown.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Sheet Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Settings & AI Key',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.charcoal,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: colors.charcoal),
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 1. BYOK AI Configuration Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.warmWhite,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: colors.mutedBrown.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.key_rounded,
                          size: 18,
                          color: colors.coral,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Bring Your Own AI Key (Optional)',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colors.charcoal,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Bookaind works offline with curated plans. Add your own free Groq or Gemini key to enable custom AI trip architecting.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.mutedBrown,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Provider selector
                    Row(
                      children: AiProviderType.values.map((provider) {
                        final isSelected = _selectedProvider == provider;
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: provider == AiProviderType.groq ? 8 : 0,
                            ),
                            child: InkWell(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() {
                                  _selectedProvider = provider;
                                  _testMessage = null;
                                });
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? colors.charcoal
                                      : colors.cream.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected
                                        ? colors.charcoal
                                        : colors.mutedBrown
                                            .withValues(alpha: 0.25),
                                  ),
                                ),
                                child: Text(
                                  provider.shortLabel,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.white
                                        : colors.charcoal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),

                    // API Key Field
                    TextField(
                      controller: _keyController,
                      obscureText: _obscureKey,
                      autocorrect: false,
                      enableSuggestions: false,
                      decoration: InputDecoration(
                        labelText: '${_selectedProvider.shortLabel} API Key',
                        hintText: _selectedProvider.keyHint,
                        filled: true,
                        fillColor: colors.cream.withValues(alpha: 0.4),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                _obscureKey
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                size: 18,
                                color: colors.mutedBrown,
                              ),
                              tooltip:
                                  _obscureKey ? 'Show key' : 'Hide key',
                              onPressed: () {
                                setState(() => _obscureKey = !_obscureKey);
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.content_paste_rounded,
                                size: 18,
                                color: colors.coral,
                              ),
                              tooltip: 'Paste key',
                              onPressed: () async {
                                final clip =
                                    await Clipboard.getData('text/plain');
                                if (clip?.text != null && mounted) {
                                  _keyController.text = clip!.text!.trim();
                                  setState(() => _testMessage = null);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Get Free Key Link
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: colors.teal,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 6,
                          ),
                        ),
                        onPressed: _launchKeyConsole,
                        icon: const Icon(Icons.open_in_new_rounded, size: 15),
                        label: Text(
                          'Get a free ${_selectedProvider.shortLabel} key',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    if (_testMessage != null) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _testSuccess
                              ? colors.tealSubtle
                              : colors.coralSubtle,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _testSuccess
                                ? colors.teal.withValues(alpha: 0.4)
                                : colors.coral.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _testSuccess
                                  ? Icons.check_circle_outline_rounded
                                  : Icons.error_outline_rounded,
                              size: 16,
                              color:
                                  _testSuccess ? colors.teal : colors.coral,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _testMessage!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colors.charcoal,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),

                    // Test & Save Row
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isTesting ? null : _testKey,
                            style: OutlinedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: _isTesting
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Test Key'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saveKey,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colors.coral,
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('Save Key'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 2. Application Preferences Card
              Container(
                decoration: BoxDecoration(
                  color: colors.warmWhite,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: colors.mutedBrown.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.language_rounded,
                        color: colors.charcoal,
                      ),
                      title: const Text('Language'),
                      trailing: Text(
                        language,
                        style: TextStyle(
                          color: colors.coral,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        final next = language == 'English'
                            ? 'Bahasa Indonesia'
                            : 'English';
                        ref.read(languageProvider.notifier).setLanguage(next);
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(
                        Icons.cloud_done_outlined,
                        color: colors.charcoal,
                      ),
                      title: Text(
                        SupabaseAuthService.isCloudAvailable
                            ? (user != null ? 'Sign Out' : 'Sign In (Cloud Sync)')
                            : 'Storage Mode',
                      ),
                      subtitle: Text(
                        SupabaseAuthService.isCloudAvailable
                            ? (user?.email ?? 'Optional self-hosted sync')
                            : 'Local-first · Private on device',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.mutedBrown,
                        ),
                      ),
                      trailing: SupabaseAuthService.isCloudAvailable
                          ? Icon(
                              user != null
                                  ? Icons.logout_rounded
                                  : Icons.login_rounded,
                              color: colors.coral,
                              size: 20,
                            )
                          : Icon(
                              Icons.lock_outline_rounded,
                              color: colors.teal,
                              size: 18,
                            ),
                      onTap: SupabaseAuthService.isCloudAvailable
                          ? () async {
                              if (user != null) {
                                await SupabaseAuthService.signOut();
                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                }
                              } else {
                                Navigator.of(context).pop();
                                context.push('/login');
                              }
                            }
                          : null,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(
                        Icons.info_outline_rounded,
                        color: colors.charcoal,
                      ),
                      title: const Text('About Bookaind'),
                      subtitle: Text(
                        'v1.0.0 · Open-Source Nusantara Heritage',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.mutedBrown,
                        ),
                      ),
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationName: 'Bookaind',
                          applicationVersion: '1.0.0',
                          applicationLegalese:
                              'Open-Source Nusantara Cultural Heritage & Discovery Guide.',
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
