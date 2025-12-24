import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:studentrank/models/resource.dart';
import 'package:studentrank/models/activity.dart';
import 'package:studentrank/providers/app_provider.dart';
import 'package:studentrank/services/resource_service.dart';
import 'package:studentrank/services/activity_service.dart';
import 'package:studentrank/theme.dart';
import 'package:studentrank/services/storage_service.dart';
import 'package:studentrank/nav.dart';
import 'package:studentrank/widgets/student_rank_app_bar.dart';

class ContributeScreen extends StatefulWidget {
  const ContributeScreen({super.key});

  @override
  State<ContributeScreen> createState() => _ContributeScreenState();
}

class _ContributeScreenState extends State<ContributeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _subjectController = TextEditingController();
  final _textContentController = TextEditingController();
  final _linkController = TextEditingController();
  
  final ResourceService _resourceService = ResourceService();
  final ActivityService _activityService = ActivityService();
  final StorageService _storageService = StorageService();
  
  ResourceType _selectedType = ResourceType.notes;
  bool _isSubmitting = false;
  
  // Content State
  final List<UploadedItem> _uploadedItems = [];
  bool _showTextInput = false;
  bool _showLinkInput = false;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_updateState);
    _descriptionController.addListener(_updateState);
    _subjectController.addListener(_updateState);
  }

  void _updateState() {
    setState(() {});
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _subjectController.dispose();
    _textContentController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  // Calculate dynamic reputation
  int get _estimatedReputation {
    int base = 35;
    if (_titleController.text.length > 10) base += 5;
    if (_descriptionController.text.length > 20) base += 5;
    if (_uploadedItems.isNotEmpty) base += 10;
    if (_selectedType == ResourceType.researchPaper) base += 15;
    return base;
  }

  bool get _isDirty {
    return _titleController.text.isNotEmpty || 
           _descriptionController.text.isNotEmpty || 
           _subjectController.text.isNotEmpty ||
           _uploadedItems.isNotEmpty;
  }

  void _handleCancel() {
    if (_isDirty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Discard Contribution?'),
          content: const Text('Your uploaded content and edits will be lost.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Continue Editing'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); 
                context.go(AppRoutes.main); 
              },
              child: const Text('Discard & Exit', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    } else {
      context.go(AppRoutes.main);
    }
  }

  Future<void> _pickPDF() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        setState(() {
          _uploadedItems.add(UploadedItem(
            type: UploadType.pdf,
            name: result.files.single.name,
            size: _formatBytes(result.files.single.size),
            path: result.files.single.path ?? result.files.single.name,
          ));
        });
      }
    } catch (e) {
      debugPrint('Error picking PDF: $e');
    }
  }

  Future<void> _pickImages() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final List<XFile> images = await ImagePicker().pickMultiImage();
                  if (images.isNotEmpty) {
                    setState(() {
                      for (var image in images) {
                        _uploadedItems.add(UploadedItem(
                          type: UploadType.image,
                          name: image.name,
                          path: image.path,
                        ));
                      }
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? photo = await ImagePicker().pickImage(source: ImageSource.camera);
                  if (photo != null) {
                    setState(() {
                      _uploadedItems.add(UploadedItem(
                        type: UploadType.image,
                        name: photo.name,
                        path: photo.path,
                      ));
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = context.textStyles;

    return Scaffold(
      appBar: StudentRankAppBar(
        title: 'Contribute',
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _handleCancel,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: AppSpacing.paddingLg,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Text('Share your knowledge', style: textStyles.headlineSmall?.bold),
                      const SizedBox(height: 8),
                      Text(
                        'Upload quality content to earn reputation.', 
                        style: textStyles.bodyMedium?.copyWith(color: colors.onSurfaceVariant)
                      ),
                      const SizedBox(height: 32),

                      // 1. Content Type (Segmented Control)
                      _buildSectionLabel('Content Type'),
                      const SizedBox(height: 12),
                      _buildSegmentedControl(colors),
                      const SizedBox(height: 24),

                      // 2. Content Details
                      _buildSectionLabel('Content Details'),
                      const SizedBox(height: 12),
                      
                      // Subject Input
                      TextFormField(
                        controller: _subjectController,
                        decoration: const InputDecoration(
                          labelText: 'Subject / Topic',
                          hintText: 'e.g., Linear Algebra, Organic Chemistry',
                          prefixIcon: Icon(Icons.class_outlined),
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'Please enter a subject' : null,
                      ),
                      const SizedBox(height: 16),
                      
                      // Title Input
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          hintText: 'Clear, specific title',
                          prefixIcon: Icon(Icons.title),
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'Please enter a title' : null,
                        maxLength: 100,
                      ),
                      const SizedBox(height: 16),
                      
                      // Description Input
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'What does this content explain?',
                          alignLabelWithHint: true,
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(bottom: 60), 
                            child: Icon(Icons.description_outlined),
                          ),
                        ),
                        maxLines: 4,
                        validator: (value) => value == null || value.isEmpty ? 'Please enter a description' : null,
                        maxLength: 500,
                      ),
                      const SizedBox(height: 24),

                      // 3. Add Your Content
                      _buildSectionLabel('Add Your Content'),
                      const SizedBox(height: 12),
                      
                      // Upload Buttons Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildUploadButton(Icons.picture_as_pdf, 'PDF', Colors.red, _pickPDF),
                          _buildUploadButton(Icons.image, 'Images', Colors.purple, _pickImages),
                          _buildUploadButton(Icons.text_fields, 'Text', Colors.blue, () {
                            setState(() => _showTextInput = !_showTextInput);
                          }),
                          _buildUploadButton(Icons.link, 'Link', Colors.green, () {
                            setState(() => _showLinkInput = !_showLinkInput);
                          }),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Dynamic Inputs (Text/Link)
                      if (_showTextInput) ...[
                        TextFormField(
                          controller: _textContentController,
                          decoration: InputDecoration(
                            hintText: 'Paste your notes here...',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.check_circle),
                              color: colors.primary,
                              onPressed: () {
                                if (_textContentController.text.isNotEmpty) {
                                  setState(() {
                                    _uploadedItems.add(UploadedItem(
                                      type: UploadType.text,
                                      name: 'Text Content',
                                      path: _textContentController.text,
                                      preview: _textContentController.text,
                                    ));
                                    _textContentController.clear();
                                    _showTextInput = false;
                                  });
                                }
                              },
                            ),
                          ),
                          maxLines: 5,
                        ),
                        const SizedBox(height: 16),
                      ],

                      if (_showLinkInput) ...[
                        TextFormField(
                          controller: _linkController,
                          decoration: InputDecoration(
                            hintText: 'https://example.com/resource',
                            prefixIcon: const Icon(Icons.link),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.check_circle),
                              color: colors.primary,
                              onPressed: () {
                                if (_linkController.text.isNotEmpty) {
                                  // Simple validation
                                  if (Uri.tryParse(_linkController.text)?.hasAbsolutePath ?? false) {
                                    setState(() {
                                      _uploadedItems.add(UploadedItem(
                                        type: UploadType.link,
                                        name: 'External Link',
                                        path: _linkController.text,
                                      ));
                                      _linkController.clear();
                                      _showLinkInput = false;
                                    });
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Please enter a valid URL')),
                                    );
                                  }
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Uploaded Items List
                      if (_uploadedItems.isNotEmpty)
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: colors.outline.withOpacity(0.5)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: _uploadedItems.asMap().entries.map((entry) {
                              final index = entry.key;
                              final item = entry.value;
                              return Column(
                                children: [
                                  ListTile(
                                    leading: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: item.color.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(item.icon, color: item.color),
                                    ),
                                    title: Text(item.name, style: textStyles.titleSmall?.semiBold),
                                    subtitle: item.size != null ? Text(item.size!) : null,
                                    trailing: IconButton(
                                      icon: const Icon(Icons.close, size: 20),
                                      onPressed: () {
                                        setState(() {
                                          _uploadedItems.removeAt(index);
                                        });
                                      },
                                    ),
                                  ),
                                  if (index < _uploadedItems.length - 1)
                                    Divider(height: 1, color: colors.outline.withOpacity(0.2)),
                                ],
                              );
                            }).toList(),
                          ),
                        ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
            
            // Bottom Action Bar
            Container(
              padding: AppSpacing.paddingMd,
              decoration: BoxDecoration(
                color: colors.surface,
                boxShadow: [
                  BoxShadow(
                    color: colors.shadow.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitContribution,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: colors.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isSubmitting
                            ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: colors.onPrimary))
                            : const Text('Submit Contribution', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label, 
      style: Theme.of(context).textTheme.titleSmall?.bold.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        letterSpacing: 0.5,
      )
    );
  }

  Widget _buildSegmentedControl(ColorScheme colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outline.withOpacity(0.5)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = (constraints.maxWidth - 8) / 2;
          return Row(
            children: [
              _buildSegmentTab('Notes', ResourceType.notes, width),
              _buildSegmentTab('Research Paper', ResourceType.researchPaper, width),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSegmentTab(String label, ResourceType type, double width) {
    final isSelected = _selectedType == type;
    final colors = Theme.of(context).colorScheme;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected ? [
            BoxShadow(
              color: colors.shadow.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ] : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? colors.onPrimary : colors.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUploadButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              shape: BoxShape.circle,
              border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: Theme.of(context).textTheme.labelMedium?.semiBold),
        ],
      ),
    );
  }

  Future<void> _submitContribution() async {
    if (!_formKey.currentState!.validate()) return;

    if (_uploadedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please add at least one file or content item'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final appProvider = context.read<AppProvider>();
      final user = appProvider.currentUser;
      
      if (user == null) {
         if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error: User not found.')),
            );
         }
         return;
      }

      String? mainFileUrl;
      List<String> attachmentUrls = [];
      StringBuffer textContentBuffer = StringBuffer();
      
      // Process uploaded items
      for (final item in _uploadedItems) {
        if (item.type == UploadType.text) {
          if (textContentBuffer.isNotEmpty) textContentBuffer.writeln('\n---\n');
          textContentBuffer.write(item.path); // path stores the text content for text type
        } else if (item.type == UploadType.link) {
          attachmentUrls.add(item.path);
        } else if (item.type == UploadType.pdf || item.type == UploadType.image) {
          // Upload file
          final file = File(item.path);
          if (await file.exists()) {
            final fileName = '${const Uuid().v4()}_${item.name}';
            final path = 'resources/${user.id}/$fileName';
            
            final url = await _storageService.uploadFile(file, path);
            if (url != null) {
              attachmentUrls.add(url);
            }
          }
        }
      }

      // Determine main file URL (first non-text attachment)
      if (attachmentUrls.isNotEmpty) {
        mainFileUrl = attachmentUrls.first;
        // If multiple attachments, keep the rest in attachmentUrls
        // If we want to store ALL in attachmentUrls (including main), we can do that too.
        // But for now, let's say fileUrl is the PRIMARY one, and attachmentUrls are EXTRA.
        // So we remove the first one from the list?
        // Or we keep all in attachmentUrls and just duplicate the first one to fileUrl for easy access.
        // Let's duplicate to be safe, so attachmentUrls contains EVERYTHING uploaded.
      }

      final resource = Resource(
        id: const Uuid().v4(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _selectedType,
        subject: _subjectController.text.trim(),
        authorId: user.id,
        authorName: user.name,
        qualityRating: 0.0,
        reputationImpact: _estimatedReputation,
        viewCount: 0,
        downloadCount: 0,
        improveCount: 0,
        isPlagiarized: false,
        fileUrl: mainFileUrl,
        attachmentUrls: attachmentUrls,
        textContent: textContentBuffer.isNotEmpty ? textContentBuffer.toString() : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (user.isDemo) {
        // Just simulate success for demo user
        await Future.delayed(const Duration(seconds: 1));
      } else {
        await _resourceService.uploadResource(resource);

        final activity = Activity(
          id: const Uuid().v4(),
          userId: user.id,
          type: ActivityType.upload,
          title: 'Uploaded ${resource.title}',
          description: 'Contributed to ${resource.subject}',
          reputationChange: _estimatedReputation,
          resourceId: resource.id,
          createdAt: DateTime.now(),
        );

        await _activityService.addActivity(activity);
        await appProvider.updateReputationScore(_estimatedReputation);
      }

      if (!mounted) return;
      
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          icon: Icon(Icons.check_circle, color: Theme.of(context).colorScheme.tertiary, size: 48),
          title: const Text('Contribution Submitted!'),
          content: Text('You earned +$_estimatedReputation reputation points.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.go(AppRoutes.main);
              },
              child: const Text('Awesome'),
            ),
          ],
        ),
      );
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}

enum UploadType { pdf, image, text, link }

class UploadedItem {
  final UploadType type;
  final String name;
  final String path;
  final String? size;
  final String? preview;

  UploadedItem({
    required this.type,
    required this.name,
    required this.path,
    this.size,
    this.preview,
  });

  IconData get icon {
    switch (type) {
      case UploadType.pdf: return Icons.picture_as_pdf;
      case UploadType.image: return Icons.image;
      case UploadType.text: return Icons.text_fields;
      case UploadType.link: return Icons.link;
    }
  }

  Color get color {
    switch (type) {
      case UploadType.pdf: return Colors.red;
      case UploadType.image: return Colors.purple;
      case UploadType.text: return Colors.blue;
      case UploadType.link: return Colors.green;
    }
  }
}
