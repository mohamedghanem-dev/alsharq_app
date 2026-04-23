import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';
import '../widgets/app_theme.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        title: const Text('طلباتي', style: TextStyle(fontWeight: FontWeight.w900, color: AppTheme.textColor)),
        centerTitle: true,
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Divider(height: 1, color: AppTheme.border)),
      ),
      body: uid == null
        ? const Center(child: Text('سجل دخول لمشاهدة طلباتك', style: TextStyle(color: AppTheme.muted)))
        : StreamBuilder(
            stream: FB.userOrdersStream(uid),
            builder: (_, snap) {
              if (snap.connectionState == ConnectionState.waiting)
                return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
              final orders = snap.data ?? [];
              if (orders.isEmpty) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.receipt_long_outlined, size: 64, color: AppTheme.muted.withOpacity(0.3)),
                const SizedBox(height: 12),
                const Text('لا توجد طلبات بعد', style: TextStyle(color: AppTheme.muted, fontSize: 16)),
              ]));
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: orders.length,
                itemBuilder: (_, i) {
                  final o = orders[i];
                  final color = kStatusColors[o.status] ?? AppTheme.muted;
                  final label = kStatusLabels[o.status] ?? o.status;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: color.withOpacity(0.3)),
                    ),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      title: Row(children: [
                        Text('#${o.id.substring(o.id.length > 6 ? o.id.length - 6 : 0).toUpperCase()}',
                          style: const TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.w900)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
                        ),
                      ]),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(children: [
                          Text('${o.total.toStringAsFixed(0)} ج.م',
                            style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w900, fontSize: 15)),
                          const Spacer(),
                          if (o.createdAt != null)
                            Text('${o.createdAt!.hour}:${o.createdAt!.minute.toString().padLeft(2,'0')}',
                              style: const TextStyle(color: AppTheme.muted, fontSize: 11)),
                        ]),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Divider(color: AppTheme.border),
                            ...((o.items as List).map((item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              child: Row(children: [
                                Text(item['name'] ?? '', style: const TextStyle(color: AppTheme.textColor, fontSize: 13)),
                                const Spacer(),
                                Text('× ${item['qty'] ?? 1}', style: const TextStyle(color: AppTheme.muted, fontSize: 12)),
                              ]),
                            ))),
                            if (o.address != null) ...[
                              const SizedBox(height: 8),
                              Row(children: [
                                const Icon(Icons.location_on_outlined, color: AppTheme.muted, size: 14),
                                const SizedBox(width: 4),
                                Text(o.address!, style: const TextStyle(color: AppTheme.muted, fontSize: 12)),
                              ]),
                            ],
                          ]),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
    );
  }
}
