import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sips254/data/models/cocktail_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_providers.dart';
import '../../home/presentation/widgets/recipe_card.dart';
import '../providers/profile_providers.dart';
import 'widgets/follow_button.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final String? userId; // null = viewing own profile

  const ProfileScreen({super.key, this.userId});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final targetUserId = widget.userId ?? currentUser?.id;

    if (targetUserId == null) {
      return const Scaffold(body: Center(child: Text('Not signed in')));
    }

    final profileAsync = ref.watch(profileDataProvider(targetUserId));
    final followersAsync = ref.watch(followerCountProvider(targetUserId));
    final followingAsync = ref.watch(followingCountProvider(targetUserId));

    return Scaffold(
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (profile) {
          if (profile == null) return const Center(child: Text('Profile not found'));

          return Column(
            children: [
              const SizedBox(height: 40),
              CircleAvatar(
                radius: 44,
                backgroundColor: AppColors.surfaceElevated,
                backgroundImage:
                    profile['avatar_url'] != null ? NetworkImage(profile['avatar_url']) : null,
                child: profile['avatar_url'] == null
                    ? const Icon(Icons.person, size: 44, color: AppColors.textSecondary)
                    : null,
              ),
              const SizedBox(height: 12),
              Text(profile['username'] ?? '',
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
              if (profile['bio'] != null) ...[
                const SizedBox(height: 4),
                Text(profile['bio'], style: const TextStyle(color: AppColors.textSecondary)),
              ],
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  followersAsync.when(
                    data: (count) => _StatColumn(label: 'Followers', count: count),
                    loading: () => const SizedBox.shrink(),
                    error: (_, _) => const SizedBox.shrink(),
                  ),
                  const SizedBox(width: 32),
                  followingAsync.when(
                    data: (count) => _StatColumn(label: 'Following', count: count),
                    loading: () => const SizedBox.shrink(),
                    error: (_, _) => const SizedBox.shrink(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (currentUser != null)
                FollowButton(currentUserId: currentUser.id, targetUserId: targetUserId),
              const SizedBox(height: 16),
              TabBar(
                controller: _tabController,
                indicatorColor: AppColors.premiumAccent,
                labelColor: AppColors.premiumAccent,
                unselectedLabelColor: AppColors.textSecondary,
                tabs: const [
                  Tab(text: 'Created'),
                  Tab(text: 'Saved'),
                  Tab(text: 'Liked'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _CocktailGrid(provider: createdCocktailsProvider(targetUserId)),
                    _CocktailGrid(provider: savedCocktailsProvider(targetUserId)),
                    _CocktailGrid(provider: likedCocktailsProvider(targetUserId)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final int count;

  const _StatColumn({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$count',
            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }
}

class _CocktailGrid extends ConsumerWidget {
  final FutureProvider<List<Cocktail>> provider;

  const _CocktailGrid({required this.provider});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cocktailsAsync = ref.watch(provider);

    return cocktailsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (cocktails) {
        if (cocktails.isEmpty) {
          return const Center(
              child: Text('Nothing here yet', style: TextStyle(color: AppColors.textSecondary)));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: cocktails.length,
          itemBuilder: (context, index) => RecipeCard(cocktail: cocktails[index]),
        );
      },
    );
  }
}