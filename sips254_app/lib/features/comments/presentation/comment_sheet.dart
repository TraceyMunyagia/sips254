import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/social_providers.dart';

class CommentSheet extends ConsumerStatefulWidget {
  final String cocktailId;

  const CommentSheet({super.key, required this.cocktailId});

  @override
  ConsumerState<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends ConsumerState<CommentSheet> {
  final _controller = TextEditingController();

  Future<void> _post() async {
    final user = ref.read(currentUserProvider);
    if (user == null || _controller.text.trim().isEmpty) return;

    await ref.read(socialRepositoryProvider).addComment(widget.cocktailId, user.id, _controller.text.trim());
    _controller.clear();
    ref.invalidate(commentsProvider(widget.cocktailId));
  }

  @override
  Widget build(BuildContext context) {
    final commentsAsync = ref.watch(commentsProvider(widget.cocktailId));

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Comments', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: commentsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (comments) => ListView.builder(
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  final c = comments[index];
                  final profile = c['profiles'] as Map<String, dynamic>?;
                  return ListTile(
                    title: Text(profile?['username'] ?? 'User',
                        style: const TextStyle(color: AppColors.premiumAccent, fontSize: 13)),
                    subtitle: Text(c['content'] as String,
                        style: const TextStyle(color: AppColors.textPrimary)),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: 'Add a comment...'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: AppColors.primaryAction),
                  onPressed: _post,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}