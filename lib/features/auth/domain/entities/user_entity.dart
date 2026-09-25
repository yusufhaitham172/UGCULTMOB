enum UserRole {
  creator,
  brand,
  admin;

  static UserRole? fromString(String? val) {
    if (val == null) return null;
    return switch (val.toLowerCase()) {
      'creator' => UserRole.creator,
      'brand' => UserRole.brand,
      'admin' => UserRole.admin,
      _ => null,
    };
  }
}

enum UserStatus {
  active,
  suspended,
  pendingVerification;

  static UserStatus fromString(String? val) {
    return switch (val?.toLowerCase()) {
      'suspended' => UserStatus.suspended,
      'pending_verification' => UserStatus.pendingVerification,
      _ => UserStatus.active,
    };
  }
}

/// Core App User
class AppUser {
  final String id;
  final UserRole role;
  final String phone;
  final bool phoneVerified;
  final String? email;
  final UserStatus status;
  final DateTime? createdAt;

  const AppUser({
    required this.id,
    required this.role,
    required this.phone,
    this.phoneVerified = false,
    this.email,
    this.status = UserStatus.active,
    this.createdAt,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      role: UserRole.fromString(json['role'] as String?) ?? UserRole.creator,
      phone: json['phone'] as String? ?? '',
      phoneVerified: json['phone_verified'] as bool? ?? false,
      email: json['email'] as String?,
      status: UserStatus.fromString(json['status'] as String?),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'role': role.name,
    'phone': phone,
    'phone_verified': phoneVerified,
    'email': email,
    'status': status.name,
    'created_at': createdAt?.toIso8601String(),
  };
}

/// Creator Profile Entity
class CreatorProfile {
  final String userId;
  final String displayName;
  final String? bio;
  final String? avatarUrl;
  final List<String> nicheCategories;
  final String? customNiche;
  final String governorate;
  final String? tiktokHandle;
  final String? instagramHandle;
  final String? youtubeHandle;
  final int followerCount;
  final double engagementRate;
  final int profileCompletionPct;
  final double averageRating;
  final int ratingsCount;

  const CreatorProfile({
    required this.userId,
    required this.displayName,
    this.bio,
    this.avatarUrl,
    this.nicheCategories = const [],
    this.customNiche,
    required this.governorate,
    this.tiktokHandle,
    this.instagramHandle,
    this.youtubeHandle,
    this.followerCount = 0,
    this.engagementRate = 0.0,
    this.profileCompletionPct = 0,
    this.averageRating = 5.0,
    this.ratingsCount = 0,
  });

  factory CreatorProfile.fromJson(Map<String, dynamic> json) {
    final rawNiches = json['niche_categories'];
    final List<String> niches = rawNiches is List
        ? rawNiches.map((e) => e.toString()).toList()
        : [];

    return CreatorProfile(
      userId: json['user_id'] as String? ?? '',
      displayName: json['display_name'] as String? ?? '',
      bio: json['bio'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      nicheCategories: niches,
      customNiche: json['custom_niche'] as String?,
      governorate: json['governorate'] as String? ?? 'Cairo',
      tiktokHandle: json['tiktok_handle'] as String?,
      instagramHandle: json['instagram_handle'] as String?,
      youtubeHandle: json['youtube_handle'] as String?,
      followerCount: (json['follower_count'] as num?)?.toInt() ?? 0,
      engagementRate: (json['engagement_rate'] as num?)?.toDouble() ?? 0.0,
      profileCompletionPct: (json['profile_completion_pct'] as num?)?.toInt() ?? 0,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 5.0,
      ratingsCount: (json['ratings_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'display_name': displayName,
    'bio': bio,
    'avatar_url': avatarUrl,
    'niche_categories': nicheCategories,
    'custom_niche': customNiche,
    'governorate': governorate,
    'tiktok_handle': tiktokHandle,
    'instagram_handle': instagramHandle,
    'youtube_handle': youtubeHandle,
    'follower_count': followerCount,
    'engagement_rate': engagementRate,
    'profile_completion_pct': profileCompletionPct,
    'average_rating': averageRating,
    'ratings_count': ratingsCount,
  };
}

/// Brand Profile Entity
class BrandProfile {
  final String userId;
  final String companyName;
  final String industryCategory;
  final String? description;
  final String? logoUrl;
  final String? websiteUrl;
  final String? governorate;
  final double averageRating;
  final int ratingsCount;
  final bool isVerified;

  const BrandProfile({
    required this.userId,
    required this.companyName,
    required this.industryCategory,
    this.description,
    this.logoUrl,
    this.websiteUrl,
    this.governorate,
    this.averageRating = 5.0,
    this.ratingsCount = 0,
    this.isVerified = false,
  });

  factory BrandProfile.fromJson(Map<String, dynamic> json) {
    return BrandProfile(
      userId: json['user_id'] as String? ?? '',
      companyName: json['company_name'] as String? ?? '',
      industryCategory: json['industry_category'] as String? ?? '',
      description: json['description'] as String?,
      logoUrl: json['logo_url'] as String?,
      websiteUrl: json['website_url'] as String?,
      governorate: json['governorate'] as String?,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 5.0,
      ratingsCount: (json['ratings_count'] as num?)?.toInt() ?? 0,
      isVerified: json['is_verified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'company_name': companyName,
    'industry_category': industryCategory,
    'description': description,
    'logo_url': logoUrl,
    'website_url': websiteUrl,
    'governorate': governorate,
    'average_rating': averageRating,
    'ratings_count': ratingsCount,
    'is_verified': isVerified,
  };
}

/// Creator Private Contacts (Zero-Trust PII)
class CreatorPrivateContacts {
  final String userId;
  final String fullLegalName;
  final String contactPhone;
  final String? instapayHandle;
  final String? shippingGovernorate;
  final String? shippingCity;
  final String? shippingStreetAddress;
  final String? shippingBuildingDetails;

  const CreatorPrivateContacts({
    required this.userId,
    required this.fullLegalName,
    required this.contactPhone,
    this.instapayHandle,
    this.shippingGovernorate,
    this.shippingCity,
    this.shippingStreetAddress,
    this.shippingBuildingDetails,
  });

  factory CreatorPrivateContacts.fromJson(Map<String, dynamic> json) {
    return CreatorPrivateContacts(
      userId: json['user_id'] as String? ?? '',
      fullLegalName: json['full_legal_name'] as String? ?? '',
      contactPhone: json['contact_phone'] as String? ?? '',
      instapayHandle: json['instapay_handle'] as String?,
      shippingGovernorate: json['shipping_governorate'] as String?,
      shippingCity: json['shipping_city'] as String?,
      shippingStreetAddress: json['shipping_street_address'] as String?,
      shippingBuildingDetails: json['shipping_building_details'] as String?,
    );
  }
}
