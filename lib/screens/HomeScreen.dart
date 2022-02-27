import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:icnnsoft/constants/colors.dart';
import 'package:icnnsoft/constants/strings.dart';
import 'package:icnnsoft/helper/debug_print.dart';
//import 'package:webview_flutter/platform_interface.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isloading = true;
  bool loadingError = false;
  int exitPressCount = 0;
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  @override
  void initState() {
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final WebViewController ctrl = await _controller.future;

        if (!await ctrl.canGoBack()) {
          exitPressCount += 1;

          if (exitPressCount < 2) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Double press back to exit.")));
            Future.delayed(Duration(seconds: 1), () => exitPressCount = 0);
          }

          return exitPressCount == 2;
        } else {
          ctrl.goBack();
        }

        return false;
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(children: [
            WebView(
              onPageFinished: _onFinished,
              javascriptMode: JavascriptMode.unrestricted,
              initialUrl: kString.homePageUrl,
              onWebViewCreated: (WebViewController webViewController) {
                devPrint('Webview Created');
                _controller.complete(webViewController);
              },
            ),
            if (loadingError)
              Container(
                color: Colors.white,
                child: Center(
                  child: isloading
                      ? SizedBox()
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Please check your internet connection.'),
                            SizedBox(
                              height: 10.0,
                            ),
                            RefreshButton(_controller.future, () {
                              setState(() {
                                isloading = true;
                              });
                            })
                          ],
                        ),
                ),
              ),
            if (isloading)
              SpinKitThreeBounce(
                color: kColors.primaryColor,
              ),
          ]),
        ),
      ),
    );
  }

  void _onFinished(String url) {
    devPrint('page loaded');
    setState(() {
      isloading = false;
      loadingError = false;
    });
    _controller.future.then((ctrl) async {
      final pageTitel = await ctrl.evaluateJavascript('document.title');
      print('pageTitel');
      print(pageTitel);
      if ((pageTitel == '""') || (pageTitel == '"Web page not available"')) {
        devPrint('Web page not available');
        setState(() {
          loadingError = true;
        });
      }
    });
  }
}

class RefreshButton extends StatelessWidget {
  const RefreshButton(
    this._webViewControllerFuture,
    this.startLoading,
  ) : assert(_webViewControllerFuture != null);

  final Future<WebViewController> _webViewControllerFuture;
  final Function startLoading;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _webViewControllerFuture,
      builder:
          (BuildContext context, AsyncSnapshot<WebViewController> snapshot) {
        final bool webViewReady =
            snapshot.connectionState == ConnectionState.done;

        if (webViewReady) {
          final WebViewController controller = snapshot.data!;
          return ElevatedButton(
            onPressed: !webViewReady
                ? null
                : () {
                    controller.reload();
                    startLoading();
                  },
            child: Text('Refresh'),
          );
        }
        return SizedBox();
      },
    );
  }
}
