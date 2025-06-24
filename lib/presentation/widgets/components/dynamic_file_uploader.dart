import 'dart:async';
import 'dart:io';
import 'package:cross_file/cross_file.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:dynamic_form_bi/core/utils/style_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class DynamicFileUploader extends StatefulWidget {
  final DynamicFormModel component;

  const DynamicFileUploader({super.key, required this.component});

  @override
  State<DynamicFileUploader> createState() => _DynamicFileUploaderState();
}

class _DynamicFileUploaderState extends State<DynamicFileUploader> {
  String _currentState = 'base'; // base, dragging, loading, success, error
  bool _isDragging = false;
  double _progress = 0.0;
  List<XFile> _pickedFiles = [];
  Timer? _timer;
  bool _isMultipleFiles = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _isMultipleFiles = widget.component.config['multipleFiles'] == true;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startUpload(List<XFile> files) {
    if (_isProcessing) return; // Prevent multiple simultaneous uploads

    _pickedFiles = files;
    _isProcessing = true;

    setState(() {
      _currentState = 'loading';
      _progress = 0;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _progress += 2; // Slower progress for better stability
        if (_progress >= 100) {
          timer.cancel();
          _isProcessing = false;
          // Simulate a random success/error outcome
          if (DateTime.now().second % 2 == 0) {
            _currentState = 'success';
          } else {
            _currentState = 'error';
          }
        }
      });
    });
  }

  void _handleFiles(List<XFile> files) {
    if (files.isEmpty || _isProcessing) return;

    final allowedExtensions =
        (widget.component.config['allowedExtensions'] as List<dynamic>?)
            ?.cast<String>() ??
        [];

    // Check if all files have allowed extensions
    if (allowedExtensions.isNotEmpty) {
      for (final file in files) {
        if (!allowedExtensions.any(
          (ext) => file.name.toLowerCase().endsWith('.${ext.toLowerCase()}'),
        )) {
          debugPrint(
            "File type not allowed: ${file.name}. Allowed: $allowedExtensions",
          );
          setState(() {
            _currentState = 'error';
            _isProcessing = false;
          });
          return;
        }
      }
    }

    _startUpload(files);
  }

  void _browseFiles() async {
    if (_isProcessing) return;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions:
            (widget.component.config['allowedExtensions'] as List<dynamic>?)
                ?.cast<String>(),
        allowMultiple: _isMultipleFiles,
      );

      if (result != null && result.files.isNotEmpty && mounted) {
        final files = result.files.map((f) => XFile(f.path!)).toList();
        _handleFiles(files);
      }
    } catch (e) {
      debugPrint('Error picking files: $e');
      if (mounted) {
        setState(() {
          _currentState = 'error';
          _isProcessing = false;
        });
      }
    }
  }

  void _resetState() {
    if (!mounted) return;

    setState(() {
      _currentState = 'base';
      _pickedFiles.clear();
      _progress = 0;
      _isDragging = false;
      _isProcessing = false;
      _timer?.cancel();
    });
  }

  void _removeFile(int index) {
    if (!mounted || _isProcessing) return;

    setState(() {
      _pickedFiles.removeAt(index);
      if (_pickedFiles.isEmpty) {
        _currentState = 'base';
      }
    });
  }

  IconData? _mapIconNameToIconData(String name) {
    switch (name) {
      case 'file':
        return Icons.insert_drive_file_outlined;
      case 'check':
        return Icons.check_circle_outline;
      case 'error':
        return Icons.error_outline;
      case 'mail':
        return Icons.mail;
      case 'close':
        return Icons.close;
      case 'user':
        return Icons.person;
      case 'lock':
        return Icons.lock;
      case 'chevron-down':
        return Icons.keyboard_arrow_down;
      case 'chevron-up':
        return Icons.keyboard_arrow_up;
      case 'globe':
        return Icons.language;
      case 'heart':
        return Icons.favorite;
      case 'search':
        return Icons.search;
      case 'location':
        return Icons.location_on;
      case 'calendar':
        return Icons.calendar_today;
      case 'phone':
        return Icons.phone;
      case 'email':
        return Icons.email;
      case 'home':
        return Icons.home;
      case 'work':
        return Icons.work;
      case 'school':
        return Icons.school;
      case 'shopping':
        return Icons.shopping_cart;
      case 'food':
        return Icons.restaurant;
      case 'sports':
        return Icons.sports_soccer;
      case 'movie':
        return Icons.movie;
      case 'book':
        return Icons.book;
      case 'car':
        return Icons.directions_car;
      case 'plane':
        return Icons.flight;
      case 'train':
        return Icons.train;
      case 'bus':
        return Icons.directions_bus;
      case 'bike':
        return Icons.directions_bike;
      case 'walk':
        return Icons.directions_walk;
      case 'settings':
        return Icons.settings;
      case 'logout':
        return Icons.logout;
      case 'bell':
        return Icons.notifications;
      case 'more_horiz':
        return Icons.more_horiz;
      case 'edit':
        return Icons.edit;
      case 'delete':
        return Icons.delete;
      case 'share':
        return Icons.share;
      default:
        return null;
    }
  }

  bool _isImageFile(String filePath) {
    final imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'];
    final extension = filePath.split('.').last.toLowerCase();
    return imageExtensions.contains(extension);
  }

  Future<String> _getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      final size = await file.length();
      if (size < 1024) {
        return '$size B';
      } else if (size < 1024 * 1024) {
        return '${(size / 1024).toStringAsFixed(1)} KB';
      } else {
        return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
      }
    } catch (e) {
      return 'Unknown size';
    }
  }

  Widget _buildBaseState(
    Map<String, dynamic> style,
    Map<String, dynamic> config,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (style['icon'] != null) ...[
          Icon(
            _mapIconNameToIconData(style['icon']),
            color: StyleUtils.parseColor(style['iconColor']),
            size: (style['iconSize'] as num?)?.toDouble() ?? 48,
          ),
          const SizedBox(height: 8),
        ],
        Text(
          config['title'] ?? '',
          textAlign: TextAlign.center,
          style: TextStyle(color: StyleUtils.parseColor(style['textColor'])),
        ),
        if (config['subtitle'] != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              config['subtitle'] ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: StyleUtils.parseColor(style['textColor']),
              ),
            ),
          ),
        if (config['buttonText'] != null &&
            config['buttonText'].isNotEmpty) ...[
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isProcessing ? null : _browseFiles,
            style: ElevatedButton.styleFrom(
              backgroundColor: StyleUtils.parseColor(
                style['buttonBackgroundColor'],
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  (style['buttonBorderRadius'] as num?)?.toDouble() ?? 8,
                ),
              ),
            ),
            child: Text(
              config['buttonText'] ?? 'Browse',
              style: TextStyle(
                color: StyleUtils.parseColor(style['buttonTextColor']),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLoadingState(
    Map<String, dynamic> style,
    Map<String, dynamic> config,
  ) {
    String statusText =
        config['statusTextFormat'] ??
        'Uploading {fileName} {progress}/{total}%';

    if (_isMultipleFiles && _pickedFiles.length > 1) {
      statusText = statusText
          .replaceAll('{fileName}', '${_pickedFiles.length} files')
          .replaceAll('{progress}', _progress.toInt().toString())
          .replaceAll('{total}', '100');
    } else if (_pickedFiles.isNotEmpty) {
      statusText = statusText
          .replaceAll('{fileName}', _pickedFiles.first.name)
          .replaceAll('{progress}', _progress.toInt().toString())
          .replaceAll('{total}', '100');
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (style['icon'] != null)
          Icon(
            _mapIconNameToIconData(style['icon']),
            color: StyleUtils.parseColor(style['iconColor']),
            size: 48,
          ),
        const SizedBox(height: 16),
        Text(
          statusText,
          textAlign: TextAlign.center,
          style: TextStyle(color: StyleUtils.parseColor(style['textColor'])),
        ),
        if (config['subtitle'] != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              config['subtitle'],
              textAlign: TextAlign.center,
              style: TextStyle(
                color: StyleUtils.parseColor(
                  style['textColor'],
                ).withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
          ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: null, // Disabled
          style: ElevatedButton.styleFrom(
            backgroundColor: StyleUtils.parseColor(
              style['buttonBackgroundColor'],
            ).withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                (style['buttonBorderRadius'] as num?)?.toDouble() ?? 8,
              ),
            ),
          ),
          child: Text(
            config['buttonText'] ?? 'Loading',
            style: TextStyle(
              color: StyleUtils.parseColor(style['buttonTextColor']),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessState(
    Map<String, dynamic> style,
    Map<String, dynamic> config,
  ) {
    final bool hasPreview =
        widget.component.variants?.containsKey('withPreview') ?? false;
    final bool isMultipleVariant =
        widget.component.variants?.containsKey('multipleFiles') ?? false;

    if (isMultipleVariant && _pickedFiles.length > 1) {
      return _buildMultipleFilesSuccessState(style, config);
    }

    if (hasPreview &&
        _pickedFiles.isNotEmpty &&
        _isImageFile(_pickedFiles.first.path)) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  (style['borderRadius'] as num?)?.toDouble() ?? 8.0,
                ),
                child: Image.file(
                  File(_pickedFiles.first.path),
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _resetState,
            style: ElevatedButton.styleFrom(
              backgroundColor: StyleUtils.parseColor(
                style['buttonBackgroundColor'],
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  (style['buttonBorderRadius'] as num?)?.toDouble() ?? 8,
                ),
              ),
            ),
            child: Text(
              config['buttonText'] ?? 'Remove',
              style: TextStyle(
                color: StyleUtils.parseColor(style['buttonTextColor']),
              ),
            ),
          ),
        ],
      );
    }

    String statusText = config['statusTextFormat'] ?? '{fileName} uploaded!';
    if (_isMultipleFiles && _pickedFiles.length > 1) {
      statusText = statusText.replaceAll(
        '{fileName}',
        '${_pickedFiles.length} files',
      );
    } else if (_pickedFiles.isNotEmpty) {
      statusText = statusText.replaceAll('{fileName}', _pickedFiles.first.name);
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (style['icon'] != null)
          Icon(
            _mapIconNameToIconData(style['icon']),
            color: StyleUtils.parseColor(style['iconColor']),
            size: 48,
          ),
        const SizedBox(height: 16),
        Text(
          statusText,
          style: TextStyle(color: StyleUtils.parseColor(style['textColor'])),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _resetState,
          style: ElevatedButton.styleFrom(
            backgroundColor: StyleUtils.parseColor(
              style['buttonBackgroundColor'],
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                (style['buttonBorderRadius'] as num?)?.toDouble() ?? 8,
              ),
            ),
          ),
          child: Text(
            config['buttonText'] ?? 'Remove',
            style: TextStyle(
              color: StyleUtils.parseColor(style['buttonTextColor']),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMultipleFilesSuccessState(
    Map<String, dynamic> style,
    Map<String, dynamic> config,
  ) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _pickedFiles.length,
            itemBuilder: (context, index) {
              final file = _pickedFiles[index];
              final isImage = _isImageFile(file.path);

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: StyleUtils.parseColor(
                    style['fileItemBackgroundColor'],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    if (isImage) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: Image.file(
                            File(file.path),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.broken_image,
                                color: StyleUtils.parseColor(
                                  style['iconColor'],
                                ),
                                size: 40,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ] else ...[
                      Icon(
                        Icons.insert_drive_file,
                        color: StyleUtils.parseColor(style['iconColor']),
                        size: 40,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            file.name,
                            style: TextStyle(
                              color: StyleUtils.parseColor(style['textColor']),
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          FutureBuilder<String>(
                            future: _getFileSize(file.path),
                            builder: (context, snapshot) {
                              return Text(
                                snapshot.data ?? 'Calculating...',
                                style: TextStyle(
                                  color: StyleUtils.parseColor(
                                    style['textColor'],
                                  ).withValues(alpha: 0.7),
                                  fontSize: 12,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _isProcessing
                          ? null
                          : () => _removeFile(index),
                      icon: Icon(
                        Icons.close,
                        color: StyleUtils.parseColor(style['iconColor']),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _browseFiles,
                style: ElevatedButton.styleFrom(
                  backgroundColor: StyleUtils.parseColor(
                    style['buttonBackgroundColor'],
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      (style['buttonBorderRadius'] as num?)?.toDouble() ?? 8,
                    ),
                  ),
                ),
                child: Text(
                  config['addMoreButtonText'] ?? 'Add More',
                  style: TextStyle(
                    color: StyleUtils.parseColor(style['buttonTextColor']),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _isProcessing ? null : _resetState,
              style: ElevatedButton.styleFrom(
                backgroundColor: StyleUtils.parseColor(
                  style['removeAllButtonColor'],
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    (style['buttonBorderRadius'] as num?)?.toDouble() ?? 8,
                  ),
                ),
              ),
              child: Text(
                config['removeAllButtonText'] ?? 'Remove All',
                style: TextStyle(
                  color: StyleUtils.parseColor(style['buttonTextColor']),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorState(
    Map<String, dynamic> style,
    Map<String, dynamic> config,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (style['icon'] != null)
          Icon(
            _mapIconNameToIconData(style['icon']),
            color: StyleUtils.parseColor(style['iconColor']),
            size: 48,
          ),
        const SizedBox(height: 16),
        Text(
          config['statusText'] ?? 'Error',
          textAlign: TextAlign.center,
          style: TextStyle(color: StyleUtils.parseColor(style['textColor'])),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _resetState,
          style: ElevatedButton.styleFrom(
            backgroundColor: StyleUtils.parseColor(
              style['buttonBackgroundColor'],
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                (style['buttonBorderRadius'] as num?)?.toDouble() ?? 8,
              ),
            ),
          ),
          child: Text(
            config['buttonText'] ?? 'Retry',
            style: TextStyle(
              color: StyleUtils.parseColor(style['buttonTextColor']),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> baseStyle = Map.from(widget.component.style);
    final Map<String, dynamic> variantStyle = _isDragging
        ? Map.from(widget.component.variants?['dragging']?['style'] ?? {})
        : {};
    final Map<String, dynamic> stateStyle = Map.from(
      widget.component.states?[_currentState]?['style'] ?? {},
    );

    final style = {...baseStyle, ...variantStyle, ...stateStyle};

    final Map<String, dynamic> baseConfig = Map.from(widget.component.config);
    final Map<String, dynamic> variantConfig = _isDragging
        ? Map.from(widget.component.variants?['dragging']?['config'] ?? {})
        : {};
    final Map<String, dynamic> stateConfig = Map.from(
      widget.component.states?[_currentState]?['config'] ?? {},
    );
    final config = {...baseConfig, ...variantConfig, ...stateConfig};

    return DragTarget<List<XFile>>(
      onWillAcceptWithDetails: (data) {
        if (_isProcessing) return false;
        setState(() => _isDragging = true);
        return true;
      },
      onAcceptWithDetails: (details) {
        // Changed from onAccept to onAcceptWithDetails
        setState(() => _isDragging = false);
        _handleFiles(details.data); // Use details.data instead of details.files
      },
      onLeave: (data) {
        setState(() => _isDragging = false);
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          key: Key(widget.component.id),
          margin: StyleUtils.parsePadding(style['margin']),
          child: DottedBorder(
            color: StyleUtils.parseColor(style['borderColor']),
            strokeWidth: (style['borderWidth'] as num?)?.toDouble() ?? 1,
            radius: Radius.circular(
              (style['borderRadius'] as num?)?.toDouble() ?? 0,
            ),
            dashPattern: const [6, 6],
            borderType: BorderType.RRect,
            child: Container(
              width: (style['width'] as num?)?.toDouble() ?? 300,
              height: (style['height'] as num?)?.toDouble() ?? 200,
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              decoration: BoxDecoration(
                color: StyleUtils.parseColor(style['backgroundColor']),
                borderRadius: BorderRadius.circular(
                  (style['borderRadius'] as num?)?.toDouble() ?? 0,
                ),
              ),
              child: _buildChild(style, config),
            ),
          ),
        );
      },
    );
  }

  // Moved into build method for clarity or can remain as private helper if only used here
  Widget _buildChild(Map<String, dynamic> style, Map<String, dynamic> config) {
    switch (_currentState) {
      case 'loading':
        return _buildLoadingState(style, config);
      case 'success':
        return _buildSuccessState(style, config);
      case 'error':
        return _buildErrorState(style, config);
      default: // base and dragging
        return _buildBaseState(style, config);
    }
  }
}
