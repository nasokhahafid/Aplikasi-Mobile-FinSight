import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:finsight/core/constants/app_design_system.dart';
import 'package:finsight/core/providers/dashboard_provider.dart';
import 'package:finsight/core/providers/theme_provider.dart';
import 'package:finsight/core/services/api_service.dart';
import 'package:finsight/features/auth/screens/login_screen.dart';

class PengaturanScreen extends StatefulWidget {
  const PengaturanScreen({super.key});

  @override
  State<PengaturanScreen> createState() => _PengaturanScreenState();
}

class _PengaturanScreenState extends State<PengaturanScreen> {
  bool _isNotificationEnabled = true;
  String _printerStatus = 'Belum terhubung';
  String _storeName = 'Toko FinSight';
  String _ownerName = 'Owner';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final dashboard = Provider.of<DashboardProvider>(context, listen: false);

    setState(() {
      _isNotificationEnabled = prefs.getBool('notifications') ?? true;
      _printerStatus = prefs.getString('printer') ?? 'Belum terhubung';

      // Use settings from provider if available
      _storeName =
          dashboard.appSettings['store_name'] ??
          prefs.getString('storeName') ??
          'Toko FinSight';
      _ownerName =
          dashboard.appSettings['owner_name'] ??
          prefs.getString('ownerName') ??
          'Owner';
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      prefs.setBool(key, value);
    } else if (value is String) {
      prefs.setString(key, value);
    }
  }

  Future<void> _backupData() async {
    try {
      final api = ApiService();
      final data = await api.exportData();
      final jsonString = jsonEncode(data);

      final directory = await getTemporaryDirectory();
      final file = File(
        '${directory.path}/FinSight_Backup_${DateTime.now().millisecondsSinceEpoch}.json',
      );
      await file.writeAsString(jsonString);

      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Backup Data FinSight - ${DateTime.now().toString()}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal backup: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _restoreData() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        final data = jsonDecode(content);

        if (data['data'] == null) {
          throw Exception('Format file backup tidak valid');
        }

        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Restore Data'),
            content: const Text(
              'Tindakan ini akan menimpa data saat ini. Lanjutkan?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Restore'),
              ),
            ],
          ),
        );

        if (confirm == true) {
          final api = ApiService();
          final success = await api.importData(data['data']);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  success
                      ? 'Data berhasil dipulihkan'
                      : 'Gagal memulihkan data',
                ),
                backgroundColor: success ? AppColors.success : AppColors.error,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal restore: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final dashboard = context.watch<DashboardProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pengaturan'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Store Profile Section
            Container(
              margin: const EdgeInsets.all(AppSpacing.lg),
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppRadius.xl2),
                boxShadow: AppShadow.lg,
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: AppShadow.md,
                    ),
                    child: CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white,
                      foregroundImage: NetworkImage(
                        'https://ui-avatars.com/api/?name=${Uri.encodeComponent(_storeName)}&background=random',
                      ),
                      child: const Icon(
                        Icons.store,
                        size: 32,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _storeName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _ownerName,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (dashboard.appSettings['store_address'] != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            dashboard.appSettings['store_address'],
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showEditProfileDialog(context),
                    icon: const Icon(Icons.edit_rounded, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                ],
              ),
            ),

            // Settings Groups
            _SettingsGroup(
              title: 'Tampilan & Aplikasi',
              children: [
                _SettingsTile(
                  icon: themeProvider.isDarkMode
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                  title: 'Mode Gelap',
                  subtitle: themeProvider.isDarkMode ? 'Aktif' : 'Nonaktif',
                  trailing: Switch.adaptive(
                    value: themeProvider.isDarkMode,
                    onChanged: (value) {
                      themeProvider.toggleTheme(value);
                    },
                    activeColor: AppColors.secondary,
                  ),
                ),
                _SettingsTile(
                  icon: Icons.language_rounded,
                  title: 'Bahasa',
                  subtitle: 'Indonesia',
                  onTap: () {},
                ),
                _SettingsTile(
                  icon: _isNotificationEnabled
                      ? Icons.notifications_active_rounded
                      : Icons.notifications_off_rounded,
                  title: 'Notifikasi',
                  subtitle: 'Transaksi & Stok',
                  trailing: Switch.adaptive(
                    value: _isNotificationEnabled,
                    onChanged: (value) {
                      setState(() => _isNotificationEnabled = value);
                      _saveSetting('notifications', value);
                    },
                    activeColor: AppColors.primary,
                  ),
                ),
              ],
            ),

            _SettingsGroup(
              title: 'Perangkat',
              children: [
                _SettingsTile(
                  icon: Icons.print_rounded,
                  title: 'Printer Thermal',
                  subtitle: _printerStatus,
                  onTap: () => _showPrinterDialog(context),
                ),
                _SettingsTile(
                  icon: Icons.qr_code_scanner_rounded,
                  title: 'Scanner Barcode',
                  subtitle: 'Kamera Bawaan',
                  onTap: () {},
                ),
              ],
            ),

            _SettingsGroup(
              title: 'Data & Keamanan',
              children: [
                _SettingsTile(
                  icon: Icons.backup_rounded,
                  title: 'Backup Data',
                  subtitle: 'Simpan data ke file JSON',
                  onTap: _backupData,
                ),
                _SettingsTile(
                  icon: Icons.restore_rounded,
                  title: 'Restore Data',
                  subtitle: 'Pulihkan data dari file backup',
                  onTap: _restoreData,
                ),
              ],
            ),

            _SettingsGroup(
              title: 'Lainnya',
              children: [
                _SettingsTile(
                  icon: Icons.info_outline_rounded,
                  title: 'Tentang Aplikasi',
                  onTap: () => _showAboutDialog(context),
                ),
                _SettingsTile(
                  icon: Icons.help_outline_rounded,
                  title: 'Bantuan & Support',
                  onTap: () {},
                ),
              ],
            ),

            // Logout Button
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: TextButton(
                onPressed: () => _showLogoutDialog(context),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    side: BorderSide(
                      color: AppColors.error.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout_rounded),
                    SizedBox(width: AppSpacing.md),
                    Text(
                      'Keluar Aplikasi',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.xl2),
              child: Text(
                'Versi 1.0.0 (Build 2025)',
                style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final dashboard = Provider.of<DashboardProvider>(context, listen: false);
    final storeController = TextEditingController(text: _storeName);
    final ownerController = TextEditingController(text: _ownerName);
    final addressController = TextEditingController(
      text: dashboard.appSettings['store_address'] ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profil Toko'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: storeController,
                decoration: const InputDecoration(labelText: 'Nama Toko'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: ownerController,
                decoration: const InputDecoration(labelText: 'Nama Pemilik'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Alamat Toko'),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newStoreName = storeController.text;
              final newOwnerName = ownerController.text;
              final newAddress = addressController.text;

              setState(() {
                _storeName = newStoreName;
                _ownerName = newOwnerName;
              });

              _saveSetting('storeName', _storeName);
              _saveSetting('ownerName', _ownerName);

              // Update to Server
              await dashboard.updateStoreSettings({
                'store_name': newStoreName,
                'owner_name': newOwnerName,
                'store_address': newAddress,
              });

              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showPrinterDialog(BuildContext context) {
    bool isScanning = true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Simulate scanning delay
            if (isScanning) {
              Future.delayed(const Duration(seconds: 2), () {
                if (context.mounted) {
                  setDialogState(() => isScanning = false);
                }
              });
            }

            return AlertDialog(
              title: const Text('Sambungkan Printer'),
              content: SizedBox(
                width: double.maxFinite,
                height: 200,
                child: isScanning
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Mencari perangkat...'),
                        ],
                      )
                    : ListView(
                        children: [
                          ListTile(
                            leading: const Icon(
                              Icons.print,
                              color: AppColors.textSecondary,
                            ),
                            title: const Text('RPP02N (Thermal)'),
                            subtitle: const Text('00:02:5B:00:15:10'),
                            onTap: () {
                              Navigator.pop(context);
                              setState(
                                () => _printerStatus = 'Terhubung (RPP02N)',
                              );
                              _saveSetting('printer', 'Terhubung (RPP02N)');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Printer berhasil terhubung!'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            },
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(
                              Icons.print,
                              color: AppColors.textSecondary,
                            ),
                            title: const Text('Epson TM-T82'),
                            subtitle: const Text('192.168.1.50'),
                            onTap: () {
                              Navigator.pop(context);
                              setState(
                                () =>
                                    _printerStatus = 'Terhubung (Epson TM-T82)',
                              );
                              _saveSetting(
                                'printer',
                                'Terhubung (Epson TM-T82)',
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Printer berhasil terhubung!'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Tutup'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        title: const Text('Konfirmasi Keluar'),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari aplikasi? Sesi Anda akan berakhir.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 48,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text(
                'FinSight',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Solusi Cerdas Keuangan UMKM',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xl),
              const Text(
                'Developed by DeepMind Team\n© 2025 All Rights Reserved',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Tutup'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsGroup({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: AppShadow.sm,
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0)
                  const Divider(
                    height: 1,
                    indent: 56, // Align with text
                  ),
                children[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: 4,
      ),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
          fontSize: 15,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            )
          : null,
      trailing:
          trailing ?? const Icon(Icons.chevron_right, color: AppColors.border),
      onTap: onTap,
    );
  }
}
