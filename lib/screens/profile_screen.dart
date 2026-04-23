import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';
import '../widgets/app_theme.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        title: const Text('بروفايلي', style: TextStyle(fontWeight: FontWeight.w900, color: AppTheme.textColor)),
        centerTitle: true,
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Divider(height: 1, color: AppTheme.border)),
      ),
      body: user == null
        ? _notLoggedIn(context)
        : FutureBuilder(
            future: FB.getProfile(user.uid),
            builder: (_, snap) {
              final profile = snap.data ?? {};
              final fname = profile['fname'] ?? 'مستخدم';
              final lname = profile['lname'] ?? '';
              final email = user.email ?? profile['email'] ?? '';
              final phone = profile['phone'] ?? '';
              final initials = ((fname.isNotEmpty ? fname[0] : '') + (lname.isNotEmpty ? lname[0] : '')).toUpperCase();

              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Avatar
                  Center(child: Column(children: [
                    Container(
                      width: 90, height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppTheme.gradient,
                        boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 20)],
                      ),
                      child: Center(child: Text(initials.isEmpty ? '👤' : initials,
                        style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900))),
                    ),
                    const SizedBox(height: 12),
                    Text('$fname $lname'.trim(),
                      style: const TextStyle(color: AppTheme.textColor, fontSize: 20, fontWeight: FontWeight.w900)),
                    if (email.isNotEmpty)
                      Text(email, style: const TextStyle(color: AppTheme.muted, fontSize: 13)),
                  ])),
                  const SizedBox(height: 24),

                  // Info card
                  _card([
                    if (phone.isNotEmpty) _row(Icons.phone_outlined, 'الهاتف', phone),
                    if (email.isNotEmpty) _row(Icons.email_outlined, 'البريد', email),
                    _row(Icons.calendar_today_outlined, 'تاريخ الانضمام', profile['joined'] ?? '—'),
                  ]),
                  const SizedBox(height: 14),

                  // Restaurant info
                  StreamBuilder(
                    stream: FB.settingsStream(),
                    builder: (_, snap) {
                      if (!snap.hasData) return const SizedBox.shrink();
                      final s = snap.data!;
                      final whatsapp = s['whatsapp'] ?? '';
                      final phone2 = s['phone'] ?? '';
                      return _card([
                        const Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Text('بيانات المطعم', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w900))),
                        if (phone2.isNotEmpty) _row(Icons.phone_outlined, 'الهاتف', phone2),
                        if (whatsapp.isNotEmpty) _row(Icons.chat_outlined, 'واتساب', whatsapp),
                        if (s['address'] != null) _row(Icons.location_on_outlined, 'العنوان', s['address']),
                      ]);
                    },
                  ),
                  const SizedBox(height: 14),

                  // Reviews
                  StreamBuilder(
                    stream: FB.reviewsStream(),
                    builder: (_, snap) {
                      if (!snap.hasData || snap.data!.isEmpty) return const SizedBox.shrink();
                      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('تقييمات العملاء', style: TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.w900, fontSize: 15)),
                        const SizedBox(height: 10),
                        ...snap.data!.map((r) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.border)),
                          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Container(
                              width: 38, height: 38,
                              decoration: BoxDecoration(shape: BoxShape.circle, gradient: AppTheme.gradient),
                              child: Center(child: Text(r.name[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)))),
                            const SizedBox(width: 10),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(r.name, style: const TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.w800)),
                              Text('⭐' * r.stars, style: const TextStyle(fontSize: 12)),
                              if (r.comment != null) Text(r.comment!, style: const TextStyle(color: AppTheme.muted, fontSize: 12)),
                            ])),
                          ]),
                        )),
                      ]);
                    },
                  ),

                  const SizedBox(height: 20),
                  // Logout
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.red,
                      side: BorderSide(color: AppTheme.red.withOpacity(0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      await FB.signOut();
                      if (context.mounted) Navigator.pushAndRemoveUntil(context,
                        MaterialPageRoute(builder: (_) => const AuthScreen()), (_) => false);
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('تسجيل الخروج', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(height: 80),
                ],
              );
            },
          ),
    );
  }

  Widget _notLoggedIn(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.person_outline, size: 64, color: AppTheme.muted.withOpacity(0.3)),
      const SizedBox(height: 12),
      const Text('غير مسجل', style: TextStyle(color: AppTheme.muted, fontSize: 16)),
      const SizedBox(height: 16),
      ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthScreen())),
        child: const Text('تسجيل الدخول', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    ]),
  );

  Widget _card(List<Widget> children) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppTheme.border)),
    child: Column(children: children),
  );

  Widget _row(IconData icon, String label, String val) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(children: [
      Icon(icon, color: AppTheme.primary, size: 18),
      const SizedBox(width: 10),
      Text(label, style: const TextStyle(color: AppTheme.muted, fontSize: 12)),
      const Spacer(),
      Text(val, style: const TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.w600, fontSize: 13)),
    ]),
  );
}
