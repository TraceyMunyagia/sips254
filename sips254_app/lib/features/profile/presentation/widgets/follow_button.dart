import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../comments/providers/social_providers.dart';

class FollowButton extends ConsumerStatefulWidget {
  final String currentUserId;
  final String targetUserId;

  const FollowButton({super.key, required this.currentUserId, required this.targetUserId});

  @override
  ConsumerState<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends ConsumerState<FollowButton> {
  bool? _isFollowing;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await ref
        .read(socialRepositoryProvider)
        .isFollowing(widget.currentUserId, widget.targetUserId);
    if (mounted) setState(() => _isFollowing = result);
  }

  Future<void> _toggle() async {
    if (_isFollowing == null) return;
    await ref.read(socialRepositoryProvider).toggleFollow(
          widget.currentUserId,
          widget.targetUserId,
          _isFollowing!,
        );
    setState(() => _isFollowing = !_isFollowing!);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.currentUserId == widget.targetUserId) return const SizedBox.shrink();
    if (_isFollowing == null) return const SizedBox(height: 36);

    return ElevatedButton(
      onPressed: _toggle,
      style: ElevatedButton.styleFrom(
        backgroundColor: _isFollowing! ? AppColors.surfaceElevated : AppColors.primaryAction,
      ),
      child: Text(_isFollowing! ? 'Following' : 'Follow'),
    );
  }
}