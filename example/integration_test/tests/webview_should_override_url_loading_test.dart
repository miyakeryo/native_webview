import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:native_webview/native_webview.dart';
import 'package:native_webview_example/integration_test/webview_event.dart';

import '../utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWebView('Return allow', (tester, context) async {
    await tester.pumpFrames(
      WebView(
        initialUrl: 'about:blank',
        onWebViewCreated: context.onWebViewCreated,
        shouldOverrideUrlLoading: context.shouldOverrideUrlLoading,
        onPageStarted: context.onPageStarted,
        onWebResourceError: context.onWebResourceError,
        onProgressChanged: context.onProgressChanged,
        onPageFinished: context.onPageFinished,
      ),
    );

    final controller = await context.webviewController.future;
    await controller.evaluateJavascript(
      "location.href = 'https://flutter.dev/'",
    );

    await sleep();

    expect(
      context.loadingRequestEvents.length,
      anyOf(
        greaterThanOrEqualTo(0),
        greaterThanOrEqualTo(1),
      ),
    );

    expect(context.webResourceErrorEvents.length, 0);

    expect(context.pageStartedEvents, [
      WebViewEvent.pageStarted(
        "about:blank",
        "about:blank",
        false,
        false,
      ),
      WebViewEvent.pageStarted(
        "https://flutter.dev/",
        "https://flutter.dev/",
        Platform.isAndroid ? true : false,
        false,
      ),
    ]);

    expect(
        context.pageFinishedEvents,
        anyOf(
          equals([
            WebViewEvent.pageFinished(
              "about:blank",
              "about:blank",
              false,
              false,
            ),
            WebViewEvent.pageFinished(
              "https://flutter.dev/",
              "https://flutter.dev/",
              Platform.isAndroid ? true : false,
              false,
            ),
          ]),
          equals([
            // PageFinished of flutter.dev may come twice on Android.
            WebViewEvent.pageFinished(
              "about:blank",
              "about:blank",
              false,
              false,
            ),
            WebViewEvent.pageFinished(
              "https://flutter.dev/",
              "https://flutter.dev/",
              Platform.isAndroid ? true : false,
              false,
            ),
            WebViewEvent.pageFinished(
              "https://flutter.dev/",
              "https://flutter.dev/",
              Platform.isAndroid ? true : false,
              false,
            ),
          ]),
        ));
  });

  testWebView('Return cancel', (tester, context) async {
    await tester.pumpFrames(
      WebView(
        initialUrl: 'about:blank',
        onWebViewCreated: context.onWebViewCreated,
        onWebResourceError: context.onWebResourceError,
        onProgressChanged: context.onProgressChanged,
        onPageStarted: context.onPageStarted,
        onPageFinished: context.onPageFinished,
        shouldOverrideUrlLoading: (controller, request) async {
          await context.shouldOverrideUrlLoading(controller, request);
          return ShouldOverrideUrlLoadingAction.cancel;
        },
      ),
    );

    final controller = await context.webviewController.future;
    await controller.evaluateJavascript(
      "location.href = 'https://flutter.dev/'",
    );

    await sleep();

    expect(context.loadingRequestEvents.map((e) => e.request.url), [
      "https://flutter.dev/",
    ]);

    expect(context.webResourceErrorEvents.length, 0);

    expect(context.pageStartedEvents, [
      WebViewEvent.pageStarted(
        "about:blank",
        "about:blank",
        false,
        false,
      ),
    ]);
    expect(context.pageFinishedEvents, [
      WebViewEvent.pageFinished(
        "about:blank",
        "about:blank",
        false,
        false,
      ),
    ]);
  });

  testWebView('loadUrl execute shouldOverrideUrlLoading',
      (tester, context) async {
    await tester.pumpFrames(
      WebView(
        initialUrl: 'about:blank',
        onWebViewCreated: context.onWebViewCreated,
        onWebResourceError: context.onWebResourceError,
        onProgressChanged: context.onProgressChanged,
        onPageStarted: context.onPageStarted,
        onPageFinished: context.onPageFinished,
        shouldOverrideUrlLoading: (controller, request) async {
          await context.shouldOverrideUrlLoading(controller, request);
          return ShouldOverrideUrlLoadingAction.cancel;
        },
      ),
    );

    final controller = await context.webviewController.future;
    await controller.loadUrl("https://flutter.dev/");

    await sleep();

    expect(context.loadingRequestEvents.map((e) => e.request.url), [
      if (Platform.isIOS) "https://flutter.dev/",
    ]);

    expect(context.webResourceErrorEvents.length, 0);
  });
}
