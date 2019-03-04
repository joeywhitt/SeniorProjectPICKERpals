import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:senior_project_pickerpal/model/Items.dart';
 
final CollectionReference itemCollection = Firestore.instance.collection('Items');
 
class FirebaseFirestoreService {
 
  static final FirebaseFirestoreService _instance = new FirebaseFirestoreService.internal();
 
  factory FirebaseFirestoreService() => _instance;
 
  FirebaseFirestoreService.internal();
 
  Future<Items> createItems(String title, String description) async {
    final TransactionHandler createTransaction = (Transaction tx) async {
      final DocumentSnapshot ds = await tx.get(itemCollection.document());
 
      final Items item = new Items(ds.documentID, title, description);
      final Map<String, dynamic> data = item.toMap();
 
      await tx.set(ds.reference, data);
 
      return data;
    };
 
    return Firestore.instance.runTransaction(createTransaction).then((mapData) {
      return Items.fromMap(mapData);
    }).catchError((error) {
      print('error: $error');
      return null;
    });
  }
 
  Stream<QuerySnapshot> getItemsList({int offset, int limit}) {
    Stream<QuerySnapshot> snapshots = itemCollection.snapshots();
 
    if (offset != null) {
      snapshots = snapshots.skip(offset);
    }
 
    if (limit != null) {
      snapshots = snapshots.take(limit);
    }
 
    return snapshots;
  }
 
  Future<dynamic> updateItems(Items item) async {
    final TransactionHandler updateTransaction = (Transaction tx) async {
      final DocumentSnapshot ds = await tx.get(itemCollection.document(item.id));
 
      await tx.update(ds.reference, item.toMap());
      return {'updated': true};
    };
 
    return Firestore.instance
        .runTransaction(updateTransaction)
        .then((result) => result['updated'])
        .catchError((error) {
      print('error: $error');
      return false;
    });
  }
 
  Future<dynamic> deleteItems(String id) async {
    final TransactionHandler deleteTransaction = (Transaction tx) async {
      final DocumentSnapshot ds = await tx.get(itemCollection.document(id));
 
      await tx.delete(ds.reference);
      return {'deleted': true};
    };
 
    return Firestore.instance
        .runTransaction(deleteTransaction)
        .then((result) => result['deleted'])
        .catchError((error) {
      print('error: $error');
      return false;
    });
  }
}