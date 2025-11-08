import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tracklist_app/core/utils/notifiers.dart';
import 'package:tracklist_app/features/user/models/app_user_class.dart';
import 'package:tracklist_app/core/constants/constants.dart';

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // The currently logged in user
  User? get currentUser => firebaseAuth.currentUser;

  // Stream of user changes
  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();

  Future<bool> signUp({
    required String email,
    required String password,
    required String displayname,
    required String username,
  }) async {
    try {
      // Create new auth user
      UserCredential newUserCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Capture generated uid
      String uid = newUserCredential.user!.uid;

      Map<String, dynamic> newUserData = {
        "email": email.toLowerCase(),
        "displayname": displayname.toLowerCase(),
        "username": username.toLowerCase(),
        "bio": "",
        "profileUrl": DEFAULT_PROFILE_IMG,
        "spotifyUrl": "",
        "following": [],
        "followers": [],
        "notifications": 0,
        "createdAt": FieldValue.serverTimestamp(),
      };

      // Create user document in Firestore
      await firestore.collection("users").doc(uid).set(newUserData);

      return true;
    } catch (error) {
      throw Exception("Error creating user: $error");
    }
  }

  Future<String> signIn({required String email, required String password}) async {
    try {
      // Try to sign in user
      UserCredential userCredential = await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);

      if (await getAuthUser(userCredential.user!)) {
        return "Success!";
      } else {
        return "Error!";
      }
    } catch (error) {
      if (error.toString().contains("user-not-found") || error.toString().contains("wrong-password")) {
        return "Error: Incorrect email or password";
      } else {
        return "Error signing in: $error";
      }
    }
  }

  Future<bool> getAuthUser(User user) async {
    try {
      String uid = user.uid;
      DocumentSnapshot userDoc = await firestore.collection("users").doc(uid).get();

      // If user document exists
      if (userDoc.exists) {
        // Store user data in map
        final data = userDoc.data() as Map<String, dynamic>;

        // Create new AppUser object
        authUser.value = AppUser.fromJson({
          'uid': uid,
          'email': data["email"],
          'username': data["username"],
          'displayname': data["displayname"],
          'created_at': data["createdAt"],
          'bio': data["bio"],
          'profile_url': data["profileUrl"],
          'following': data["following"],
          'followers': data["followers"],
        });

        return true;
      } else {
        return false;
      }
    } catch (error) {
      throw Exception("Error signing in: $error");
    }
  }

  Future<void> signOut() async {
    await firebaseAuth.signOut();
    authUser.value = null;
  }

  Future<bool> checkIfEmailExists({required String email}) async {
    final userRef = firestore.collection("users");
    final querySnapshot = await userRef.where("email", isEqualTo: email).get();

    if (querySnapshot.docs.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> sendPasswordReset({required String email}) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
      return true;
    } catch (error) {
      return false;
    }
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String email,
  }) async {
    AuthCredential credential = EmailAuthProvider.credential(email: email, password: currentPassword);
    await currentUser!.reauthenticateWithCredential(credential);

    await currentUser!.updatePassword(newPassword);
  }

  Future<void> updateUsername({required String username}) async {
    await currentUser!.updateDisplayName(username);
  }

  Future<void> deleteAccount({required String email, required String password}) async {
    AuthCredential credential = EmailAuthProvider.credential(email: email, password: password);
    await currentUser!.reauthenticateWithCredential(credential);

    await currentUser!.delete();
    await firebaseAuth.signOut();

    authUser.value = null;
  }
}
