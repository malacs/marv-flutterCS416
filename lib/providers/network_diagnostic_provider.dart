import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Categories for network connection operational tiers.
enum NetworkHealthTier {
  excellent, // > 10 Mbps
  fair,      // 2 - 10 Mbps
  poor,      // < 2 Mbps
  degraded,  // Heavy packet loss / extreme latency / request failure
}

/// Detailed status of the multi-step diagnostic sequence.
enum DiagnosticStatus {
  idle,
  measuringIdlePing,
  measuringDownload,
  measuringUpload,
  completed,
  error,
}

class NetworkDiagnosticProvider extends ChangeNotifier {
  // Test Metrics
  double _idlePingMs = 0.0;
  double _downloadMbps = 0.0;
  double _downloadPingMs = 0.0;
  double _uploadMbps = 0.0;
  double _uploadPingMs = 0.0;
  double _packetLossPercent = 0.0;
  DateTime? _lastTestedTime;

  bool _isOffline = false;
  bool _hasMeasured = false;

  DiagnosticStatus _status = DiagnosticStatus.idle;
  String _statusMessage = 'Diagnostic tool ready';
  NetworkHealthTier _calculatedTier = NetworkHealthTier.excellent;

  // Periodic Auto-Test Configuration
  bool _isAutoRefreshEnabled = false;
  Timer? _periodicTimer;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  // Getters
  bool get isOffline => _isOffline;
  bool get hasMeasured => _hasMeasured;
  double get idlePingMs => _idlePingMs;
  double get downloadMbps => _downloadMbps;
  double get downloadPingMs => _downloadPingMs;
  double get uploadMbps => _uploadMbps;
  double get uploadPingMs => _uploadPingMs;
  double get packetLossPercent => _packetLossPercent;
  DateTime? get lastTestedTime => _lastTestedTime;

  DiagnosticStatus get status => _status;
  String get statusMessage => _statusMessage;

  bool get isAutoRefreshEnabled => _isAutoRefreshEnabled;

  /// Effective health tier calculated from actual diagnostic metrics.
  NetworkHealthTier get activeTier {
    return _calculatedTier;
  }

  /// Title string for tier badge
  String get tierName {
    if (_isOffline) {
      return 'Offline';
    }
    switch (activeTier) {
      case NetworkHealthTier.excellent:
        return 'Excellent';
      case NetworkHealthTier.fair:
        return 'Fair';
      case NetworkHealthTier.poor:
        return 'Poor';
      case NetworkHealthTier.degraded:
        return 'Degraded';
    }
  }

  /// Description of the current operational tier
  String get tierDescription {
    if (_isOffline) {
      return 'No active internet connection. Please connect to Wi-Fi or Mobile Data.';
    }
    switch (activeTier) {
      case NetworkHealthTier.excellent:
        return 'High bandwidth (>10 Mbps) & normal latency. Richer high-quality content enabled.';
      case NetworkHealthTier.fair:
        return 'Moderate bandwidth (2–10 Mbps). Standard reduced content enabled.';
      case NetworkHealthTier.poor:
        return 'Low bandwidth (<2 Mbps). Lightweight placeholders active.';
      case NetworkHealthTier.degraded:
        return 'Heavy packet loss or high latency detected. Minimal text-focused fallback active.';
    }
  }

  NetworkDiagnosticProvider() {
    _initConnectivityListener();
    // Perform initial real diagnostic test upon initialization
    runFullDiagnostics();
  }

  /// Listen for connectivity changes (Wi-Fi, Mobile Hotspot, Cellular Data, Offline)
  void _initConnectivityListener() {
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((results) {
      final disconnected =
          results.isEmpty || results.every((r) => r == ConnectivityResult.none);

      if (disconnected) {
        _setOfflineState('No network connection detected (Offline)');
      } else {
        if (_isOffline) {
          _isOffline = false;
          runFullDiagnostics();
        }
      }
    });
  }

  /// Resets all metrics and sets the provider to an offline state
  void _setOfflineState(String reason) {
    _isOffline = true;
    _hasMeasured = false;
    _idlePingMs = 0.0;
    _downloadMbps = 0.0;
    _downloadPingMs = 0.0;
    _uploadMbps = 0.0;
    _uploadPingMs = 0.0;
    _packetLossPercent = 100.0;
    _calculatedTier = NetworkHealthTier.degraded;
    _status = DiagnosticStatus.error;
    _statusMessage = reason;
    _lastTestedTime = DateTime.now();
    notifyListeners();
  }

  /// Toggle background periodic network testing (every 30 seconds)
  void toggleAutoRefresh(bool enable) {
    _isAutoRefreshEnabled = enable;
    _periodicTimer?.cancel();
    _periodicTimer = null;

    if (_isAutoRefreshEnabled) {
      // Execute immediately when enabled if not currently measuring
      if (_status != DiagnosticStatus.measuringIdlePing &&
          _status != DiagnosticStatus.measuringDownload &&
          _status != DiagnosticStatus.measuringUpload) {
        runFullDiagnostics();
      }

      // Schedule periodic diagnostic cycle every 30 seconds
      _periodicTimer = Timer.periodic(const Duration(seconds: 30), (_) {
        if (_status != DiagnosticStatus.measuringIdlePing &&
            _status != DiagnosticStatus.measuringDownload &&
            _status != DiagnosticStatus.measuringUpload) {
          runFullDiagnostics();
        }
      });
    }
    notifyListeners();
  }

  /// Multi-step real diagnostic sequence supporting Wi-Fi and Mobile Data/Hotspot
  Future<void> runFullDiagnostics() async {
    // 0. Pre-flight connectivity check
    try {
      final connResults = await Connectivity().checkConnectivity();
      if (connResults.isEmpty ||
          connResults.every((r) => r == ConnectivityResult.none)) {
        _setOfflineState('No internet connection. Network is offline.');
        return;
      }
    } catch (_) {
      // If connectivity check fails, continue to HTTP probes
    }

    _status = DiagnosticStatus.measuringIdlePing;
    _statusMessage = 'Step 1/3: Measuring baseline idle ping...';
    notifyListeners();

    try {
      // ----------------------------------------------------
      // Step 1: Measure Baseline Idle Ping & Packet Loss
      // ----------------------------------------------------
      final pingResult = await _measurePingLatency(count: 3);
      _idlePingMs = pingResult['pingMs'] ?? 0.0;
      final pingFailedCount = pingResult['failedCount']?.toInt() ?? 0;
      final pingTotalCount = pingResult['totalCount']?.toInt() ?? 3;

      if (_idlePingMs < 0 || pingFailedCount == pingTotalCount) {
        _setOfflineState('Ping targets unreachable. Check internet connection.');
        return;
      }

      // ----------------------------------------------------
      // Step 2: Compute Real Download Bandwidth & Loaded Ping
      // ----------------------------------------------------
      _status = DiagnosticStatus.measuringDownload;
      _statusMessage = 'Step 2/3: Computing download bandwidth & loaded ping...';
      notifyListeners();

      final downloadResults = await _measureDownloadBandwidthAndPing();
      _downloadMbps = downloadResults['speedMbps'] ?? 0.0;
      _downloadPingMs = downloadResults['loadedPingMs'] ?? _idlePingMs;
      final downloadSuccess = (downloadResults['success'] ?? 0.0) == 1.0;

      // ----------------------------------------------------
      // Step 3: Compute Real Upload Bandwidth & Loaded Ping
      // ----------------------------------------------------
      _status = DiagnosticStatus.measuringUpload;
      _statusMessage = 'Step 3/3: Calculating upload bandwidth & upload ping...';
      notifyListeners();

      final uploadResults = await _measureUploadBandwidthAndPing();
      _uploadMbps = uploadResults['speedMbps'] ?? 0.0;
      _uploadPingMs = uploadResults['loadedPingMs'] ?? _idlePingMs;
      final uploadSuccess = (uploadResults['success'] ?? 0.0) == 1.0;

      // Calculate total Packet Loss percentage across all probes
      int totalProbes = pingTotalCount + 2; // pings + download probe + upload probe
      int failedProbes =
          pingFailedCount + (downloadSuccess ? 0 : 1) + (uploadSuccess ? 0 : 1);
      _packetLossPercent = (failedProbes / totalProbes) * 100.0;

      _lastTestedTime = DateTime.now();
      _isOffline = false;
      _hasMeasured = true;

      // Evaluate real network tier based on actual measured thresholds
      _evaluateThresholdLogic();

      _status = DiagnosticStatus.completed;
      _statusMessage = 'Diagnostics complete! Tier: $tierName';
    } catch (e) {
      _handleDiagnosticFailure('Diagnostic Error: ${e.toString()}');
    } finally {
      notifyListeners();
    }
  }

  /// Threshold Logic: Categorizes network operational tiers based on real metrics
  void _evaluateThresholdLogic() {
    if (_isOffline) {
      _calculatedTier = NetworkHealthTier.degraded;
      return;
    }

    if (_packetLossPercent >= 50.0 ||
        _idlePingMs > 1500.0 ||
        _downloadPingMs > 1500.0 ||
        _uploadPingMs > 1500.0 ||
        _idlePingMs < 0) {
      _calculatedTier = NetworkHealthTier.degraded;
    } else if (_downloadMbps >= 10.0) {
      _calculatedTier = NetworkHealthTier.excellent;
    } else if (_downloadMbps >= 2.0) {
      _calculatedTier = NetworkHealthTier.fair;
    } else {
      _calculatedTier = NetworkHealthTier.poor;
    }
  }

  void _handleDiagnosticFailure(String reason) {
    _setOfflineState(reason);
  }

  /// Measure round-trip ping time (in milliseconds) using ultra-fast, SSL-valid CDN endpoints
  Future<Map<String, double>> _measurePingLatency({int count = 3}) async {
    final pingTargets = [
      Uri.parse('https://www.google.com/generate_204'),
      Uri.parse('https://connectivitycheck.gstatic.com/generate_204'),
      Uri.parse('https://www.cloudflare.com/cdn-cgi/trace'),
      Uri.parse('https://1.1.1.1/cdn-cgi/trace'),
    ];

    double totalLatency = 0.0;
    int successCount = 0;
    int failedCount = 0;

    for (int i = 0; i < count; i++) {
      final target = pingTargets[i % pingTargets.length];
      final stopwatch = Stopwatch()..start();
      try {
        final response =
            await http.get(target).timeout(const Duration(seconds: 4));
        stopwatch.stop();
        if (response.statusCode >= 200 && response.statusCode < 400) {
          totalLatency += stopwatch.elapsedMilliseconds;
          successCount++;
        } else {
          failedCount++;
        }
      } catch (_) {
        stopwatch.stop();
        failedCount++;
      }
    }

    if (successCount == 0) {
      return {
        'pingMs': -1.0,
        'successCount': 0.0,
        'failedCount': failedCount.toDouble(),
        'totalCount': count.toDouble(),
      };
    }

    return {
      'pingMs': totalLatency / successCount,
      'successCount': successCount.toDouble(),
      'failedCount': failedCount.toDouble(),
      'totalCount': count.toDouble(),
    };
  }

  /// Measure Download speed (Mbps) and concurrent download ping using real HTTP requests
  Future<Map<String, double>> _measureDownloadBandwidthAndPing() async {
    final pingFuture = _measurePingLatency(count: 1);

    // Reliable download endpoints on global CDNs
    final downloadTargets = [
      Uri.parse('https://speed.cloudflare.com/__down?bytes=200000'),
      Uri.parse('https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.3/css/bootstrap.min.css'),
      Uri.parse('https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js'),
    ];

    for (final target in downloadTargets) {
      try {
        final stopwatch = Stopwatch()..start();
        final response =
            await http.get(target).timeout(const Duration(seconds: 7));
        stopwatch.stop();

        final loadedPingResult = await pingFuture;
        final loadedPingMs = loadedPingResult['pingMs'] ?? _idlePingMs;

        if (response.statusCode == 200 &&
            stopwatch.elapsedMilliseconds > 0 &&
            response.bodyBytes.isNotEmpty) {
          final bytesDownloaded = response.bodyBytes.length;
          final seconds = stopwatch.elapsedMilliseconds / 1000.0;
          final bitsDownloaded = bytesDownloaded * 8;
          final speedMbps = (bitsDownloaded / (1024 * 1024)) / seconds;

          return {
            'speedMbps': speedMbps,
            'loadedPingMs': loadedPingMs > 0 ? loadedPingMs : _idlePingMs,
            'success': 1.0,
          };
        }
      } catch (_) {}
    }

    final fallbackPing = await pingFuture;
    return {
      'speedMbps': 0.0,
      'loadedPingMs': fallbackPing['pingMs'] ?? _idlePingMs,
      'success': 0.0,
    };
  }

  /// Measure Upload speed (Mbps) and concurrent upload ping using real HTTP requests
  Future<Map<String, double>> _measureUploadBandwidthAndPing() async {
    final pingFuture = _measurePingLatency(count: 1);

    // Create a 64KB byte payload to test upload throughput
    final payload = List<int>.generate(65536, (i) => i % 256);

    final uploadTargets = [
      Uri.parse('https://speed.cloudflare.com/__up'),
      Uri.parse('https://postman-echo.com/post'),
      Uri.parse('https://httpbin.org/post'),
    ];

    for (final target in uploadTargets) {
      try {
        final stopwatch = Stopwatch()..start();
        final response = await http
            .post(target, body: payload)
            .timeout(const Duration(seconds: 7));
        stopwatch.stop();

        final loadedPingResult = await pingFuture;
        final loadedPingMs = loadedPingResult['pingMs'] ?? _idlePingMs;

        if ((response.statusCode == 200 || response.statusCode == 204) &&
            stopwatch.elapsedMilliseconds > 0) {
          final bytesUploaded = payload.length;
          final seconds = stopwatch.elapsedMilliseconds / 1000.0;
          final bitsUploaded = bytesUploaded * 8;
          final speedMbps = (bitsUploaded / (1024 * 1024)) / seconds;

          return {
            'speedMbps': speedMbps,
            'loadedPingMs': loadedPingMs > 0 ? loadedPingMs : _idlePingMs,
            'success': 1.0,
          };
        }
      } catch (_) {}
    }

    final fallbackPing = await pingFuture;
    return {
      'speedMbps': 0.0,
      'loadedPingMs': fallbackPing['pingMs'] ?? _idlePingMs,
      'success': 0.0,
    };
  }

  @override
  void dispose() {
    _periodicTimer?.cancel();
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}
