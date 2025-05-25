import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:workout_prediction_system_mobile/features/auth/providers/auth_provider.dart';
import 'package:workout_prediction_system_mobile/features/profile/providers/profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);

    if (profileState.status == ProfileStatus.loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final user = profileState.user;
    if (user == null) {
      // If user is null after loading, redirect to login
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('User not found')),
      );
    }

    // Set the initial value for name controller when not editing
    if (!_isEditing) {
      _nameController.text = user.name ?? '';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                // Save changes
                if (_formKey.currentState!.validate()) {
                  ref
                      .read(profileProvider.notifier)
                      .updateProfile(
                        userId: user.id,
                        name: _nameController.text,
                      );
                  setState(() {
                    _isEditing = false;
                  });
                }
              } else {
                // Enter edit mode
                setState(() {
                  _isEditing = true;
                });
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile picture with upload option
              _buildProfilePicture(context, profileState),
              const SizedBox(height: 24),

              // User details section
              _buildUserDetailsSection(context, profileState, user),
              const SizedBox(height: 32),

              // Notification settings section
              _buildNotificationSettingsSection(context),
              const SizedBox(height: 32),

              // Logout button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                onPressed: () {
                  // Sign out using profile provider
                  ref.read(profileProvider.notifier).signOut();

                  // Navigate back to the login page and clear all routes
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/', (route) => false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePicture(BuildContext context, ProfileState state) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Theme.of(context).primaryColor, width: 2),
          ),
          child: ClipOval(
            child:
                state.photoUrl != null
                    ? Image.network(
                      state.photoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) => const Icon(
                            Icons.person,
                            size: 80,
                            color: Colors.grey,
                          ),
                    )
                    : const Icon(Icons.person, size: 80, color: Colors.grey),
          ),
        ),
        GestureDetector(
          onTap: () => _showImagePicker(context),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            child:
                state.isUploading
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        color: Colors.white,
                      ),
                    )
                    : const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserDetailsSection(
    BuildContext context,
    ProfileState state,
    dynamic user,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account Information',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),

        // Name field
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Name',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
          readOnly: !_isEditing,
          validator: (value) {
            if (_isEditing && (value == null || value.isEmpty)) {
              return 'Please enter your name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Email field (non-editable)
        TextFormField(
          initialValue: user.email,
          decoration: const InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.email),
          ),
          readOnly: true,
        ),

        // Display any error messages
        if (state.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text(
              state.errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }

  Widget _buildNotificationSettingsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Settings', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        ListTile(
          leading: const Icon(Icons.notifications_active),
          title: const Text('Notification Settings'),
          subtitle: const Text('Manage your notification preferences'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.pushNamed(context, '/notification-settings');
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[700]!),
          ),
        ),
      ],
    );
  }

  Future<void> _showImagePicker(BuildContext context) async {
    final user = ref.read(profileProvider).user;
    if (user == null) return;

    final ImagePicker picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (image != null) {
                    ref
                        .read(profileProvider.notifier)
                        .uploadProfilePhoto(user.id, image.path);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.camera,
                  );
                  if (image != null) {
                    ref
                        .read(profileProvider.notifier)
                        .uploadProfilePhoto(user.id, image.path);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
