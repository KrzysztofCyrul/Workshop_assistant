import '../../domain/entities/temporary_code.dart';

class TemporaryCodeModel extends TemporaryCode {
  TemporaryCodeModel({
    required super.code,
    required super.expiresAt,
  });

  factory TemporaryCodeModel.fromJson(Map<String, dynamic> json) {
    return TemporaryCodeModel(
      code: json['code'],
      expiresAt: DateTime.parse(json['expires_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'expires_at': expiresAt.toIso8601String(),
    };
  }

  TemporaryCode toEntity() {
    return TemporaryCode(
      code: code,
      expiresAt: expiresAt,
    );
  }

  static TemporaryCodeModel fromEntity(TemporaryCode temporaryCode) {
    return TemporaryCodeModel(
      code: temporaryCode.code,
      expiresAt: temporaryCode.expiresAt,
    );
  }
}