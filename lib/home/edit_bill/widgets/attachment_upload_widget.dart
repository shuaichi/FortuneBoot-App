import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fortuneboot/home/edit_bill/models/attachment_item.dart';
import 'package:fortuneboot/home/edit_bill/services/attachment_service.dart';

/// 附件上传组件
class AttachmentUploadWidget extends StatefulWidget {
  final List<AttachmentItem> initialAttachments;
  final ValueChanged<List<AttachmentItem>> onAttachmentsChanged;
  final bool enabled;

  const AttachmentUploadWidget({
    super.key,
    this.initialAttachments = const [],
    required this.onAttachmentsChanged,
    this.enabled = true,
  });

  @override
  State<AttachmentUploadWidget> createState() => _AttachmentUploadWidgetState();
}

class _AttachmentUploadWidgetState extends State<AttachmentUploadWidget> {
  late List<AttachmentItem> _attachments;
  final AttachmentService _attachmentService = AttachmentService();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _attachments = List.from(widget.initialAttachments);
  }

  @override
  void didUpdateWidget(AttachmentUploadWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialAttachments != oldWidget.initialAttachments) {
      _attachments = List.from(widget.initialAttachments);
    }
  }

  /// 显示选择附件的底部弹窗
  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildAttachmentOptionsSheet(),
    );
  }

  /// 构建附件选择选项表
  Widget _buildAttachmentOptionsSheet() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '选择附件',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildOptionTile(
            icon: Icons.photo_library,
            title: '从相册选择',
            subtitle: '选择图片文件',
            onTap: () {
              Navigator.pop(context);
              _pickImagesFromGallery();
            },
          ),
          _buildOptionTile(
            icon: Icons.camera_alt,
            title: '拍照',
            subtitle: '使用相机拍摄照片',
            onTap: () {
              Navigator.pop(context);
              _takePhoto();
            },
          ),
          _buildOptionTile(
            icon: Icons.folder,
            title: '选择文件',
            subtitle: '从文件管理器选择',
            onTap: () {
              Navigator.pop(context);
              _pickFiles();
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// 构建选项项
  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  /// 从相册选择图片
  Future<void> _pickImagesFromGallery() async {
    if (!widget.enabled || _isUploading) return;

    setState(() => _isUploading = true);

    try {
      final remainingSlots = AttachmentService.maxFileCount - _attachments.length;
      if (remainingSlots <= 0) {
        _showError('最多只能上传${AttachmentService.maxFileCount}个文件');
        return;
      }

      final newAttachments = await _attachmentService.pickImagesFromGallery(
        maxImages: remainingSlots,
      );

      if (newAttachments.isNotEmpty) {
        _addAttachments(newAttachments);
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isUploading = false);
    }
  }

  /// 拍照
  Future<void> _takePhoto() async {
    if (!widget.enabled || _isUploading) return;

    setState(() => _isUploading = true);

    try {
      if (_attachments.length >= AttachmentService.maxFileCount) {
        _showError('最多只能上传${AttachmentService.maxFileCount}个文件');
        return;
      }

      final attachment = await _attachmentService.takePhoto();
      if (attachment != null) {
        _addAttachments([attachment]);
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isUploading = false);
    }
  }

  /// 选择文件
  Future<void> _pickFiles() async {
    if (!widget.enabled || _isUploading) return;

    setState(() => _isUploading = true);

    try {
      final remainingSlots = AttachmentService.maxFileCount - _attachments.length;
      if (remainingSlots <= 0) {
        _showError('最多只能上传${AttachmentService.maxFileCount}个文件');
        return;
      }

      final newAttachments = await _attachmentService.pickFiles(
        type: FileType.any,
      );

      if (newAttachments.isNotEmpty) {
        // 限制选择的文件数量
        final limitedAttachments = newAttachments.take(remainingSlots).toList();
        _addAttachments(limitedAttachments);
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isUploading = false);
    }
  }

  /// 添加附件
  void _addAttachments(List<AttachmentItem> newAttachments) {
    final updatedAttachments = [..._attachments, ...newAttachments];
    
    // 验证附件
    final validationError = AttachmentService.validateAttachments(updatedAttachments);
    if (validationError != null) {
      _showError(validationError);
      return;
    }

    setState(() {
      _attachments = updatedAttachments;
    });
    
    widget.onAttachmentsChanged(_attachments);
  }

  /// 删除附件
  void _removeAttachment(AttachmentItem attachment) {
    setState(() {
      _attachments.removeWhere((item) => item.id == attachment.id);
    });
    widget.onAttachmentsChanged(_attachments);
  }

  /// 显示错误信息
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: message.contains('权限') || message.contains('设置')
            ? SnackBarAction(
                label: '去设置',
                textColor: Colors.white,
                onPressed: () async {
                  final opened = await openAppSettings();
                  if (!opened) {
                    _showError('无法打开设置页面');
                  }
                },
              )
            : null,
      ),
    );
  }

  /// 获取总文件大小
  String get _totalSizeFormatted {
    final totalSize = _attachments.fold<int>(0, (sum, item) => sum + item.size);
    if (totalSize < 1024 * 1024) {
      return '${(totalSize / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(totalSize / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题和统计信息
        Row(
          children: [
            const Text(
              '附件',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            if (_attachments.isNotEmpty)
              Text(
                '${_attachments.length}/${AttachmentService.maxFileCount} • $_totalSizeFormatted',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // 附件列表
        if (_attachments.isNotEmpty) ...[
          _buildAttachmentList(),
          const SizedBox(height: 16),
        ],

        // 添加附件按钮
        if (_attachments.length < AttachmentService.maxFileCount)
          _buildAddAttachmentButton(),
      ],
    );
  }

  /// 构建附件列表
  Widget _buildAttachmentList() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _attachments.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: Colors.grey.shade200,
        ),
        itemBuilder: (context, index) {
          final attachment = _attachments[index];
          return _buildAttachmentItem(attachment);
        },
      ),
    );
  }

  /// 构建附件项
  Widget _buildAttachmentItem(AttachmentItem attachment) {
    return ListTile(
      leading: _buildAttachmentThumbnail(attachment),
      title: Text(
        attachment.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(attachment.sizeFormatted),
      trailing: widget.enabled
          ? IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: () => _removeAttachment(attachment),
              tooltip: '删除',
            )
          : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  /// 构建附件缩略图
  Widget _buildAttachmentThumbnail(AttachmentItem attachment) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: attachment.isImage
          ? _buildImageThumbnail(attachment)
          : Center(
              child: Text(
                AttachmentService.getFileIcon(attachment),
                style: const TextStyle(fontSize: 20),
              ),
            ),
    );
  }

  /// 构建图片缩略图
  Widget _buildImageThumbnail(AttachmentItem attachment) {
    if (kIsWeb || attachment.bytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.memory(
          attachment.bytes!,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
        ),
      );
    } else if (!kIsWeb && attachment.file != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          attachment.file!,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return const Center(
        child: Icon(Icons.image, color: Colors.grey),
      );
    }
  }

  /// 构建添加附件按钮
  Widget _buildAddAttachmentButton() {
    return InkWell(
      onTap: widget.enabled && !_isUploading ? _showAttachmentOptions : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: widget.enabled ? Colors.grey.shade400 : Colors.grey.shade300,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            if (_isUploading)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Icon(
                Icons.add,
                size: 32,
                color: widget.enabled ? Colors.grey.shade600 : Colors.grey.shade400,
              ),
            const SizedBox(height: 8),
            Text(
              _isUploading ? '上传中...' : '添加附件',
              style: TextStyle(
                color: widget.enabled ? Colors.grey.shade600 : Colors.grey.shade400,
                fontSize: 14,
              ),
            ),
            if (!_isUploading)
              Text(
                '支持图片、文档等格式',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }
}