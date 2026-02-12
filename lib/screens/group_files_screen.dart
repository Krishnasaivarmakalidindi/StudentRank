import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:studentrank/providers/app_provider.dart';
import 'package:studentrank/providers/file_share_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class GroupFilesScreen extends StatefulWidget {
  final String groupId;

  const GroupFilesScreen({super.key, required this.groupId});

  @override
  State<GroupFilesScreen> createState() => _GroupFilesScreenState();
}

class _GroupFilesScreenState extends State<GroupFilesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FileShareProvider>().initFiles(widget.groupId);
    });
  }

  Future<void> _pickAndUploadFile() async {
    final appProvider = context.read<AppProvider>();
    final user = appProvider.currentUser;
    if (user == null) return;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'pdf',
        'doc',
        'docx',
        'xls',
        'xlsx',
        'txt',
        'jpg',
        'png',
        'jpeg'
      ],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final fileName = result.files.single.name;
      final size = result.files.single.size;

      if (size > 10 * 1024 * 1024) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File size too large. Max 10MB.')),
        );
        return;
      }

      // Ask for description
      if (!mounted) return;
      final descriptionController = TextEditingController();
      final shouldUpload = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Upload File'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('File: $fileName'),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Upload'),
            ),
          ],
        ),
      );

      if (shouldUpload == true) {
        if (!mounted) return;
        try {
          await context.read<FileShareProvider>().uploadFile(
                groupId: widget.groupId,
                userId: user.id,
                userName: user.name,
                file: file,
                description: descriptionController.text.trim(),
              );
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File uploaded successfully')),
          );
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload failed: $e')),
          );
        }
      }
    }
  }

  Future<void> _openFile(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open file')),
      );
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  IconData _getFileIcon(String fileType) {
    switch (fileType) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'image':
        return Icons.image;
      case 'doc':
        return Icons.description;
      case 'xls':
        return Icons.table_chart;
      default:
        return Icons.insert_drive_file;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pickAndUploadFile,
        icon: const Icon(Icons.upload_file),
        label: const Text('Upload'),
      ),
      body: Consumer<FileShareProvider>(
        builder: (context, provider, child) {
          if (provider.isUploading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                      'Uploading... ${(provider.uploadProgress * 100).toInt()}%'),
                ],
              ),
            );
          }

          if (provider.isLoading && provider.files.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.files.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open,
                      size: 64,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant
                          .withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  Text(
                    'No files shared yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.files.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final file = provider.files[index];
              return Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainer,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    child: Icon(_getFileIcon(file.fileType),
                        color: Theme.of(context).colorScheme.primary),
                  ),
                  title: Text(
                    file.fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (file.description.isNotEmpty)
                        Text(file.description,
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '${_formatBytes(file.fileSize)} • ${DateFormat('MMM d').format(file.uploadedAt)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const Spacer(),
                          Text(
                            'by ${file.uploaderName}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.download_rounded),
                    onPressed: () => _openFile(file.fileUrl),
                  ),
                  onTap: () => _openFile(file.fileUrl),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
