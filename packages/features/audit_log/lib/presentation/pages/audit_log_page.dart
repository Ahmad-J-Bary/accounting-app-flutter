import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audit_log/audit_log.dart';

class AuditLogPage extends ConsumerWidget {
  const AuditLogPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(auditLogsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit Log'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context, ref),
          ),
        ],
      ),
      body: logsAsync.when(
        data: (logs) => logs.isEmpty
            ? const Center(child: Text('No audit logs found'))
            : ListView.builder(
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log = logs[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ListTile(
                      leading: _getActionIcon(log.action),
                      title: Text('${log.username} - ${log.action.name}'),
                      subtitle: Text(
                        '${log.entity}${log.entityId != null ? ' (${log.entityId})' : ''}\n'
                        '${_formatDateTime(log.timestamp)}',
                      ),
                      isThreeLine: true,
                      trailing: IconButton(
                        icon: const Icon(Icons.info_outline),
                        onPressed: () => _showLogDetails(context, log),
                      ),
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _getActionIcon(AuditAction action) {
    switch (action) {
      case AuditAction.create:
        return const Icon(Icons.add_circle, color: Colors.green);
      case AuditAction.update:
        return const Icon(Icons.edit, color: Colors.blue);
      case AuditAction.delete:
        return const Icon(Icons.delete, color: Colors.red);
      case AuditAction.login:
        return const Icon(Icons.login, color: Colors.purple);
      case AuditAction.logout:
        return const Icon(Icons.logout, color: Colors.orange);
      case AuditAction.export:
        return const Icon(Icons.file_download, color: Colors.teal);
      case AuditAction.import:
        return const Icon(Icons.file_upload, color: Colors.teal);
      case AuditAction.custom:
        return const Icon(Icons.settings, color: Colors.grey);
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }

  void _showFilterDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Audit Logs'),
        content: const Text('Filter options will be implemented'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLogDetails(BuildContext context, AuditLog log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Audit Log Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('User', log.username),
              _buildDetailRow('Action', log.action.name),
              _buildDetailRow('Entity', log.entity),
              if (log.entityId != null) _buildDetailRow('Entity ID', log.entityId!),
              if (log.description != null) _buildDetailRow('Description', log.description!),
              _buildDetailRow('Timestamp', log.timestamp.toIso8601String()),
              if (log.ipAddress != null) _buildDetailRow('IP Address', log.ipAddress!),
              if (log.userAgent != null) _buildDetailRow('User Agent', log.userAgent!),
              if (log.changes != null) _buildDetailRow('Changes', log.changes.toString()),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
