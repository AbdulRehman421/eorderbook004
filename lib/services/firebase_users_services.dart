import 'package:Mini_Bill/models/user_model.dart';
import 'package:firebase_database/firebase_database.dart';
// import 'package:minipos/models/user_model.dart';

class FirebaseUsersServices {
  Future<List<User>> getUsers() async {
    DatabaseReference firebaseDbRef = FirebaseDatabase.instance.ref("users");
    DataSnapshot data = await firebaseDbRef.get();
    List<User> users = [];
    if (data.value != null) {
      Map<Object?, Object?> usersMap = data.value! as Map<Object?, Object?>;
      usersMap.forEach((key, value) {
        users.add(User.fromMap(value as Map<Object?, Object?>));
      });
    }
    return users;
  }
}
