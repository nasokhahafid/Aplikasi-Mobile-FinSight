import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:finsight/core/constants/app_design_system.dart';
import 'package:finsight/core/models/user_model.dart';
import 'package:finsight/core/providers/dashboard_provider.dart';

class StaffScreen extends StatelessWidget {
  const StaffScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context);
    final staffList = provider.staff;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Manajemen Staff'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => provider.fetchStaff(),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  // Summary Cards
                  Row(
                    children: [
                      Expanded(
                        child: _StaffSummaryCard(
                          label: 'Total Staff',
                          value: '${staffList.length}',
                          icon: Icons.people_alt_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _StaffSummaryCard(
                          label: 'Aktif',
                          value: '${staffList.where((s) => s.isActive).length}',
                          icon: Icons.check_circle_rounded,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Staff List
                  staffList.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Text('Belum ada staff'),
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                            border: Border.all(color: AppColors.borderLight),
                            boxShadow: AppShadow.sm,
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: staffList.length,
                            separatorBuilder: (context, index) =>
                                const Divider(height: 1, indent: 72),
                            itemBuilder: (context, index) {
                              final staff = staffList[index];
                              final isOwner =
                                  staff.role.toLowerCase() == 'admin' ||
                                  staff.role.toLowerCase() == 'owner';
                              final isKasir =
                                  staff.role.toLowerCase() == 'cashier' ||
                                  staff.role.toLowerCase() == 'kasir';

                              Color roleColor = AppColors.textSecondary;
                              Color roleBg = AppColors.surfaceVariant;

                              if (isOwner) {
                                roleColor = AppColors.primary;
                                roleBg = AppColors.primary.withValues(
                                  alpha: 0.1,
                                );
                              } else if (isKasir) {
                                roleColor = AppColors.secondary;
                                roleBg = AppColors.secondary.withValues(
                                  alpha: 0.1,
                                );
                              }

                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.lg,
                                  vertical: AppSpacing.sm,
                                ),
                                leading: CircleAvatar(
                                  radius: 20,
                                  backgroundColor: isOwner
                                      ? AppColors.primary
                                      : AppColors.accent,
                                  foregroundColor: Colors.white,
                                  child: Text(
                                    staff.name
                                        .substring(
                                          0,
                                          staff.name.length > 2
                                              ? 2
                                              : staff.name.length,
                                        )
                                        .toUpperCase(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        staff.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    // Status Dot
                                    if (staff.isActive)
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: AppColors.secondary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    staff.email,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: roleBg,
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.full,
                                    ),
                                  ),
                                  child: Text(
                                    staff.role.toUpperCase(),
                                    style: TextStyle(
                                      color: roleColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  _showStaffDetail(context, staff);
                                },
                              );
                            },
                          ),
                        ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showStaffForm(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Tambah Staff'),
      ),
    );
  }

  void _showStaffForm(BuildContext context, [UserModel? staff]) {
    showDialog(
      context: context,
      builder: (context) => _StaffFormDialog(staff: staff),
    );
  }

  void _showStaffDetail(BuildContext context, UserModel staff) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl2),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    child: Text(
                      staff.name
                          .substring(
                            0,
                            staff.name.length > 2 ? 2 : staff.name.length,
                          )
                          .toUpperCase(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    staff.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    staff.role.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl2),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _showStaffForm(context, staff);
                          },
                          child: const Text('Edit Profil'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final provider = Provider.of<DashboardProvider>(
                              context,
                              listen: false,
                            );
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Hapus Staff'),
                                content: Text('Hapus ${staff.name}?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Batal'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text('Hapus'),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true && context.mounted) {
                              await provider.deleteStaff(staff.id);
                              if (context.mounted) Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                          ),
                          child: const Text('Hapus Staff'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StaffSummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StaffSummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppShadow.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StaffFormDialog extends StatefulWidget {
  final UserModel? staff;

  const _StaffFormDialog({this.staff});

  @override
  State<_StaffFormDialog> createState() => _StaffFormDialogState();
}

class _StaffFormDialogState extends State<_StaffFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late String _selectedRole;
  late bool _isActive;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.staff?.name);
    _emailController = TextEditingController(text: widget.staff?.email);
    _passwordController = TextEditingController();
    _selectedRole = widget.staff?.role ?? 'cashier';
    _isActive = widget.staff?.isActive ?? true;
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.staff != null;

    return AlertDialog(
      title: Text(isEdit ? 'Edit Staff' : 'Tambah Staff Baru'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              if (!isEdit) ...[
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 16),
              ],
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(labelText: 'Role'),
                items: const [
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  DropdownMenuItem(value: 'cashier', child: Text('Cashier')),
                ],
                onChanged: (v) => setState(() => _selectedRole = v!),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Status Aktif'),
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleSubmit,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Simpan'),
        ),
      ],
    );
  }

  void _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final provider = Provider.of<DashboardProvider>(context, listen: false);

      final data = {
        'name': _nameController.text,
        'email': _emailController.text,
        'role': _selectedRole,
        'is_active': _isActive,
      };

      if (widget.staff == null && _passwordController.text.isNotEmpty) {
        data['password'] = _passwordController.text;
      }

      bool success;
      if (widget.staff != null) {
        success = await provider.updateStaff(widget.staff!.id, data);
      } else {
        success = await provider.addStaff(data);
      }

      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success ? 'Berhasil' : 'Gagal'),
              backgroundColor: success ? AppColors.success : AppColors.error,
            ),
          );
        }
      }
    }
  }
}
