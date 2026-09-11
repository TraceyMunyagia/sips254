import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/bartender_repository.dart';

final bartenderRepositoryProvider = Provider<BartenderRepository>((ref) => BartenderRepository());