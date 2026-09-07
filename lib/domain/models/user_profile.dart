import 'package:equatable/equatable.dart';

import 'player_progress.dart';

/// Profilo utente locale (F10, prototype-grade).
///
/// Un profilo = un'identità di login (username + hash password) + i dati
/// di gioco, che vivono sotto la chiave `slay_data_<userId>` (stesso
/// formato envelope del vecchio `slay_save_v1`). L'avatar riusa le
/// costanti di [PlayerProgress] (icone/cornici); la scelta live resta
/// nel [PlayerProgress] del save per-utente, qui è mostrata in lista.
class UserProfile extends Equatable {
  final String userId;
  final String displayName;

  /// Salt + hash FNV-1a (vedi `UserStore.hashPassword`). Profilo migrato
  /// dal vecchio save: entrambi vuoti = accesso senza password.
  final String passwordSalt;
  final String passwordHash;

  final int avatarIconIndex;
  final int avatarFrameIndex;
  final DateTime createdAt;

  const UserProfile({
    required this.userId,
    required this.displayName,
    this.passwordSalt = '',
    this.passwordHash = '',
    this.avatarIconIndex = 0,
    this.avatarFrameIndex = 0,
    required this.createdAt,
  });

  /// True per il profilo migrato dal save singolo (nessuna password).
  bool get hasPassword => passwordHash.isNotEmpty;

  /// Icona avatar (stesse opzioni di [PlayerProgress.avatarIcons]).
  String get avatarIcon => PlayerProgress.avatarIcons[
      avatarIconIndex.clamp(0, PlayerProgress.avatarIcons.length - 1)];

  /// Valore ARGB della cornice (come [PlayerProgress.avatarFrameColorValues]).
  int get avatarFrameColorValue => PlayerProgress.avatarFrameColorValues[
      avatarFrameIndex.clamp(
          0, PlayerProgress.avatarFrameColorValues.length - 1)];

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'displayName': displayName,
        'passwordSalt': passwordSalt,
        'passwordHash': passwordHash,
        'avatarIconIndex': avatarIconIndex,
        'avatarFrameIndex': avatarFrameIndex,
        'createdAt': createdAt.toIso8601String(),
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        userId: json['userId'] as String,
        displayName: json['displayName'] as String,
        passwordSalt: (json['passwordSalt'] as String?) ?? '',
        passwordHash: (json['passwordHash'] as String?) ?? '',
        avatarIconIndex:
            (json['avatarIconIndex'] as num?)?.toInt() ?? 0,
        avatarFrameIndex:
            (json['avatarFrameIndex'] as num?)?.toInt() ?? 0,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  @override
  List<Object?> get props => [
        userId,
        displayName,
        passwordSalt,
        passwordHash,
        avatarIconIndex,
        avatarFrameIndex,
        createdAt,
      ];
}
