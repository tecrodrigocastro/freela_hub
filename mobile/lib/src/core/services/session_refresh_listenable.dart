import 'dart:async';

import 'package:base_clean_arch_bloc/src/core/services/session_service.dart';
import 'package:flutter/foundation.dart';

/// Faz o go_router reavaliar o `redirect` quando a sessão expira (401).
class SessionRefreshListenable extends ChangeNotifier {
  late final StreamSubscription<void> _subscription;

  SessionRefreshListenable(SessionService sessionService) {
    _subscription = sessionService.onSessionExpired.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
