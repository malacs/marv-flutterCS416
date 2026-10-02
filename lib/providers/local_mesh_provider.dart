import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/local_mesh_message.dart';
import '../models/local_mesh_peer.dart';

class LocalMeshProvider extends ChangeNotifier {
  static const String serviceId = 'com.example.activity_app.mesh';
  static const int maxHops = 5;

  final String myDeviceId = 'dev_${Random().nextInt(9000) + 1000}';
  String _deviceName = 'Phone_${Random().nextInt(900) + 100}';

  bool _isAdvertising = false;
  bool _isDiscovering = false;
  String _statusMessage = 'Idle. Grant permissions & start discovery.';
  String? _errorMessage;

  final Strategy _strategy = Strategy.P2P_CLUSTER;

  final Map<String, LocalMeshPeer> _peers = {};
  final List<LocalMeshMessage> _messages = [];
  final Set<String> _processedMessageIds = {};

  // Getters
  String get deviceName => _deviceName;
  bool get isAdvertising => _isAdvertising;
  bool get isDiscovering => _isDiscovering;
  String get statusMessage => _statusMessage;
  String? get errorMessage => _errorMessage;
  List<LocalMeshPeer> get discoveredPeers => _peers.values.toList();
  List<LocalMeshPeer> get connectedPeers =>
      _peers.values.where((p) => p.isConnected).toList();
  List<LocalMeshMessage> get messages => List.unmodifiable(_messages);

  void setDeviceName(String newName) {
    if (newName.trim().isNotEmpty && newName != _deviceName) {
      _deviceName = newName.trim();
      notifyListeners();
    }
  }

  // Request Permissions
  Future<bool> requestPermissions() async {
    try {
      _errorMessage = null;
      _statusMessage = 'Requesting nearby & location permissions...';
      notifyListeners();

      final permissions = <Permission>[
        Permission.location,
        Permission.bluetoothScan,
        Permission.bluetoothAdvertise,
        Permission.bluetoothConnect,
        Permission.nearbyWifiDevices,
      ];

      Map<Permission, PermissionStatus> statuses = await permissions.request();

      bool isLocationGranted = statuses[Permission.location]?.isGranted ?? false;
      
      // On Android 12+, check bluetooth/nearby permissions
      bool areNewPermissionsGranted = true;
      if (statuses.containsKey(Permission.bluetoothScan)) {
        areNewPermissionsGranted =
            (statuses[Permission.bluetoothScan]?.isGranted ?? true) &&
            (statuses[Permission.bluetoothAdvertise]?.isGranted ?? true) &&
            (statuses[Permission.bluetoothConnect]?.isGranted ?? true);
      }

      if (isLocationGranted && areNewPermissionsGranted) {
        _statusMessage = 'Permissions granted. Ready for local mesh connection.';
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Bluetooth/Location permissions denied.';
        _statusMessage = 'Permissions denied. Cannot discover nearby devices.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Permission error: $e';
      _statusMessage = 'Error checking permissions.';
      notifyListeners();
      return false;
    }
  }

  // Toggle Advertising
  Future<void> toggleAdvertising() async {
    if (_isAdvertising) {
      await stopAdvertising();
    } else {
      await startAdvertising();
    }
  }

  Future<void> startAdvertising() async {
    try {
      _errorMessage = null;
      final permGranted = await requestPermissions();
      if (!permGranted) return;

      bool a = await Nearby().startAdvertising(
        _deviceName,
        _strategy,
        onConnectionInitiated: _onConnectionInitiated,
        onConnectionResult: _onConnectionResult,
        onDisconnected: _onDisconnected,
        serviceId: serviceId,
      );

      _isAdvertising = a;
      if (a) {
        _statusMessage = 'Advertising as "$_deviceName" (P2P Cluster)';
      } else {
        _errorMessage = 'Failed to start advertising.';
      }
    } catch (e) {
      _isAdvertising = false;
      _errorMessage = 'Advertising exception: $e';
      _statusMessage = 'Advertising failed.';
    }
    notifyListeners();
  }

  Future<void> stopAdvertising() async {
    try {
      await Nearby().stopAdvertising();
      _isAdvertising = false;
      _statusMessage = 'Stopped advertising.';
    } catch (e) {
      _errorMessage = 'Stop advertising error: $e';
    }
    notifyListeners();
  }

  // Toggle Discovery
  Future<void> toggleDiscovery() async {
    if (_isDiscovering) {
      await stopDiscovery();
    } else {
      await startDiscovery();
    }
  }

  Future<void> startDiscovery() async {
    try {
      _errorMessage = null;
      final permGranted = await requestPermissions();
      if (!permGranted) return;

      bool d = await Nearby().startDiscovery(
        _deviceName,
        _strategy,
        onEndpointFound: (endpointId, name, serviceId) {
          _statusMessage = 'Discovered device: $name';
          _peers[endpointId] = LocalMeshPeer(
            id: endpointId,
            name: name.isEmpty ? 'Unknown Peer' : name,
            status: PeerConnectionStatus.discovered,
          );
          notifyListeners();
        },
        onEndpointLost: (endpointId) {
          final peer = _peers[endpointId];
          if (peer != null && !peer.isConnected) {
            _peers.remove(endpointId);
            _statusMessage = 'Lost endpoint: ${peer.name}';
            notifyListeners();
          }
        },
        serviceId: serviceId,
      );

      _isDiscovering = d;
      if (d) {
        _statusMessage = 'Searching for nearby devices...';
      } else {
        _errorMessage = 'Failed to start discovery.';
      }
    } catch (e) {
      _isDiscovering = false;
      _errorMessage = 'Discovery exception: $e';
      _statusMessage = 'Discovery failed.';
    }
    notifyListeners();
  }

  Future<void> stopDiscovery() async {
    try {
      await Nearby().stopDiscovery();
      _isDiscovering = false;
      _statusMessage = 'Stopped discovery.';
    } catch (e) {
      _errorMessage = 'Stop discovery error: $e';
    }
    notifyListeners();
  }

  // Request Connection to peer
  Future<void> connectToPeer(String endpointId) async {
    final peer = _peers[endpointId];
    if (peer == null) return;

    try {
      _errorMessage = null;
      _statusMessage = 'Connecting to ${peer.name}...';
      peer.status = PeerConnectionStatus.connecting;
      notifyListeners();

      await Nearby().requestConnection(
        _deviceName,
        endpointId,
        onConnectionInitiated: _onConnectionInitiated,
        onConnectionResult: _onConnectionResult,
        onDisconnected: _onDisconnected,
      );
    } catch (e) {
      peer.status = PeerConnectionStatus.disconnected;
      _errorMessage = 'Connection request error: $e';
      _statusMessage = 'Connection failed to ${peer.name}';
      notifyListeners();
    }
  }

  // Disconnect from peer
  Future<void> disconnectFromPeer(String endpointId) async {
    final peer = _peers[endpointId];
    try {
      await Nearby().disconnectFromEndpoint(endpointId);
      if (peer != null) {
        peer.status = PeerConnectionStatus.disconnected;
        _statusMessage = 'Disconnected from ${peer.name}';
      }
    } catch (e) {
      _errorMessage = 'Disconnect error: $e';
    }
    notifyListeners();
  }

  // Connection Callbacks
  void _onConnectionInitiated(String endpointId, ConnectionInfo info) async {
    _statusMessage = 'Connection initiated by ${info.endpointName}. Accepting handshake...';
    
    // Track peer if not already tracked
    _peers[endpointId] = LocalMeshPeer(
      id: endpointId,
      name: info.endpointName.isEmpty ? 'Unknown Device' : info.endpointName,
      status: PeerConnectionStatus.connecting,
    );
    notifyListeners();

    // Auto-accept connection handshake for seamless mesh pairing
    try {
      await Nearby().acceptConnection(
        endpointId,
        onPayLoadRecieved: (endpointId, payload) {
          _onPayloadReceived(endpointId, payload);
        },
      );
    } catch (e) {
      _errorMessage = 'Accept connection error: $e';
      notifyListeners();
    }
  }

  void _onConnectionResult(String endpointId, Status status) {
    final peer = _peers[endpointId];
    if (status == Status.CONNECTED) {
      if (peer != null) {
        peer.status = PeerConnectionStatus.connected;
        _statusMessage = 'Connected to ${peer.name}';
      } else {
        _peers[endpointId] = LocalMeshPeer(
          id: endpointId,
          name: 'Peer $endpointId',
          status: PeerConnectionStatus.connected,
        );
        _statusMessage = 'Connected to endpoint $endpointId';
      }
    } else {
      if (peer != null) {
        peer.status = PeerConnectionStatus.disconnected;
      }
      _errorMessage = 'Connection rejected/failed with status: ${status.name}';
      _statusMessage = 'Connection failed';
    }
    notifyListeners();
  }

  void _onDisconnected(String endpointId) {
    final peer = _peers[endpointId];
    final peerName = peer?.name ?? endpointId;
    if (peer != null) {
      peer.status = PeerConnectionStatus.disconnected;
    }
    _statusMessage = 'Disconnected from $peerName';
    notifyListeners();
  }

  // Payload Handling & Deduplication / Mesh Relay
  void _onPayloadReceived(String fromEndpointId, Payload payload) {
    if (payload.type != PayloadType.BYTES || payload.bytes == null) return;

    final msg = LocalMeshMessage.fromUtf8Bytes(payload.bytes!);
    if (msg == null) return;

    // Deduplication check
    if (_processedMessageIds.contains(msg.messageId)) {
      // Already received/processed, drop duplicate payload
      return;
    }

    _processedMessageIds.add(msg.messageId);
    _messages.add(msg);
    _statusMessage = 'Message received from ${msg.senderName}';
    notifyListeners();

    // Mesh Forwarding / Relay logic
    // Forward message to all other connected peers if hop count < maxHops
    if (msg.hopCount < maxHops) {
      final relayedMsg = msg.incrementHop();
      final bytesToRelay = relayedMsg.toUtf8Bytes();

      for (var peer in connectedPeers) {
        // Do not send back to sender endpoint or original author
        if (peer.id != fromEndpointId && peer.id != msg.senderId) {
          Nearby().sendBytesPayload(peer.id, bytesToRelay).catchError((e) {
            // Fail silently or log forwarding error
          });
        }
      }
    }
  }

  // Send Message
  Future<bool> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;

    if (connectedPeers.isEmpty) {
      _errorMessage = 'No connected peers to send message.';
      _statusMessage = 'Connection needed to send message.';
      notifyListeners();
      return false;
    }

    final msg = LocalMeshMessage(
      messageId: '${myDeviceId}_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9999)}',
      senderId: myDeviceId,
      senderName: _deviceName,
      content: trimmed,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      hopCount: 0,
    );

    _processedMessageIds.add(msg.messageId);
    _messages.add(msg);
    notifyListeners();

    final bytes = msg.toUtf8Bytes();
    bool sentToAny = false;

    for (var peer in connectedPeers) {
      try {
        await Nearby().sendBytesPayload(peer.id, bytes);
        sentToAny = true;
      } catch (e) {
        _errorMessage = 'Error sending payload to ${peer.name}: $e';
      }
    }

    if (sentToAny) {
      _statusMessage = 'Message sent to ${connectedPeers.length} peer(s)';
    } else {
      _statusMessage = 'Sending payload failed.';
    }
    notifyListeners();
    return sentToAny;
  }

  void clearMessages() {
    _messages.clear();
    _processedMessageIds.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    try {
      Nearby().stopAdvertising();
      Nearby().stopDiscovery();
      Nearby().stopAllEndpoints();
    } catch (_) {}
    super.dispose();
  }
}
