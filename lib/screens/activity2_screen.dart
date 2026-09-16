import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../widgets/section_header.dart';

// Queued Request Model
class QueuedRequest {
  final String id;
  final String payload;
  final DateTime createdAt;
  String status; // 'Queued', 'Processing', 'Completed', 'Failed'

  QueuedRequest({
    required this.id,
    required this.payload,
    required this.createdAt,
    this.status = 'Queued',
  });
}

// Activity 2 Screen
class Activity2Screen extends StatefulWidget {
  const Activity2Screen({super.key});

  @override
  State<Activity2Screen> createState() => _Activity2ScreenState();
}

class _Activity2ScreenState extends State<Activity2Screen> {
  // Stream & Connectivity subscription
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  // Active status
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  bool _isSimulatedOffline = false; // Manual toggle for easy testing
  bool _isProcessingQueue = false;
  int _requestCounter = 0;

  // Queues and Logs
  final List<QueuedRequest> _requestQueue = [];
  final List<String> _activityLogs = [];

  @override
  void initState() {
    super.initState();
    _initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  // Initial check on load
  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      _addLog('Error checking initial connectivity: $e');
    }
  }

  // Real-time Stream Callback handler
  void _updateConnectionStatus(List<ConnectivityResult> result) {
    setState(() {
      _connectionStatus = result;
    });

    final currentInterface = _getEffectiveStatusString();
    _addLog('Network Interface Stream Updated: $currentInterface');

    // Graceful Recovery: If internet re-established, process queued requests automatically!
    if (_isOnline() && _requestQueue.any((req) => req.status == 'Queued')) {
      _addLog('⚡ Stable connection detected ($currentInterface)! Triggering Graceful Recovery for queued requests...');
      _processRequestQueue();
    }
  }

  // Returns effective status considering real network + simulated offline toggle
  bool _isOnline() {
    if (_isSimulatedOffline) return false;
    return _connectionStatus.any((r) =>
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.ethernet);
  }

  String _getEffectiveStatusString() {
    if (_isSimulatedOffline) return 'Offline (Simulated Override)';
    if (_connectionStatus.contains(ConnectivityResult.wifi)) return 'Wi-Fi Interface';
    if (_connectionStatus.contains(ConnectivityResult.mobile)) return 'Cellular / Mobile Data';
    if (_connectionStatus.contains(ConnectivityResult.ethernet)) return 'Ethernet Interface';
    return 'Offline (No Connection)';
  }

  void _addLog(String logMessage) {
    final timestamp = DateTime.now().toString().split('.').first.split(' ').last;
    setState(() {
      _activityLogs.insert(0, '[$timestamp] $logMessage');
      if (_activityLogs.length > 20) _activityLogs.removeLast();
    });
  }

  // User initiates a simulated network request
  void _sendNetworkRequest() {
    _requestCounter++;
    final reqId = 'REQ-#$_requestCounter';
    final payload = 'Fetch Large Dataset Batch #$_requestCounter';

    _addLog('Initiating $reqId ($payload)...');

    if (_isOnline()) {
      // Direct processing online
      final newReq = QueuedRequest(
        id: reqId,
        payload: payload,
        createdAt: DateTime.now(),
        status: 'Processing',
      );
      setState(() {
        _requestQueue.insert(0, newReq);
      });
      _simulateOnlineFetch(newReq);
    } else {
      // Connection drop / offline -> Catch error & Queue request instead of crashing!
      final newReq = QueuedRequest(
        id: reqId,
        payload: payload,
        createdAt: DateTime.now(),
        status: 'Queued',
      );
      setState(() {
        _requestQueue.insert(0, newReq);
      });
      _addLog('⚠️ Connection unavailable! Request $reqId safely queued in memory [Graceful Handover Protection].');
    }
  }

  // Simulates online network download latency
  Future<void> _simulateOnlineFetch(QueuedRequest req) async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    if (_isOnline()) {
      setState(() {
        req.status = 'Completed';
      });
      _addLog('✅ Success: ${req.id} completed successfully.');
    } else {
      // Connection dropped mid-request! Catch & Queue
      setState(() {
        req.status = 'Queued';
      });
      _addLog('⚡ Connection lost during processing of ${req.id}! Request moved to Pending Queue.');
    }
  }

  // Graceful Recovery Engine: Automatically flushes and retries queued requests
  Future<void> _processRequestQueue() async {
    if (_isProcessingQueue) return;
    setState(() {
      _isProcessingQueue = true;
    });

    final queuedItems = _requestQueue.where((req) => req.status == 'Queued').toList();
    for (var req in queuedItems) {
      if (!_isOnline()) break; // Connection lost mid-queue processing

      setState(() {
        req.status = 'Processing';
      });
      _addLog('Processing queued request ${req.id}...');
      await Future.delayed(const Duration(milliseconds: 1500));

      if (_isOnline()) {
        setState(() {
          req.status = 'Completed';
        });
        _addLog('✅ Recovered & Completed: ${req.id}');
      } else {
        setState(() {
          req.status = 'Queued';
        });
        _addLog('⚠️ Handover interrupted ${req.id}. Re-queued.');
      }
    }

    setState(() {
      _isProcessingQueue = false;
    });
  }

  void _clearQueue() {
    setState(() {
      _requestQueue.clear();
      _addLog('Request queue cleared.');
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOnline = _isOnline();
    final statusText = _getEffectiveStatusString();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity 2: Network Monitor'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Real-time Status Card
            Card(
              elevation: 0,
              color: isOnline
                  ? theme.colorScheme.primaryContainer.withAlpha(120)
                  : theme.colorScheme.errorContainer.withAlpha(120),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isOnline
                      ? theme.colorScheme.primary.withAlpha(100)
                      : theme.colorScheme.error.withAlpha(100),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isOnline ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isOnline
                            ? (_connectionStatus.contains(ConnectivityResult.wifi)
                                ? Icons.wifi_rounded
                                : Icons.signal_cellular_alt_rounded)
                            : Icons.wifi_off_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Active Network Interface',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            statusText,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isOnline
                                  ? theme.colorScheme.onSurface
                                  : theme.colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 2. Simulated Connection Controls (For Testing on any device)
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: theme.colorScheme.outlineVariant.withAlpha(90),
                ),
              ),
              child: SwitchListTile(
                value: _isSimulatedOffline,
                activeThumbColor: Colors.orange,
                title: const Text(
                  'Simulate Offline Mode (Handover Test)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                subtitle: const Text(
                  'Toggle to simulate connection drop / IP migration and test queue recovery.',
                ),
                onChanged: (val) {
                  setState(() {
                    _isSimulatedOffline = val;
                  });
                  _updateConnectionStatus(_connectionStatus);
                },
              ),
            ),
            const SizedBox(height: 20),

            // 3. Request Action & Queue System Section
            SectionHeader(
              title: 'Request Queuing & Handover System',
              icon: Icons.sync_problem_rounded,
              trailing: Text(
                '${_requestQueue.length} Requests',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _sendNetworkRequest,
                    icon: const Icon(Icons.cloud_upload_outlined),
                    label: const Text('Simulate Fetch Request'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.outlined(
                  onPressed: _clearQueue,
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Clear Queue',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Queued Requests List
            if (_requestQueue.isEmpty)
              Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerLow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Center(
                    child: Text(
                      'No requests sent yet. Tap "Simulate Fetch Request" to begin!',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _requestQueue.length,
                itemBuilder: (context, index) {
                  final req = _requestQueue[index];
                  Color statusColor;
                  IconData statusIcon;

                  switch (req.status) {
                    case 'Completed':
                      statusColor = Colors.green;
                      statusIcon = Icons.check_circle;
                      break;
                    case 'Processing':
                      statusColor = Colors.blue;
                      statusIcon = Icons.hourglass_top_rounded;
                      break;
                    case 'Queued':
                    default:
                      statusColor = Colors.orange;
                      statusIcon = Icons.pause_circle_outline;
                      break;
                  }

                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: theme.colorScheme.outlineVariant.withAlpha(80),
                      ),
                    ),
                    child: ListTile(
                      leading: Icon(statusIcon, color: statusColor),
                      title: Text(
                        '${req.id} — ${req.payload}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      subtitle: Text('Status: ${req.status}'),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withAlpha(30),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          req.status,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 24),

            // 4. Stream Event Log
            const SectionHeader(
              title: 'Stream Event & Recovery Log',
              icon: Icons.history_rounded,
            ),
            Card(
              elevation: 0,
              color: theme.colorScheme.surfaceContainerLowest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: theme.colorScheme.outlineVariant.withAlpha(80),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: _activityLogs.isEmpty
                    ? const Text(
                        'Stream events will appear here in real-time.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _activityLogs
                            .take(8)
                            .map((log) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                                  child: Text(
                                    log,
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 11,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
