import 'package:flutter/services.dart';

class AppLinkLauncher {
  const AppLinkLauncher._();

  static const MethodChannel _channel = MethodChannel('hanjasoook/links');

  static Future<bool> openExternalUrl(String url) async {
    final opened = await _channel.invokeMethod<bool>('openExternalUrl', {
      'url': url,
    });
    return opened ?? false;
  }
}
