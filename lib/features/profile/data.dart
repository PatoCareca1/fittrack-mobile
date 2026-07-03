import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/providers.dart';

class ProfileData {
  const ProfileData({
    this.birthDate,
    this.sex,
    this.heightCm,
    this.goal,
    this.activityLevel,
  });

  final String? birthDate; // yyyy-MM-dd
  final String? sex; // M | F
  final num? heightCm;
  final String? goal;
  final String? activityLevel;

  factory ProfileData.fromJson(Map<String, dynamic> json) => ProfileData(
        birthDate: json['birth_date'] as String?,
        sex: json['sex'] as String?,
        heightCm: num.tryParse('${json['height_cm']}'),
        goal: json['goal'] as String?,
        activityLevel: json['activity_level'] as String?,
      );

  int? get age {
    if (birthDate == null) return null;
    final birth = DateTime.parse(birthDate!);
    final now = DateTime.now();
    var years = now.year - birth.year;
    if (now.month < birth.month ||
        (now.month == birth.month && now.day < birth.day)) {
      years--;
    }
    return years;
  }
}

class Me {
  const Me({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.accountType,
    required this.profile,
  });

  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String accountType;
  final ProfileData profile;

  String get fullName => [firstName, lastName].where((s) => s.isNotEmpty).join(' ');

  factory Me.fromJson(Map<String, dynamic> json) => Me(
        id: json['id'] as int,
        email: json['email'] as String,
        firstName: json['first_name'] as String? ?? '',
        lastName: json['last_name'] as String? ?? '',
        accountType: json['account_type'] as String? ?? 'user',
        profile: json['profile'] == null
            ? const ProfileData()
            : ProfileData.fromJson(json['profile'] as Map<String, dynamic>),
      );
}

class ProfileRepository {
  ProfileRepository(this._ref);

  final Ref _ref;

  Future<Me> getMe() async {
    final res = await _ref.read(apiClientProvider).dio.get('/me/');
    return Me.fromJson(res.data as Map<String, dynamic>);
  }

  Future<Me> updateProfile({
    String? birthDate,
    String? sex,
    num? heightCm,
    String? goal,
    String? activityLevel,
  }) async {
    final res = await _ref.read(apiClientProvider).dio.patch('/me/', data: {
      'profile': {
        if (birthDate != null) 'birth_date': birthDate,
        if (sex != null) 'sex': sex,
        if (heightCm != null) 'height_cm': heightCm,
        if (goal != null) 'goal': goal,
        if (activityLevel != null) 'activity_level': activityLevel,
      },
    });
    return Me.fromJson(res.data as Map<String, dynamic>);
  }
}

final profileRepositoryProvider = Provider((ref) => ProfileRepository(ref));

final meProvider = FutureProvider<Me>((ref) {
  ref.watch(authControllerProvider.select((s) => s.status));
  return ref.watch(profileRepositoryProvider).getMe();
});
