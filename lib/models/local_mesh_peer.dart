enum PeerConnectionStatus {
  discovered,
  connecting,
  connected,
  disconnected,
}

class LocalMeshPeer {
  final String id; // Endpoint ID from Nearby Connections
  final String name;
  PeerConnectionStatus status;
  final DateTime discoveredAt;

  LocalMeshPeer({
    required this.id,
    required this.name,
    this.status = PeerConnectionStatus.discovered,
    DateTime? discoveredAt,
  }) : discoveredAt = discoveredAt ?? DateTime.now();

  bool get isConnected => status == PeerConnectionStatus.connected;
  bool get isConnecting => status == PeerConnectionStatus.connecting;

  LocalMeshPeer copyWith({
    String? name,
    PeerConnectionStatus? status,
  }) {
    return LocalMeshPeer(
      id: id,
      name: name ?? this.name,
      status: status ?? this.status,
      discoveredAt: discoveredAt,
    );
  }
}
