import 'package:firebase_database/firebase_database.dart';

class FirebasedatabaseService {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();

  // Write data to the database
  Future<void> writeData(String path, Map<String, dynamic> data) async {
    await _databaseReference.child(path).set(data);
  }

  //  Read data from the database
  Future<DataSnapshot> readData(String path) async {
    return await _databaseReference.child(path).get();
  }

  // Update data in the database
  Future<void> updateData(String path, Map<String, dynamic> data) async {
    await _databaseReference.child(path).update(data);
  }

  // Delate data form the database
  Future<void> deleteData(String path) async {
    await _databaseReference.child(path).remove();
  }

  // Listen for realtime updates
  Stream<DatabaseEvent> listenToData(String path) {
    return _databaseReference.child(path).onValue;
  }
}
