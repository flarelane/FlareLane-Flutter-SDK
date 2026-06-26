import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// Library-named adapter — same `FlareLaneJavascriptInterface` class name as
// native Android/iOS, with members shaped to flutter_inappwebview's slot
// names.
import 'package:flarelane_flutter/adapters/flutter_inappwebview.dart';

/// Demo wiring the `FlareLaneJavascriptInterface` adapter into
/// `flutter_inappwebview` using the coexist pattern.
class WebViewBridgeInAppWebViewDemo extends StatefulWidget {
  const WebViewBridgeInAppWebViewDemo({Key? key, required this.projectId})
      : super(key: key);

  final String projectId;

  @override
  State<WebViewBridgeInAppWebViewDemo> createState() =>
      _WebViewBridgeInAppWebViewDemoState();
}

class _WebViewBridgeInAppWebViewDemoState
    extends State<WebViewBridgeInAppWebViewDemo> {
  String? _html;

  @override
  void initState() {
    super.initState();
    _loadAsset();
  }

  Future<void> _loadAsset() async {
    String html =
        await rootBundle.loadString('assets/webview_websdk_test.html');
    // The async asset load can resolve after this State is disposed (e.g. the
    // user pops the route before the bundle finishes reading). Guard the
    // setState so we don't touch an unmounted element.
    if (!mounted) return;
    html = html
        .replaceAll('%PROJECT_ID%', widget.projectId)
        .replaceAll('%LIBRARY%', 'flutter_inappwebview');
    setState(() => _html = html);
  }

  @override
  Widget build(BuildContext context) {
    if (_html == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            InAppWebView(
              initialData: InAppWebViewInitialData(
                data: _html!,
                baseUrl: Uri.parse('https://localhost'),
              ),
              // additive slot — adapter UserScripts sit alongside any
              // customer-owned scripts. Spread to merge:
              //   initialUserScripts: UnmodifiableListView<UserScript>([
              //     ...FlareLaneJavascriptInterface.initialUserScripts,
              //     ...myUserScripts,
              //   ]),
              initialUserScripts:
                  FlareLaneJavascriptInterface.initialUserScripts,
              initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(javaScriptEnabled: true),
              ),
              // single-valued slot — customer composes inside onWebViewCreated.
              onWebViewCreated: (controller) {
                controller.addJavaScriptHandler(
                  handlerName: FlareLaneJavascriptInterface.BRIDGE_NAME,
                  callback: FlareLaneJavascriptInterface.handlerCallback(
                      controller),
                );
                // customer's other handler registrations / init logic goes here.
              },
            ),
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
