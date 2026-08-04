import 'dart:convert';
import 'dart:io';

import 'package:e_commerce/data/models/user_model.dart';
import 'package:flutter/material.dart';

/// Helpers for resolving, cache-busting, and displaying profile avatars.
class ProfileImageUtils {
  ProfileImageUtils._();

  /// Returns a display URL with an optional cache-busting query param.
  ///
  /// Cloudinary often reuses the same URL after re-upload, so Flutter and CDN
  /// caches may keep showing the old bytes unless the URL changes.
  static String? displayUrl(String? url, {int cacheVersion = 0}) {
    final resolved = UserModel.resolveImageUrl(url);
    if (resolved == null) return null;
    if (resolved.startsWith('data:image/')) return resolved;
    if (cacheVersion <= 0) return resolved;

    final uri = Uri.parse(resolved);
    return uri
        .replace(
          queryParameters: {
            ...uri.queryParameters,
            'v': '$cacheVersion',
          },
        )
        .toString();
  }

  static ImageProvider? provider(
    String? url, {
    File? localFile,
    int cacheVersion = 0,
  }) {
    if (localFile != null) return FileImage(localFile);

    final display = displayUrl(url, cacheVersion: cacheVersion);
    if (display == null) return null;

    if (display.startsWith('data:image/')) {
      try {
        return MemoryImage(base64Decode(display.split(',').last));
      } catch (_) {
        return null;
      }
    }

    if (display.startsWith('http://') || display.startsWith('https://')) {
      return NetworkImage(display);
    }

    return null;
  }

  static Future<void> evict(String? url, {int cacheVersion = 0}) async {
    final resolved = UserModel.resolveImageUrl(url);
    if (resolved == null) return;

    final urls = <String>{resolved};
    final busted = displayUrl(url, cacheVersion: cacheVersion);
    if (busted != null) urls.add(busted);

    for (final imageUrl in urls) {
      if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
        await NetworkImage(imageUrl).evict();
      }
    }
  }

  static Widget networkImage({
    required String? url,
    required double width,
    required double height,
    int cacheVersion = 0,
    BoxFit fit = BoxFit.cover,
    Widget? fallback,
  }) {
    final display = displayUrl(url, cacheVersion: cacheVersion);
    if (display == null) {
      return fallback ?? const SizedBox.shrink();
    }

    if (display.startsWith('data:image/')) {
      try {
        final bytes = base64Decode(display.split(',').last);
        return Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (_, __, ___) =>
              fallback ?? const SizedBox.shrink(),
        );
      } catch (_) {
        return fallback ?? const SizedBox.shrink();
      }
    }

    if (display.startsWith('http://') || display.startsWith('https://')) {
      return Image.network(
        display,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) =>
            fallback ?? const SizedBox.shrink(),
      );
    }

    return fallback ?? const SizedBox.shrink();
  }
}
