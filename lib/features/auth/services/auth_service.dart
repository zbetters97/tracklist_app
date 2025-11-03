import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tracklist_app/features/auth/models/auth_user_class.dart';
import 'package:tracklist_app/core/constants/constants.dart';

// Holds the instance of the current user and the auth service
ValueNotifier<AuthService> authService = ValueNotifier(AuthService());
ValueNotifier<AuthUser?> authUser = ValueNotifier<AuthUser?>(null);

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

      // Create new user
      bool result = await createUser(email: email, displayname: displayname, username: username, uid: uid);

      return result;
    } catch (error) {
      throw Exception("Error creating user: $error");
    }
  }

  Future<bool> createUser({
    required String email,
    required String displayname,
    required String username,
    required String uid,
  }) async {
    try {
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

  Future<bool> signIn({required String email, required String password}) async {
    try {
      // Try to sign in user
      UserCredential userCredential = await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);

      // Get user document based on auth user uid
      String uid = userCredential.user!.uid;
      DocumentSnapshot userDoc = await firestore.collection("users").doc(uid).get();

      // If user document exists
      if (userDoc.exists) {
        // Store user data in map
        final data = userDoc.data() as Map<String, dynamic>;

        // Create new AuthUser object
        authUser.value = AuthUser.fromJson({
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
        firebaseAuth.signOut();
        throw Exception("User does not exist in database");
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

  Future<AuthUser> getUserById({required String userId}) async {
    try {
      final userRef = firestore.collection("users").doc(userId);
      final userDoc = await userRef.get();

      if (!userDoc.exists) throw Exception("User does not exist in database");

      final user = userDoc.data() as Map<String, dynamic>;

      AuthUser myUser = AuthUser.fromJson({
        'uid': userId,
        'email': user["email"],
        'username': user["username"],
        'displayname': user["displayname"],
        'created_at': user["createdAt"],
        'bio': user["bio"],
        'profile_url': user["profileUrl"],
        'following': user["following"],
        'followers': user["followers"],
      });

      return myUser;
    } catch (error) {
      throw Exception("Error getting user by id: $error");
    }
  }

  Future<String> getUsernameById({required String userId}) async {
    try {
      final userRef = firestore.collection("users").doc(userId);
      final userDoc = await userRef.get();

      if (!userDoc.exists) return "";

      final user = userDoc.data() as Map<String, dynamic>;
      return user["username"];
    } catch (error) {
      throw Exception("Error getting username by id: $error");
    }
  }

  List<String> getFollowingByUserId() {
    if (authUser.value == null) return [];

    List<String> following = authUser.value!.following.map((e) => e).toList();
    return following;
  }
}
