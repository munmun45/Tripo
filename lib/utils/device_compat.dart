import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Low-end / India-first device hardening.
class DeviceCompat {
  DeviceCompat._();

  static Future<void> bootstrap() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Cap image memory — helps budget Android phones (2–4 GB RAM).
    final cache = PaintingBinding.instance.imageCache;
    cache.maximumSize = 80;
    cache.maximumSizeBytes = 48 << 20; // ~48 MB

    await SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  /// Clamp huge accessibility text so layouts don't explode on small phones.
  static Widget appBuilder(BuildContext context, Widget? child) {
    final mq = MediaQuery.of(context);
    final width = mq.size.width;
    final isCompact = width < 360;

    return MediaQuery(
      data: mq.copyWith(
        textScaler: mq.textScaler.clamp(
          minScaleFactor: 0.85,
          maxScaleFactor: isCompact ? 1.15 : 1.3,
        ),
      ),
      child: child ?? const SizedBox.shrink(),
    );
  }

  static bool get reduceMotion {
    // Prefer quieter UI on profile/debug low-end paths.
    return kDebugMode == false &&
        WidgetsBinding.instance.platformDispatcher.accessibilityFeatures
            .disableAnimations;
  }
}
