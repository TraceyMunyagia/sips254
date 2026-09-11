import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sips254/features/profile/presentation/profile_screen.dart';
import 'package:sips254/features/recipes/presentation/create_recipe_screen.dart';
import 'package:sips254/features/recipes/presentation/recipe_detail_screen.dart';
import '../../features/auth/presentation/sign_in_screen.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../features/home/presentation/home_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = authState.value?.session != null;
      final isAuthRoute = state.matchedLocation == '/sign-in';

      if (!isLoggedIn && !isAuthRoute) return '/sign-in';
      if (isLoggedIn && isAuthRoute) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/sign-in', builder: (context, state) => const SignInScreen()),
      GoRoute(path: '/', builder: (context, state) => const HomeShell()),
      GoRoute(
  path: '/recipe/:id',
  builder: (context, state) =>
      RecipeDetailScreen(cocktailId: state.pathParameters['id']!),
),
GoRoute(
  path: '/create-recipe',
  builder: (context, state) => const CreateRecipeScreen(),
),
GoRoute(
  path: '/profile/:userId',
  builder: (context, state) => ProfileScreen(userId: state.pathParameters['userId']!),
),
    ],
  );
});