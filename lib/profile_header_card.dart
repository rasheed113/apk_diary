import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfileHeaderCard extends StatelessWidget {
  final String operatorName;
  final String userId;
  final String greeting;
  final String? profileImage;
  final String? coverImage;
  final VoidCallback? onProfileTap;
  final VoidCallback? onCoverTap;

  const ProfileHeaderCard({
    super.key,
    required this.operatorName,
    required this.userId,
    required this.greeting,
    this.profileImage,
    this.coverImage,
    this.onProfileTap,
    this.onCoverTap,
  });

  ImageProvider<Object>? _imageProvider(String? path) {
    if (path == null || path.isEmpty) return null;
    return File(path).existsSync() ? FileImage(File(path)) : null;
  }

  @override
  Widget build(BuildContext context) {
    final coverProvider = _imageProvider(coverImage);
    final profileProvider = _imageProvider(profileImage);
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onTap: onCoverTap,
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: scheme.primaryContainer,
                    image: coverProvider == null
                        ? null
                        : DecorationImage(image: coverProvider, fit: BoxFit.cover),
                    border: Border.all(color: scheme.primary.withValues(alpha: 0.18)),
                  ),
                ),
              ),
              Positioned(
                left: 12,
                bottom: -32,
                child: GestureDetector(
                  onTap: onProfileTap,
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: scheme.surface,
                    child: CircleAvatar(
                      radius: 29,
                      backgroundImage: profileProvider,
                      backgroundColor: scheme.primaryContainer,
                      child: profileProvider == null
                          ? const Icon(Icons.person, size: 30)
                          : null,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 38),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(greeting, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(operatorName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('ID: $userId', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(width: 4),
                InkWell(
                  onTap: () => Clipboard.setData(ClipboardData(text: userId)),
                  child: const Icon(Icons.content_copy, size: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
