import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/local_mesh_peer.dart';
import '../providers/local_mesh_provider.dart';

class Activity4Screen extends StatefulWidget {
  const Activity4Screen({super.key});

  @override
  State<Activity4Screen> createState() => _Activity4ScreenState();
}

class _Activity4ScreenState extends State<Activity4Screen> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<LocalMeshProvider>(context, listen: false);
      _nameController.text = provider.deviceName;
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _nameController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _showEditNameDialog(LocalMeshProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Device Name'),
        content: TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Device Name',
            hintText: 'Enter name (e.g. Phone A)',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.setDeviceName(_nameController.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocalMeshProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Mesh Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Request Permissions',
            onPressed: () => provider.requestPermissions(),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Clear Chat',
            onPressed: provider.messages.isEmpty ? null : provider.clearMessages,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Status Bar & Error Notification
            _buildStatusHeader(context, provider),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Device Info & Control Panel
                    _buildDeviceControlsCard(context, provider),
                    const SizedBox(height: 16),

                    // Discovered & Connected Nearby Devices
                    _buildNearbyDevicesCard(context, provider),
                    const SizedBox(height: 16),

                    // Chat Window
                    _buildChatCard(context, provider),
                  ],
                ),
              ),
            ),

            // Message Input Bar
            _buildMessageInputBar(context, provider),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(BuildContext context, LocalMeshProvider provider) {
    final theme = Theme.of(context);
    final hasError = provider.errorMessage != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: hasError
          ? theme.colorScheme.errorContainer
          : theme.colorScheme.primaryContainer.withAlpha(120),
      child: Row(
        children: [
          Icon(
            hasError ? Icons.warning_amber_rounded : Icons.info_outline_rounded,
            size: 18,
            color: hasError
                ? theme.colorScheme.onErrorContainer
                : theme.colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              hasError ? provider.errorMessage! : provider.statusMessage,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: hasError
                    ? theme.colorScheme.onErrorContainer
                    : theme.colorScheme.onPrimaryContainer,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceControlsCard(
      BuildContext context, LocalMeshProvider provider) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Device Name Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primary.withAlpha(30),
                  child: Icon(
                    Icons.phonelink_ring_rounded,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'This Device',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      Text(
                        provider.deviceName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'ID: ${provider.myDeviceId}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  tooltip: 'Edit Device Name',
                  onPressed: () => _showEditNameDialog(provider),
                ),
              ],
            ),
            const Divider(height: 24),

            // Controls & Status Badges
            Row(
              children: [
                // Advertising Toggle
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: provider.toggleAdvertising,
                    icon: Icon(
                      provider.isAdvertising
                          ? Icons.sensors_rounded
                          : Icons.sensors_off_rounded,
                      color: provider.isAdvertising ? Colors.green : null,
                    ),
                    label: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Advertise'),
                        Text(
                          provider.isAdvertising ? 'Advertising: ON' : 'Advertising: OFF',
                          style: TextStyle(
                            fontSize: 10,
                            color: provider.isAdvertising
                                ? Colors.green
                                : theme.colorScheme.outline,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      backgroundColor: provider.isAdvertising
                          ? Colors.green.withAlpha(20)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Discovery Toggle
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: provider.toggleDiscovery,
                    icon: Icon(
                      provider.isDiscovering
                          ? Icons.radar_rounded
                          : Icons.radar_outlined,
                      color: provider.isDiscovering ? Colors.blue : null,
                    ),
                    label: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Discover'),
                        Text(
                          provider.isDiscovering ? 'Scanning: ON' : 'Scanning: OFF',
                          style: TextStyle(
                            fontSize: 10,
                            color: provider.isDiscovering
                                ? Colors.blue
                                : theme.colorScheme.outline,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      backgroundColor: provider.isDiscovering
                          ? Colors.blue.withAlpha(20)
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNearbyDevicesCard(
      BuildContext context, LocalMeshProvider provider) {
    final theme = Theme.of(context);
    final peers = provider.discoveredPeers;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.devices_other_rounded,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Nearby Devices',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${provider.connectedPeers.length} Connected',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (peers.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.wifi_find_rounded,
                        size: 36,
                        color: theme.colorScheme.outline.withAlpha(120),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        provider.isDiscovering
                            ? 'Scanning for nearby peers...'
                            : 'Tap "Discover" or "Advertise" to locate nearby phones.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: peers.length,
                separatorBuilder: (_, __) => const Divider(height: 12),
                itemBuilder: (context, index) {
                  final peer = peers[index];
                  return _buildPeerTile(context, provider, peer);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeerTile(
      BuildContext context, LocalMeshProvider provider, LocalMeshPeer peer) {
    final theme = Theme.of(context);

    Color statusColor;
    String statusText;

    switch (peer.status) {
      case PeerConnectionStatus.connected:
        statusColor = Colors.green;
        statusText = 'CONNECTED';
        break;
      case PeerConnectionStatus.connecting:
        statusColor = Colors.orange;
        statusText = 'CONNECTING...';
        break;
      case PeerConnectionStatus.discovered:
        statusColor = Colors.blue;
        statusText = 'DISCOVERED';
        break;
      case PeerConnectionStatus.disconnected:
        statusColor = Colors.grey;
        statusText = 'DISCONNECTED';
        break;
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: statusColor.withAlpha(30),
        child: Icon(
          peer.isConnected
              ? Icons.link_rounded
              : Icons.phonelink_setup_rounded,
          color: statusColor,
        ),
      ),
      title: Text(
        peer.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ],
      ),
      trailing: peer.isConnected
          ? ElevatedButton.icon(
              onPressed: () => provider.disconnectFromPeer(peer.id),
              icon: const Icon(Icons.link_off_rounded, size: 16),
              label: const Text('DISCONNECT'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.errorContainer,
                foregroundColor: theme.colorScheme.onErrorContainer,
                elevation: 0,
              ),
            )
          : ElevatedButton.icon(
              onPressed: peer.isConnecting
                  ? null
                  : () => provider.connectToPeer(peer.id),
              icon: const Icon(Icons.link_rounded, size: 16),
              label: const Text('CONNECT'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                elevation: 0,
              ),
            ),
    );
  }

  Widget _buildChatCard(BuildContext context, LocalMeshProvider provider) {
    final theme = Theme.of(context);
    final messages = provider.messages;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Container(
        constraints: const BoxConstraints(minHeight: 250, maxHeight: 400),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.forum_rounded,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Mesh Chat Log',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${messages.length} payloads',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
            const Divider(height: 16),

            Expanded(
              child: messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 40,
                            color: theme.colorScheme.outline.withAlpha(100),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No mesh messages yet.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                          Text(
                            'Connect to a peer and start messaging!',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        final isMe = msg.senderId == provider.myDeviceId;

                        final date = DateTime.fromMillisecondsSinceEpoch(
                            msg.timestamp);
                        final timeStr =
                            '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

                        return Align(
                          alignment:
                              isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4.0),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14.0, vertical: 10.0),
                            decoration: BoxDecoration(
                              color: isMe
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(14),
                                topRight: const Radius.circular(14),
                                bottomLeft: isMe
                                    ? const Radius.circular(14)
                                    : const Radius.circular(2),
                                bottomRight: isMe
                                    ? const Radius.circular(2)
                                    : const Radius.circular(14),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: isMe
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      isMe ? 'You' : msg.senderName,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isMe
                                            ? theme.colorScheme.onPrimary
                                            : theme.colorScheme
                                                .onSecondaryContainer,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (msg.hopCount > 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.withAlpha(180),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'Relayed (${msg.hopCount} hop)',
                                          style: const TextStyle(
                                            fontSize: 9,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  msg.content,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isMe
                                        ? theme.colorScheme.onPrimary
                                        : theme
                                            .colorScheme.onSecondaryContainer,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  timeStr,
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: isMe
                                        ? theme.colorScheme.onPrimary
                                            .withAlpha(180)
                                        : theme.colorScheme.onSecondaryContainer
                                            .withAlpha(180),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInputBar(
      BuildContext context, LocalMeshProvider provider) {
    final theme = Theme.of(context);
    final canSend = provider.connectedPeers.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: canSend
                    ? 'Type localized mesh payload...'
                    : 'Connect to peer to chat...',
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                enabled: canSend,
              ),
              onSubmitted: (_) => _handleSend(provider),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            icon: const Icon(Icons.send_rounded),
            onPressed: canSend ? () => _handleSend(provider) : null,
          ),
        ],
      ),
    );
  }

  void _handleSend(LocalMeshProvider provider) async {
    final text = _messageController.text;
    if (text.trim().isEmpty) return;

    final success = await provider.sendMessage(text);
    if (success) {
      _messageController.clear();
      _scrollToBottom();
    }
  }
}
