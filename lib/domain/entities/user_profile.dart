/// -----------------------------------------------------------------
/// 👤 USER PROFILE ENTITY / BENUTZERPROFIL / ملف المستخدم
/// -----------------------------------------------------------------
/// Represents user profile data from Supabase, including organization linkage.
/// -----------------------------------------------------------------
class UserProfile {
  /// User ID from Supabase Auth
  final String userId;
  
  /// User's display name (nullable - optional)
  final String? name;
  
  /// Avatar URL (nullable - optional)
  final String? avatarUrl;
  
  /// Organization ID (nullable - for B2B users)
  /// If null, user is not linked to any organization
  final String? organizationId;
  
  /// Created at timestamp
  final DateTime? createdAt;
  
  /// Updated at timestamp
  final DateTime? updatedAt;

  const UserProfile({
    required this.userId,
    this.name,
    this.avatarUrl,
    this.organizationId,
    this.createdAt,
    this.updatedAt,
  });

  /// Create UserProfile from Supabase JSON
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['user_id'] as String? ?? json['id'] as String? ?? '',
      name: json['name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      organizationId: json['organization_id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convert UserProfile to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      if (name != null) 'name': name,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (organizationId != null) 'organization_id': organizationId,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  UserProfile copyWith({
    String? userId,
    String? name,
    String? avatarUrl,
    String? organizationId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      organizationId: organizationId ?? this.organizationId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserProfile(userId: $userId, organizationId: $organizationId)';
  }
}

