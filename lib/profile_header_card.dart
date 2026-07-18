import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfileHeaderCard extends StatelessWidget {
  final String operatorName;
  final String userId;
  final String greeting;
  final String? profileImage;
  final String? coverImage;

  const ProfileHeaderCard({
    super.key,
    required this.operatorName,
    required this.userId,
    required this.greeting,
    this.profileImage,
    this.coverImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  image: coverImage != null && coverImage!.isNotEmpty
                      ? DecorationImage(
                          image: FileImage(File(coverImage!)),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
              ),
              Positioned(
                left: 12,
                bottom: -32,
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 29,
                    backgroundImage:
                        profileImage != null && profileImage!.isNotEmpty
                            ? FileImage(File(profileImage!))
                            : null,
                    child: profileImage == null || profileImage!.isEmpty
                        ? const Icon(Icons.person, size: 30)
                        : null,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 38),

          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              greeting,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              operatorName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ID: $userId',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 4),
                InkWell(
                  onTap: () async {
                    await Clipboard.setData(
                      ClipboardData(text: userId),
                    );
                  },
                  child: const Icon(
                    Icons.content_copy,
                    size: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
