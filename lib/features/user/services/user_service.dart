import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tracklist_app/core/utils/notifiers.dart';
import 'package:tracklist_app/features/auth/models/app_user_class.dart';

final FirebaseFirestore firestore = FirebaseFirestore.instance;

Future<AppUser> getUserById({required String userId}) async {
  try {
    final userRef = firestore.collection("users").doc(userId);
    final userDoc = await userRef.get();

    if (!userDoc.exists) throw Exception("User does not exist in database");

    final user = userDoc.data() as Map<String, dynamic>;

    AppUser myUser = parseAppUser(userId, user);

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

Future<List<AppUser>> searchUsers(String name) async {
  try {
    if (name.isEmpty || name.trim().isEmpty) return [];

    // Convert to all lowercase
    name = name.toLowerCase();

    // Get last letter of name to use for query
    String end = name.substring(0, name.length - 1) + String.fromCharCode(name.codeUnitAt(name.length - 1) + 1);

    final usersRef = firestore.collection("users");

    // Query all users that start with the provided name
    final queryName = usersRef.where("username", isGreaterThanOrEqualTo: name).where("username", isLessThan: end);
    final queryDisplayName = usersRef
        .where("displayname", isGreaterThanOrEqualTo: name)
        .where("displayname", isLessThan: end);

    // Store query data results in list
    final users = await Future.wait([queryName.get(), queryDisplayName.get()]);

    List<AppUser> usersList = [];

    // If username query returned any results
    if (users[0].docs.isNotEmpty) {
      // Map query data to AppUser objects
      usersList.addAll(users[0].docs.map((doc) => parseAppUser(doc.id, doc.data())).toList());
    }
    if (users[1].docs.isNotEmpty) {
      // Map query data to AppUser objects
      usersList.addAll(users[1].docs.map((doc) => parseAppUser(doc.id, doc.data())).toList());
    }

    // Remove duplicate users
    usersList = usersList.toSet().toList();

    // Sort by display name, descending
    usersList.sort((a, b) => a.displayname.compareTo(b.displayname));

    return usersList;
  } catch (error) {
    throw Exception("Error searching users: $error");
  }
}

List<String> getAppUserFollowingUserIds() {
  if (authUser.value == null) return [];

  List<String> following = authUser.value!.following.map((e) => e).toList();

  return following;
}

Future<List<AppUser>> getFollowingByUserId(String userId) async {
  try {
    final userRef = firestore.collection("users").doc(userId);
    final userDoc = await userRef.get();

    if (!userDoc.exists) return [];

    // Get list of users that the provided user is following
    List<dynamic> followingIds = userDoc["following"].map((e) => e).toList();

    // Convert user ids to AppUser objects
    List<AppUser> followingUsers = await Future.wait(followingIds.map((uid) => getUserById(userId: uid)));

    // Sort by display name, descending
    followingUsers.sort((a, b) => a.displayname.compareTo(b.displayname));

    return followingUsers;
  } catch (error) {
    throw Exception("Error getting following: $error");
  }
}

Future<List<AppUser>> getFollowersByUserId(String userId) async {
  try {
    final userRef = firestore.collection("users").doc(userId);
    final userDoc = await userRef.get();

    if (!userDoc.exists) return [];

    // Get list of users that follow the provided user
    List<dynamic> followerIds = userDoc["followers"].map((e) => e).toList();

    // Convert user ids to AppUser objects
    List<AppUser> followerUsers = await Future.wait(followerIds.map((uid) => getUserById(userId: uid)));

    // Sort by display name, descending
    followerUsers.sort((a, b) => a.displayname.compareTo(b.displayname));

    return followerUsers;
  } catch (error) {
    throw Exception("Error getting followers: $error");
  }
}

Future<void> followUser({required String userId}) async {
  try {
    if (authUser.value == null) return;

    final userRef = firestore.collection("users").doc(userId);
    final userDoc = await userRef.get();

    if (!userDoc.exists) return;

    await userRef.update({
      "followers": FieldValue.arrayUnion([authUser.value!.uid]),
    });

    final authUserRef = firestore.collection("users").doc(authUser.value!.uid);
    final authUserDoc = await authUserRef.get();

    if (!authUserDoc.exists) return;

    await authUserRef.update({
      "following": FieldValue.arrayUnion([authUser.value!.uid]),
    });

    authUser.value!.following.add(userId);
  } catch (error) {
    throw Exception("Error following user: $error");
  }
}

Future<void> unfollowUser({required String userId}) async {
  try {
    if (authUser.value == null) return;

    final userRef = firestore.collection("users").doc(userId);
    final userDoc = await userRef.get();

    if (!userDoc.exists) return;

    await userRef.update({
      "followers": FieldValue.arrayRemove([authUser.value!.uid]),
    });

    final authUserRef = firestore.collection("users").doc(authUser.value!.uid);
    final authUserDoc = await authUserRef.get();

    if (!authUserDoc.exists) return;

    await authUserRef.update({
      "following": FieldValue.arrayRemove([authUser.value!.uid]),
    });

    authUser.value!.following.remove(userId);
  } catch (error) {
    throw Exception("Error unfollowing user: $error");
  }
}

Future<void> likeContent(String contentId, String category) async {
  try {
    final userlikesRef = firestore.collection("userlikes").doc(authUser.value!.uid);
    final userlikesDoc = await userlikesRef.get();

    // User does not have any likes, create new doc
    if (!userlikesDoc.exists) {
      await firestore.collection("userlikes").doc(authUser.value!.uid).set({
        "review": [],
        "artist": [],
        "album": [],
        "track": [],
      });

      // Add content to likes
      await userlikesRef.update({
        category: FieldValue.arrayUnion([contentId]),
      });
    } else {
      bool isLiked = userlikesDoc[category].contains(contentId);

      // User is unliking content, remove from likes
      if (isLiked) {
        await userlikesRef.update({
          category: FieldValue.arrayRemove([contentId]),
        });
      } else {
        await userlikesRef.update({
          category: FieldValue.arrayUnion([contentId]),
        });
      }
    }
  } catch (error) {
    throw Exception("Error liking content: $error");
  }
}

Future<void> unlikeContent(String contentId, String category, String userId) async {
  try {
    final userlikesRef = firestore.collection("userlikes").doc(userId);
    final userlikesDoc = await userlikesRef.get();

    // User does not have any likes, exit
    if (!userlikesDoc.exists) return;

    bool isLiked = userlikesDoc[category].contains(contentId);

    // User didn't already like content, exit
    if (!isLiked) return;

    // Remove content from likes
    await userlikesRef.update({
      category: FieldValue.arrayRemove([contentId]),
    });
  } catch (error) {
    throw Exception("Error liking content: $error");
  }
}

AppUser parseAppUser(String uid, Map<String, dynamic> user) {
  return AppUser.fromJson({
    'uid': uid,
    'email': user["email"],
    'username': user["username"],
    'displayname': user["displayname"],
    'created_at': user["createdAt"],
    'bio': user["bio"],
    'profile_url': user["profileUrl"],
    'following': user["following"],
    'followers': user["followers"],
  });
}
