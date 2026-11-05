import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Toggle this to test both Guest and Signed-In views!
  User? _currentUser;
  late final StreamSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();
    _currentUser = SupabaseAuthService.currentUser;
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      data,
    ) {
      if (mounted) {
        setState(() {
          _currentUser = data.session?.user;
        });
      }
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  final List<String> _culturalInterests = [
    'Batik & Weaving',
    'Ancient Candi',
    'Royal Keraton',
    'Traditional Culinary',
    'Gamelan & Music',
    'Wayang Heritage',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);

    final user = _currentUser;
    final bool isSignedIn = user != null;
    final String fullName = user?.userMetadata?['full_name'] as String? ?? '';
    final String displayName = fullName.isNotEmpty
        ? fullName
        : (user?.email?.split('@').first ?? 'Guest Explorer');

    return Scaffold(
      backgroundColor: colors.cream,
      appBar: AppBar(
        title: Text(
          'Cultural Profile',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (isSignedIn)
            TextButton.icon(
              onPressed: () async {
                await SupabaseAuthService.signOut();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Signed out successfully')),
                  );
                }
              },
              icon: Icon(Icons.logout_rounded, size: 18, color: colors.coral),
              label: Text(
                'Skedaddle Out',
                style: TextStyle(
                  color: colors.coral,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            TextButton.icon(
              onPressed: () => context.push('/login'),
              icon: Icon(Icons.login_rounded, size: 18, color: colors.coral),
              label: Text(
                'Sign In',
                style: TextStyle(
                  color: colors.coral,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        children: [
          // 1. USER IDENTITY CARD
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.warmWhite,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: colors.mutedBrown.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: isSignedIn
                      ? colors.coral
                      : colors.coralSubtle,
                  child: Icon(
                    Icons.person_rounded,
                    size: 40,
                    color: isSignedIn ? Colors.white : colors.coral,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isSignedIn ? displayName : 'Guest Explorer',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isSignedIn
                            ? (user?.email ??
                                  'Cultural Enthusiast • Java Explorer')
                            : 'Browsing public cultural heritage',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.mutedBrown,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. GUEST CALL-TO-ACTION (Only visible if not signed in)
          if (!isSignedIn) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.saffronSubtle,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colors.saffron.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.bookmark_add_outlined,
                        color: colors.charcoal,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Unlock Bookmarks & AI Guide',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.charcoal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to save favorite destinations, build custom heritage trails, and ask the AI assistant.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.charcoal.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.push('/login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.coral,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    child: const Text('Sign In or Register'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // 3. CULTURAL INTERESTS (TAG CLOUD)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.warmWhite,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: colors.mutedBrown.withValues(alpha: 0.15),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cultural Passions',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _culturalInterests.map((interest) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: colors.tealSubtle,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: colors.teal.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Text(
                        interest,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.teal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 4. SAVED HERITAGE PREVIEW (BOOKMARKS)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.warmWhite,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: colors.mutedBrown.withValues(alpha: 0.15),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Saved Heritage',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      isSignedIn ? '3 items' : '0 items',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.mutedBrown,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (!isSignedIn)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.bookmark_border_rounded,
                            size: 40,
                            color: colors.mutedBrown,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No saved items yet.\nSign in to bookmark temples, dances, and foods.',
                            style: theme.textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else ...[
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 48,
                        height: 48,
                        color: colors.coralSubtle,
                        child: Icon(Icons.temple_buddhist, color: colors.coral),
                      ),
                    ),
                    title: const Text(
                      'Borobudur Temple',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text('Central Java • Candi Heritage'),
                    trailing: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 48,
                        height: 48,
                        color: colors.saffronSubtle,
                        child: Icon(Icons.restaurant, color: colors.saffron),
                      ),
                    ),
                    title: const Text(
                      'Gudeg Jogja',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text('DI Yogyakarta • Royal Delicacy'),
                    trailing: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 5. APPLICATION PREFERENCES
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: colors.warmWhite,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: colors.mutedBrown.withValues(alpha: 0.15),
              ),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.language_rounded, color: colors.charcoal),
                  title: const Text('Language'),
                  trailing: Text(
                    'Bahasa Indonesia',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.coral,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    Icons.info_outline_rounded,
                    color: colors.charcoal,
                  ),
                  title: const Text('About Bookaind'),
                  subtitle: const Text('v1.0.0 • Java Heritage Foundation'),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
