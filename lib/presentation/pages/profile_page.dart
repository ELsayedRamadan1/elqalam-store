import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../../core/themes/app_theme.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/blocs/auth/auth_event.dart';
import '../../presentation/blocs/auth/auth_state.dart' as app_auth;
import '../../presentation/blocs/theme/theme_bloc.dart';
import '../../presentation/blocs/theme/theme_event.dart';
import '../../presentation/blocs/theme/theme_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _selectedImage;
  bool _isEditingPhone = false;
  bool _isEditingAddress = false;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final permission = source == ImageSource.camera
          ? await Permission.camera.request()
          : await Permission.photos.request();

      if (!permission.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('يجب منح الإذن للوصول إلى الصور')),
          );
        }
        return;
      }

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null && mounted) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });

        // TODO: Upload to Supabase Storage and update profile
        // For now, just show a message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('سيتم رفع الصورة قريباً')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: $e')),
        );
      }
    }
  }

  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('اختر مصدر الصورة', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('الكاميرا'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('المعرض'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateProfileField(String field, String value) async {
    final authState = context.read<AuthBloc>().state;
    if (authState.user == null) return;

    try {
      Map<String, String> updates = {};
      if (field == 'phone') {
        updates['phone'] = value;
      } else if (field == 'address') {
        updates['address'] = value;
      }

      context.read<AuthBloc>().add(UpdateProfileEvent(
        phone: field == 'phone' ? value : null,
        address: field == 'address' ? value : null,
      ));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ التغييرات')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, app_auth.AuthState>(
      builder: (context, authState) {
        if (authState.user == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_outline,
                      size: 50, color: AppColors.primaryLight),
                ),
                const SizedBox(height: 20),
                const Text('يرجى تسجيل الدخول',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('لعرض بياناتك وطلباتك',
                    style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => context.go('/login'),
                  icon: const Icon(Icons.login),
                  label: const Text('تسجيل الدخول'),
                ),
              ],
            ),
          );
        }

        final user = authState.user!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Profile header
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _showImagePickerDialog,
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 45,
                                backgroundColor: Colors.white.withOpacity(0.3),
                                backgroundImage: _selectedImage != null
                                    ? FileImage(_selectedImage!)
                                    : user.avatarUrl != null
                                        ? CachedNetworkImageProvider(user.avatarUrl!)
                                        : null,
                                child: _selectedImage == null && user.avatarUrl == null
                                    ? Text(
                                        user.name.isNotEmpty
                                            ? user.name[0].toUpperCase()
                                            : '؟',
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      )
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Contact Info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _EditableInfoTile(
                        icon: Icons.email_outlined,
                        title: 'البريد الإلكتروني',
                        value: user.email,
                        editable: false,
                      ),
                      const Divider(height: 1, indent: 56),
                      _EditableInfoTile(
                        icon: Icons.phone_outlined,
                        title: 'رقم الهاتف',
                        value: user.phone ?? 'لم يتم تحديده',
                        editable: true,
                        isEditing: _isEditingPhone,
                        controller: _phoneController,
                        onEdit: () {
                          setState(() {
                            _isEditingPhone = true;
                            _phoneController.text = user.phone ?? '';
                          });
                        },
                        onSave: () {
                          _updateProfileField('phone', _phoneController.text.trim());
                          setState(() {
                            _isEditingPhone = false;
                          });
                        },
                        onCancel: () {
                          setState(() {
                            _isEditingPhone = false;
                            _phoneController.clear();
                          });
                        },
                      ),
                      const Divider(height: 1, indent: 56),
                      _EditableInfoTile(
                        icon: Icons.location_on_outlined,
                        title: 'العنوان',
                        value: user.address ?? 'لم يتم تحديده',
                        editable: true,
                        isEditing: _isEditingAddress,
                        controller: _addressController,
                        onEdit: () {
                          setState(() {
                            _isEditingAddress = true;
                            _addressController.text = user.address ?? '';
                          });
                        },
                        onSave: () {
                          _updateProfileField('address', _addressController.text.trim());
                          setState(() {
                            _isEditingAddress = false;
                          });
                        },
                        onCancel: () {
                          setState(() {
                            _isEditingAddress = false;
                            _addressController.clear();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Settings
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      BlocBuilder<ThemeBloc, ThemeState>(
                        builder: (context, themeState) {
                          return ListTile(
                            leading: Icon(
                              themeState.isDarkMode
                                  ? Icons.light_mode
                                  : Icons.dark_mode,
                              color: AppColors.primary,
                            ),
                            title: Text(themeState.isDarkMode ? 'الوضع الفاتح' : 'الوضع المظلم'),
                            trailing: Switch(
                              value: themeState.isDarkMode,
                              onChanged: (value) {
                                context.read<ThemeBloc>().add(ToggleThemeEvent());
                              },
                              activeColor: AppColors.primary,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Logout
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        title: const Text('تسجيل الخروج',
                            textAlign: TextAlign.center),
                        content: const Text('هل أنت متأكد من تسجيل الخروج؟',
                            textAlign: TextAlign.center),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('إلغاء'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.error),
                            onPressed: () {
                              Navigator.pop(ctx);
                              context.read<AuthBloc>().add(LogoutEvent());
                              context.go('/');
                            },
                            child: const Text('خروج'),
                          ),
                        ],
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.logout),
                  label: const Text('تسجيل الخروج',
                      style: TextStyle(fontSize: 16)),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}

class _EditableInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool editable;
  final bool isEditing;
  final TextEditingController? controller;
  final VoidCallback? onEdit;
  final VoidCallback? onSave;
  final VoidCallback? onCancel;

  const _EditableInfoTile({
    required this.icon,
    required this.title,
    required this.value,
    this.editable = false,
    this.isEditing = false,
    this.controller,
    this.onEdit,
    this.onSave,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title,
          style: const TextStyle(
              fontSize: 12, color: AppColors.textSecondary)),
      subtitle: isEditing
          ? TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            )
          : Text(
              value,
              style: TextStyle(
                color: value == 'لم يتم تحديده'
                    ? AppColors.textSecondary
                    : AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
      trailing: editable
          ? isEditing
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: AppColors.success),
                      onPressed: onSave,
                      iconSize: 20,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.error),
                      onPressed: onCancel,
                      iconSize: 20,
                    ),
                  ],
                )
              : IconButton(
                  icon: const Icon(Icons.edit, color: AppColors.primary),
                  onPressed: onEdit,
                  iconSize: 20,
                )
          : null,
      onTap: editable && !isEditing ? onEdit : null,
    );
  }
}
