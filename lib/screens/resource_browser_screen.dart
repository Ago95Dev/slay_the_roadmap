import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';

class ResourceBrowserScreen extends StatefulWidget {
  final String url;
  final String resourceTitle;
  final String topicId;
  final int resourceIndex;

  const ResourceBrowserScreen({
    super.key,
    required this.url,
    required this.resourceTitle,
    required this.topicId,
    required this.resourceIndex,
  });

  @override
  State<ResourceBrowserScreen> createState() => _ResourceBrowserScreenState();
}

/// WebView (webview_flutter) è disponibile solo su Android/iOS/macOS/web.
/// Su Linux/Windows desktop non esiste implementazione di piattaforma:
/// NON istanziare WebViewController (l'assertion su WebViewPlatform
/// non è catturabile con try/catch perché è un Error, non Exception).
/// Vedi: schermata risorsa "Variables & Types" (dart.dev) su Linux.
bool isResourceWebViewSupported() {
  if (kIsWeb) return true;
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
    case TargetPlatform.iOS:
    case TargetPlatform.macOS:
      return true;
    case TargetPlatform.linux:
    case TargetPlatform.windows:
    case TargetPlatform.fuchsia:
      return false;
  }
}

class _ResourceBrowserScreenState extends State<ResourceBrowserScreen> {
  WebViewController? _controller;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  int _secondsViewed = 0;
  Timer? _viewTimer;
  static const int _minSecondsForReward = 10;

  bool _externalBrowserFallback = false;

  Future<void> _openInExternalBrowser() async {
    final uri = Uri.tryParse(widget.url);
    if (uri == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('URL non valido')),
        );
      }
      return;
    }
    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossibile aprire il browser')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossibile aprire il browser: $e')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();

    if (!isResourceWebViewSupported()) {
      // Fallback desktop: nessun WebView, solo timer + pannello esterno.
      _externalBrowserFallback = true;
      _isLoading = false;
    } else {
      // Initialize WebView controller with error handling
      try {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              if (mounted) {
                setState(() {
                  _isLoading = true;
                });
              }
            },
            onPageFinished: (String url) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
              }
            },
            onWebResourceError: (WebResourceError error) {
              if (mounted) {
                setState(() {
                  _hasError = true;
                  _errorMessage = error.description;
                });
              }
            },
          ),
        )
        ..loadRequest(Uri.parse(widget.url));
      } catch (e) {
        _hasError = true;
        _errorMessage = 'WebView not supported on this platform. Error: $e';
      }
    }

    // Start tracking viewing time
    _viewTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _secondsViewed++;
        });
      }
    });
  }

  @override
  void dispose() {
    _viewTimer?.cancel();
    super.dispose();
  }

  void _onBack() {
    // Check if user viewed long enough for reward
    final shouldShowReward = _secondsViewed >= _minSecondsForReward;
    
    Navigator.pop(context, {
      'viewedSeconds': _secondsViewed,
      'qualifiesForReward': shouldShowReward,
      'topicId': widget.topicId,
      'resourceIndex': widget.resourceIndex,
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _onBack();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.resourceTitle,
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                'Time: ${_formatTime(_secondsViewed)}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _onBack,
          ),
          actions: [
            if (_secondsViewed >= _minSecondsForReward)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Chip(
                  avatar: const Icon(Icons.check_circle, color: Colors.green, size: 16),
                  label: const Text(
                    'Reward Ready!',
                    style: TextStyle(fontSize: 12),
                  ),
                  backgroundColor: Colors.green.shade50,
                ),
              ),
            if (!_externalBrowserFallback)
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  _controller?.reload();
                },
              ),
          ],
        ),
        body: _externalBrowserFallback
            ? Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.open_in_browser,
                        size: 64,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        widget.resourceTitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'La visualizzazione integrata non è disponibile su Linux desktop. Apri la risorsa nel browser esterno.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _openInExternalBrowser,
                        icon: const Icon(Icons.open_in_browser),
                        label: const Text('Apri nel browser'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SelectableText(
                        widget.url,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'You can still earn the reward!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Simulate viewing time to auto-qualify for reward
                          setState(() {
                            _secondsViewed = _minSecondsForReward;
                          });
                          Future.delayed(const Duration(milliseconds: 500), () {
                            if (mounted) _onBack();
                          });
                        },
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Claim Reward Anyway'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : _hasError
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.browser_not_supported,
                        size: 64,
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Browser Not Available',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'WebView is not supported on this platform (Linux desktop).',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'You can still earn the reward!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Simulate viewing time to auto-qualify for reward
                          setState(() {
                            _secondsViewed = _minSecondsForReward;
                          });
                          Future.delayed(const Duration(milliseconds: 500), () {
                            _onBack();
                          });
                        },
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Claim Reward Anyway'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Resource URL: ${widget.url}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              )
            : Stack(
                children: [
                  if (_controller != null) WebViewWidget(controller: _controller!),
                  if (_isLoading)
                    const Center(
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
        bottomNavigationBar: (_hasError || _externalBrowserFallback)
            ? null
            : Container(
          padding: const EdgeInsets.all(8),
          color: Colors.grey.shade200,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () async {
                  if (_controller != null && await _controller!.canGoBack()) {
                    _controller!.goBack();
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                onPressed: () async {
                  if (_controller != null && await _controller!.canGoForward()) {
                    _controller!.goForward();
                  }
                },
              ),
              Expanded(
                child: Center(
                  child: Text(
                    _secondsViewed < _minSecondsForReward
                        ? 'Read for ${_minSecondsForReward - _secondsViewed}s more to earn reward'
                        : '✓ Reward earned!',
                    style: TextStyle(
                      fontSize: 12,
                      color: _secondsViewed >= _minSecondsForReward 
                          ? Colors.green.shade700 
                          : Colors.grey.shade700,
                      fontWeight: _secondsViewed >= _minSecondsForReward 
                          ? FontWeight.bold 
                          : FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
