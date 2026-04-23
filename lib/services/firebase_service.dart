import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';

class FB {
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  // ─── Auth ───
  static User? get currentUser => _auth.currentUser;
  static Stream<User?> get authStream => _auth.authStateChanges();

  static Future<UserCredential> signIn(String email, String pass) =>
    _auth.signInWithEmailAndPassword(email: email, password: pass);

  static Future<UserCredential> register(String email, String pass) =>
    _auth.createUserWithEmailAndPassword(email: email, password: pass);

  static Future<void> signOut() => _auth.signOut();

  static Future<void> saveProfile(String uid, Map<String,dynamic> data) =>
    _db.collection('users').doc(uid).set(data, SetOptions(merge: true));

  static Future<Map<String,dynamic>?> getProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data();
  }

  // ─── Menu ───
  static Stream<List<MenuCategory>> categoriesStream() =>
    _db.collection('categories').orderBy('createdAt').snapshots().map(
      (s) => s.docs.map((d) => MenuCategory.fromMap(d.id, d.data())).toList());

  static Stream<List<MenuItem>> itemsStream() =>
    _db.collection('items').snapshots().map(
      (s) => s.docs.map((d) => MenuItem.fromMap(d.id, d.data())).toList());

  // ─── Offers ───
  static Stream<List<Offer>> offersStream() =>
    _db.collection('offers').snapshots().map(
      (s) => s.docs.map((d) => Offer.fromMap(d.id, d.data())).toList());

  // ─── Settings ───
  static Stream<Map<String,dynamic>> settingsStream() =>
    _db.collection('settings').doc('main').snapshots().map(
      (s) => s.data() ?? {});

  // ─── Orders ───
  static Future<DocumentReference> placeOrder(Map<String,dynamic> data) =>
    _db.collection('orders').add({...data, 'createdAt': FieldValue.serverTimestamp()});

  static Stream<List<AppOrder>> userOrdersStream(String uid) =>
    _db.collection('orders')
      .where('userId', isEqualTo: uid)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => AppOrder.fromMap(d.id, d.data())).toList());

  // ─── Reviews ───
  static Stream<List<Review>> reviewsStream() =>
    _db.collection('reviews').snapshots().map(
      (s) => s.docs.map((d) => Review.fromMap(d.id, d.data())).toList());
}
