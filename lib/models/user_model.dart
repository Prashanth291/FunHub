class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final int xp;
  final int streak;

  UserModel({required this.uid, required this.email, this.displayName, this.xp = 0, this.streak = 0});
}
