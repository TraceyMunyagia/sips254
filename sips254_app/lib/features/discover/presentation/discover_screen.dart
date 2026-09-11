import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../home/presentation/widgets/recipe_card.dart';
import '../providers/discover_providers.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  static const _categories = ['Trending', 'Kenyan', 'Classic', 'Tropical', 'Mocktail'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = ref.watch(searchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => ref.read(searchQueryProvider.notifier).state = value,
              decoration: InputDecoration(
                hintText: 'Search cocktails, ingredients, spirits...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.surfaceElevated,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: searchQuery.trim().isNotEmpty
          ? _SearchResultsView(query: searchQuery)
          : Column(
              children: [
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicatorColor: AppColors.premiumAccent,
                  labelColor: AppColors.premiumAccent,
                  unselectedLabelColor: AppColors.textSecondary,
                  tabs: _categories.map((c) => Tab(text: c)).toList(),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: _categories
                        .map((c) => c == 'Trending' ? const _TrendingTab() : _CategoryTab(category: c))
                        .toList(),
                  ),
                ),
              ],
            ),
    );
  }
}

class _TrendingTab extends ConsumerWidget {
  const _TrendingTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendingAsync = ref.watch(trendingCocktailsProvider);
    return trendingAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (cocktails) => cocktails.isEmpty
          ? const Center(child: Text('Nothing trending yet', style: TextStyle(color: AppColors.textSecondary)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cocktails.length,
              itemBuilder: (context, index) => RecipeCard(cocktail: cocktails[index]),
            ),
    );
  }
}

class _CategoryTab extends ConsumerWidget {
  final String category;

  const _CategoryTab({required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cocktailsAsync = ref.watch(categoryProvider(category));
    return cocktailsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (cocktails) => cocktails.isEmpty
          ? Center(child: Text('No $category cocktails yet', style: const TextStyle(color: AppColors.textSecondary)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cocktails.length,
              itemBuilder: (context, index) => RecipeCard(cocktail: cocktails[index]),
            ),
    );
  }
}

class _SearchResultsView extends ConsumerWidget {
  final String query;

  const _SearchResultsView({required this.query});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(cocktailSearchResultsProvider);
    return resultsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (cocktails) => cocktails.isEmpty
          ? const Center(child: Text('No matches found', style: TextStyle(color: AppColors.textSecondary)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cocktails.length,
              itemBuilder: (context, index) => RecipeCard(cocktail: cocktails[index]),
            ),
    );
  }
}