import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:webview_flutter/webview_flutter.dart';
// Library-named adapter — same `FlareLaneJavascriptInterface` class name as
// native Android/iOS, with members shaped to webview_flutter's slot names.
import 'package:flarelane_flutter/adapters/webview_flutter.dart';

/// Demo wiring the `FlareLaneJavascriptInterface` adapter into
/// `webview_flutter` using the coexist pattern (the customer's own slot
/// callbacks compose with the adapter's bridge callbacks).
class WebViewBridgeDemo extends StatefulWidget {
  const WebViewBridgeDemo({Key? key, required this.projectId})
      : super(key: key);

  final String projectId;

  @override
  State<WebViewBridgeDemo> createState() => _WebViewBridgeDemoState();
}

class _WebViewBridgeDemoState extends State<WebViewBridgeDemo> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    // The adapter factories read the controller eagerly, so build the
    // controller into a local variable first, wire the bridge into that
    // same instance, then publish it to the `_controller` field.
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
    controller
      // additive slot — bridge channel sits alongside any customer-owned
      // channels added with different names.
      ..addJavaScriptChannel(
        FlareLaneJavascriptInterface.BRIDGE_NAME,
        onMessageReceived:
            FlareLaneJavascriptInterface.onMessageReceived(controller),
      )
      // single-valued slot — compose adapter and customer callbacks. The
      // demo has no extra customer logic, but this is where it would go:
      //   onPageStarted: (url) async {
      //     await FlareLaneJavascriptInterface.onPageStarted(controller)(url);
      //     myExistingOnPageStarted(url);
      //   },
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted:
            FlareLaneJavascriptInterface.onPageStarted(controller),
      ));
    _controller = controller;
    _loadAsset();
  }

  Future<void> _loadAsset() async {
    String html =
        await rootBundle.loadString('assets/webview_websdk_test.html');
    html = html
        .replaceAll('%PROJECT_ID%', widget.projectId)
        .replaceAll('%LIBRARY%', 'webview_flutter');
    await _controller.loadHtmlString(html, baseUrl: 'https://localhost');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            Positioned(
              top: 8,
              right: 12,
              child: _CloseButton(onTap: () => Navigator.of(context).pop()),
            ),
          ],
        ),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({Key? key, required this.onTap}) : super(key: key);
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const SizedBox(
          width: 36,
          height: 36,
          child: Center(
            child: Icon(Icons.close, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }
}
