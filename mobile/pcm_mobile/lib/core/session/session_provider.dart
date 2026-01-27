import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/api_service.dart';
import 'session.dart';

final sessionProvider = AsyncNotifierProvider<SessionNotifier, SessionUser?>(SessionNotifier.new);

class SessionNotifier extends AsyncNotifier<SessionUser?> {
  @override
  Future<SessionUser?> build() async {
    final me = await ApiService.me();
    if (me == null) return null;
    return SessionUser.fromMeJson(me);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final me = await ApiService.me();
      if (me == null) return null;
      return SessionUser.fromMeJson(me);
    });
  }
}


