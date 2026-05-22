import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/member_management_controller.dart';
import '../../models/index.dart';
import '../../widgets/index.dart';

class MemberManagementScreen extends StatelessWidget {
  const MemberManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MemberManagementController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Member Management'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: CustomTextField(
              label: 'Search Members',
              hint: 'Enter name, ID, or phone number',
              prefixIcon: Icons.search,
              onChanged: (query) => controller.searchMembers(query),
            ),
          ),
          Expanded(
            child: Obx(
              () => controller.isLoading.value
                  ? const LoadingWidget()
                  : controller.filteredMembers.isEmpty
                      ? const EmptyStateWidget(
                          title: 'No Members Found',
                          subtitle: 'Start by adding a new member',
                          icon: Icons.person_outline,
                        )
                      : ListView.builder(
                          itemCount: controller.filteredMembers.length,
                          itemBuilder: (context, index) {
                            final member = controller.filteredMembers[index];
                            return _buildMemberCard(context, member, controller);
                          },
                        ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.snackbar('UI Preview', 'Form tambah member belum diaktifkan.');
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMemberCard(
    BuildContext context,
    Member member,
    MemberManagementController controller,
  ) {
    final isExpired = member.isExpired;
    final daysUntilExpiry = member.daysUntilExpiry;

    return CustomCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      onTap: () {
        Get.snackbar('UI Preview', 'Detail member belum diaktifkan.');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Member Photo or Avatar
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.withValues(alpha: 0.2),
                ),
                child: member.photoPath != null
                    ? Image.asset(member.photoPath!)
                    : Center(
                        child: Text(
                          member.name.isNotEmpty ? member.name[0].toUpperCase() : 'M',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              // Member Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      member.memberId,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          isExpired ? Icons.error : Icons.check_circle,
                          color: isExpired ? Colors.red : Colors.green,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isExpired
                              ? 'Expired'
                              : 'Expires in $daysUntilExpiry days',
                          style: TextStyle(
                            fontSize: 12,
                            color: isExpired ? Colors.red : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Action Buttons
              PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('Edit'),
                  ),
                  const PopupMenuItem(
                    value: 'renew',
                    child: Text('Renew Membership'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'edit') {
                    Get.snackbar('UI Preview', 'Form edit member belum diaktifkan.');
                  } else if (value == 'renew') {
                    Get.snackbar('UI Preview', 'Renew membership belum diaktifkan.');
                  } else if (value == 'delete') {
                    Get.dialog(
                      AlertDialog(
                        title: const Text('Delete Member'),
                        content: const Text('Are you sure you want to delete this member?'),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              controller.deleteMember(member.id ?? 0);
                              Get.back();
                            },
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                member.phoneNumber,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                member.isActive ? 'Active' : 'Inactive',
                style: TextStyle(
                  fontSize: 12,
                  color: member.isActive ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Custom Card with margin
class CustomCardWithMargin extends StatelessWidget {
  final Widget child;
  final EdgeInsets margin;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final double? elevation;
  final GestureTapCallback? onTap;

  const CustomCardWithMargin({
    super.key,
    required this.child,
    this.margin = const EdgeInsets.all(0),
    this.backgroundColor,
    this.padding,
    this.elevation,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Card(
        color: backgroundColor ?? Colors.white,
        elevation: elevation ?? 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: GestureDetector(
          onTap: onTap,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}
